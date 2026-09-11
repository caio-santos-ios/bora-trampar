using System.Collections.Concurrent;
using api_bora_trampar.src.Interfaces;
using api_bora_trampar.src.Models;
using api_bora_trampar.src.Models.Base;
using api_bora_trampar.src.Requests;
using api_bora_trampar.src.Requests.Base;
using api_bora_trampar.src.Requests.Notification;
using api_bora_trampar.src.Requests.Payment;
using api_bora_trampar.src.SignalR;
using api_bora_trampar.src.Utils;
using Microsoft.AspNetCore.SignalR;
using MongoDB.Bson;

namespace api_bora_trampar.src.Services
{
    public class PaymentService(IPaymentRepository repository, IAppointmentRepository appointmentRepository, IUserService userService, IAsaasService asaasService, INotificationService notificationService, IHubContext<AppointmentHub> hub) : IPaymentService
    {
        private static readonly ConcurrentDictionary<string, SemaphoreSlim> _locks = new();
        public async Task<ResponseApi<List<dynamic>>> GetAllAsync()
        {
            try
            {
                List<BsonDocument> pipeline =
                [
                    new("$match", new BsonDocument
                    {
                        {"deleted", false},
                    }),
                    new("$addFields", new BsonDocument {
                        {"appointmentId", new BsonDocument("$toObjectId", "$appointment_id")}
                    }),
                    new("$lookup", new BsonDocument
                    {
                        {"from", "appointments"},
                        {"localField", "appointmentId"},
                        {"foreignField", "_id"},
                        {"as", "appointments"}
                    }),
                    new("$project", new BsonDocument
                    {
                        {"_id", 0},
                        {"id", new BsonDocument("$toString", "$_id")},
                        {"appointment_id", 1},
                        {"method_payment", 1},
                        {"appointmentStatus", new BsonDocument("$first", "$appointments.status")},
                        {"date", 1},
                        {"value", new BsonDocument("$toDouble", "$value")},
                        {"status", 1},
                        {"asaas_id", 1},
                        {"qr_code_image", 1},
                        {"qr_code_payload", 1},
                        {"createdAt", 1}
                    }),
                    new("$sort", new BsonDocument { { "createdAt", -1 } } )
                ];

                List<dynamic> payments = await repository.GetAllAsync(pipeline);

                return new(payments, 200, "Pagamentos listados com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }

        public async Task<ResponseApi<Payment?>> GetByIdAsync(string id)
        {
            try
            {
                Payment? payment = await repository.GetByIdAsync(id);
                if (payment is null) return new(null, 404, "Pagamento não encontrado");

                return new(payment, 200, "Pagamento buscado com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }

        public async Task<ResponseApi<Payment?>> CreateAsync(CreatePaymentRequest request)
        {
            string lockKey = !string.IsNullOrEmpty(request.AppointmentId)
                ? request.AppointmentId
                : (!string.IsNullOrEmpty(request.CreatedBy) ? request.CreatedBy : "global_payment_lock");

            var semaphore = _locks.GetOrAdd(lockKey, _ => new SemaphoreSlim(1, 1));
            await semaphore.WaitAsync();

            try
            {
                Payment entity = ObjectMapper.Map<CreatePaymentRequest, Payment>(request);

                string userId = request.CreatedBy;
                if (string.IsNullOrEmpty(userId) && !string.IsNullOrEmpty(request.AppointmentId))
                {
                    Appointment? appointment = await appointmentRepository.GetByIdAsync(request.AppointmentId);
                    if (appointment is not null && !string.IsNullOrEmpty(appointment.CustomerId))
                    {
                        userId = appointment.CustomerId;
                    }
                }

                if (!string.IsNullOrEmpty(request.AppointmentId))
                {
                    List<BsonDocument> checkPipeline =
                    [
                        new("$match", new BsonDocument
                        {
                            {"deleted", false},
                            {"appointment_id", request.AppointmentId},
                            {"status", "PENDING"}
                        }),
                        new("$project", new BsonDocument
                        {
                            {"_id", 0},
                            {"id", new BsonDocument("$toString", "$_id")}
                        })
                    ];
                    var existingList = await repository.GetAllAsync(checkPipeline);
                    if (existingList != null && existingList.Count > 0)
                    {
                        string existingId = existingList[0].id?.ToString() ?? "";
                        if (!string.IsNullOrEmpty(existingId))
                        {
                            Payment? existing = await repository.GetByIdAsync(existingId);
                            if (existing != null && !string.IsNullOrEmpty(existing.QrCodePayload))
                            {
                                return new(existing, 200, "Cobrança Pix pendente recuperada");
                            }
                        }
                    }
                }

                ResponseApi<User?> user = await userService.GetByIdAsync(userId);

                if (user?.Data is null) return new(null, 400, "Cliente não encontrado");

                string asaasCustomerId = await asaasService.GetOrCreateCustomerAsync(user.Data.Name, user.Data.Document, user.Data.Email, user.Data.WhatsApp);
                var asaasPix = await asaasService.CreatePixPaymentAsync(asaasCustomerId, request.Value, "Diária de Serviço - Bora Trampar");
                if (asaasPix is null) return new(null, 400, "Falha ao gerar pix no Asaas");

                entity.MethodPayment = "PIX Instantâneo";
                entity.Status = "PENDING";
                entity.AsaasId = asaasPix.Value.paymentId;
                entity.QrCodeImage = asaasPix.Value.qrCodeImage;
                entity.QrCodePayload = asaasPix.Value.qrCodePayload;

                entity.CreatedAt = DateTime.UtcNow;
                entity.UpdatedAt = DateTime.UtcNow;
                Payment? payment = await repository.CreateAsync(entity);
                if (payment is null) return new(null, 400, "Falha ao criar pagamento");

                return new(payment, 201, "Pagamento criado com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
            finally
            {
                semaphore.Release();
            }
        }

        public async Task<ResponseApi<Payment?>> UpdateAsync(UpdatePaymentRequest request)
        {
            try
            {
                Payment entity = ObjectMapper.Map<UpdatePaymentRequest, Payment>(request);

                entity.UpdatedAt = DateTime.UtcNow;
                Payment? payment = await repository.UpdateAsync(entity);
                if (payment is null) return new(null, 400, "Falha ao atualizar pagamento");

                return new(payment, 200, "Pagamento atualizado com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }

        public async Task<ResponseApi<Payment?>> ConfirmPaymentAsync(string paymentId, string userId)
        {
            try
            {
                Payment? payment = await repository.GetByIdAsync(paymentId);
                if (payment is null) return new(null, 404, "Pagamento não encontrado");

                string? asaasPaymentId = !string.IsNullOrEmpty(payment.AsaasId) ? payment.AsaasId : payment.Id;
                bool isReceived = await asaasService.IsPaymentReceivedAsync(asaasPaymentId ?? "");

                if (!isReceived)
                {
                    return new(payment, 400, "O pagamento via PIX ainda não foi identificado. Se você já realizou o pagamento, aguarde alguns segundos e tente novamente.");
                }

                payment.Status = "RECEIVED";
                payment.UpdatedBy = userId;
                payment.UpdatedAt = DateTime.UtcNow;

                Payment? updatedPayment = await repository.UpdateAsync(payment);

                if (!string.IsNullOrEmpty(payment.AppointmentId))
                {
                    Appointment? appointment = await appointmentRepository.GetByIdAsync(payment.AppointmentId);
                    if (appointment is not null)
                    {
                        appointment.Status = "PendingAcceptance";
                        await appointmentRepository.UpdateAsync(appointment);

                        if (!string.IsNullOrWhiteSpace(appointment.ProfessionalId))
                        {
                            string message = "Você recebeu uma nova solicitação de agendamento.";

                            CreateNotificationRequest notification = new()
                            {
                                UserId = appointment.ProfessionalId,
                                Title = "Novo Agendamento Recebido!",
                                Message = message,
                                Type = Models.Enums.NotificationTypeEnum.Service,
                                Read = false,
                                Send = false,
                                SendAt = DateTime.UtcNow
                            };

                            await notificationService.CreateAsync(notification);
                        }
                    }
                }

                return new(updatedPayment, 200, "Pagamento confirmado com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }
        public async Task<ResponseApi<Payment?>> CheckPaymentAsync(CheckPaymentRequest request)
        {
            try
            {
                if (!request.Event.Equals("PAYMENT_RECEIVED")) return new(null, 400, "Evento não mapeada");

                Payment? payment = await repository.GetByAssasIdAsync(request.Payment.Id);
                if (payment is null) return new(null, 404, "Pagamento não encontrado");

                payment.Status = "RECEIVED";
                payment.UpdatedAt = DateTime.UtcNow;

                Payment? updatedPayment = await repository.UpdateAsync(payment);

                if (!string.IsNullOrEmpty(payment.AppointmentId))
                {
                    Appointment? appointment = await appointmentRepository.GetByIdAsync(payment.AppointmentId);

                    if (appointment is not null)
                    {
                        appointment.Status = "PendingAcceptance";
                        await appointmentRepository.UpdateAsync(appointment);

                        if (!string.IsNullOrWhiteSpace(appointment.ProfessionalId))
                        {
                            string message = "Você recebeu uma nova solicitação de agendamento.";

                            CreateNotificationRequest notification = new()
                            {
                                UserId = appointment.ProfessionalId,
                                Title = "Novo Agendamento Recebido!",
                                Message = message,
                                Type = Models.Enums.NotificationTypeEnum.Service,
                                Read = false,
                                Send = false,
                                SendAt = DateTime.UtcNow
                            };

                            await notificationService.CreateAsync(notification);
                        }
                    }
                }

                await hub.Clients.Group($"appointment-{payment.AppointmentId}").SendAsync("AppointmentUpdated", new { payment.AppointmentId, status = "Received" });

                return new(updatedPayment, 200, "Pagamento confirmado com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }
        public async Task<ResponseApi<Payment?>> UpdateRefundCustomerAsync(string appointmentId)
        {
            try
            {
                Payment? payment = await repository.GetByAppointmentIdAsync(appointmentId);
                if (payment is null) return new(null, 404, "Pagamento não encontrado");

                payment.Status = "EXPENSE";
                payment.UpdatedAt = DateTime.UtcNow;

                Payment? updatedPayment = await repository.UpdateAsync(payment);
                if (updatedPayment is null) return new(null, 400, "Falha ao fazer reembolso");

                Appointment? appointment = await appointmentRepository.GetByIdAsync(appointmentId);
                if (appointment is not null)
                {
                    await userService.UpdateWalletBalanceAsync(appointment.CustomerId, payment.Value);
                }


                return new(updatedPayment, 200, "Reembolso feito com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }
        public async Task<ResponseApi<Payment?>> DeleteAsync(DeleteRequest request)
        {
            try
            {
                Payment? existedPayment = await repository.GetByIdAsync(request.Id);
                if (existedPayment is null) return new(null, 404, "Pagamento não encontrado");

                existedPayment.Deleted = true;
                existedPayment.DeletedAt = DateTime.UtcNow;
                existedPayment.DeletedBy = request.DeletedBy;

                Payment payment = await repository.DeleteAsync(existedPayment);
                if (payment is null) return new(null, 400, "Falha ao excluir pagamento");

                return new(payment, 204, "Pagamento excluído com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }
    }
}
