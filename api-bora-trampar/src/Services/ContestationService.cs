using api_bora_trampar.src.Interfaces;
using api_bora_trampar.src.Models;
using api_bora_trampar.src.Models._Base;
using api_bora_trampar.src.Models.Base;
using api_bora_trampar.src.Requests;
using api_bora_trampar.src.Requests._Base;
using api_bora_trampar.src.Requests.Base;
using api_bora_trampar.src.Utils;
using MongoDB.Bson;

namespace api_bora_trampar.src.Services
{
    public class ContestationService(
        IContestationRepository repository,
        IAppointmentRepository appointmentRepository,
        IUserRepository userRepository,
        IUserService userService) : IContestationService
    {
        #region READ
        public async Task<ResponseApi<PaginationApi<List<dynamic>>>> GetAllAsync(GetAllRequest request)
        {
            try
            {
                Pagination<Contestation> pagination = new(request.QueryParams);

                List<BsonDocument> countPipeline =
                [
                    new("$match", pagination.PipelineFilter)
                ];

                List<BsonDocument> pipeline =
                [
                    new("$match", pagination.PipelineFilter),
                    new("$sort", pagination.PipelineSort),
                    new("$skip", pagination.Skip),
                    new("$limit", pagination.Limit),
                    new("$project", new BsonDocument
                    {
                        {"_id", 0},
                        {"id", new BsonDocument("$toString", "$_id")},
                        {"appointmentId", "$appointment_id"},
                        {"appointment_id", 1},
                        {"customerId", "$customer_id"},
                        {"customerName", "$customer_name"},
                        {"professionalId", "$professional_id"},
                        {"professionalName", "$professional_name"},
                        {"serviceName", "$service_name"},
                        {"value", 1},
                        {"totalValue", "$value"},
                        {"reason", 1},
                        {"description", 1},
                        {"customerEvidenceUrl", "$customer_evidence_url"},
                        {"proNotes", "$pro_notes"},
                        {"status", 1},
                        {"statusLabel", "$status_label"},
                        {"adminDecision", "$admin_decision"},
                        {"decidedBy", "$decided_by"},
                        {"decidedAt", "$decided_at"},
                        {"createdAt", "$created_at"},
                        {"openedAt", "$created_at"},
                        {"created_at", 1}
                    })
                ];

                long count = await repository.GetCountAsync(countPipeline);
                List<dynamic> contestations = await repository.GetAllAsync(pipeline);

                PaginationApi<List<dynamic>> data = new(contestations, count, pagination.PageNumber, pagination.PageSize);

                return new(data, 200, "Contestações listadas com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }

        public async Task<ResponseApi<List<dynamic>>> GetSelectAsync(GetAllRequest request)
        {
            try
            {
                Pagination<Contestation> pagination = new(request.QueryParams);

                List<BsonDocument> pipeline =
                [
                    new("$match", pagination.PipelineFilter),
                    new("$sort", pagination.PipelineSort),
                    new("$project", new BsonDocument
                    {
                        {"_id", 0},
                        {"id", new BsonDocument("$toString", "$_id")},
                        {"appointmentId", "$appointment_id"},
                        {"customerName", "$customer_name"},
                        {"professionalName", "$professional_name"},
                        {"reason", 1},
                        {"status", 1},
                        {"created_at", 1}
                    })
                ];

                List<dynamic> contestations = await repository.GetAllAsync(pipeline);

                return new(contestations, 200, "Contestações listadas com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }

        public async Task<ResponseApi<Contestation?>> GetByIdAsync(string id)
        {
            try
            {
                Contestation? contestation = await repository.GetByIdAsync(id);
                if (contestation is null) return new(null, 404, "Contestação não encontrada");

                return new(contestation, 200, "Contestação buscada com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }
        #endregion

        #region CREATE
        public async Task<ResponseApi<Contestation?>> CreateAsync(CreateContestationRequest request)
        {
            try
            {
                Contestation entity = ObjectMapper.Map<CreateContestationRequest, Contestation>(request);

                if (!string.IsNullOrEmpty(request.AppointmentId))
                {
                    Appointment? appointment = await appointmentRepository.GetByIdAsync(request.AppointmentId);
                    if (appointment != null)
                    {
                        if (string.IsNullOrEmpty(entity.CustomerId)) entity.CustomerId = appointment.CustomerId;
                        if (string.IsNullOrEmpty(entity.ProfessionalId)) entity.ProfessionalId = appointment.ProfessionalId;
                        if (string.IsNullOrEmpty(entity.ServiceName)) entity.ServiceName = appointment.ServiceNames ?? appointment.CategoryName ?? "Serviço Prestado";
                        if (entity.Value <= 0) entity.Value = appointment.TotalPrice;

                        appointment.Status = "Disputed";
                        appointment.UpdatedAt = DateTime.UtcNow;
                        await appointmentRepository.UpdateAsync(appointment);
                    }
                }

                if (!string.IsNullOrEmpty(entity.CustomerId) && string.IsNullOrEmpty(entity.CustomerName))
                {
                    User? customer = await userRepository.GetByIdAsync(entity.CustomerId);
                    if (customer != null) entity.CustomerName = customer.Name;
                }

                if (!string.IsNullOrEmpty(entity.ProfessionalId) && string.IsNullOrEmpty(entity.ProfessionalName))
                {
                    User? pro = await userRepository.GetByIdAsync(entity.ProfessionalId);
                    if (pro != null) entity.ProfessionalName = pro.Name;
                }

                entity.Status = "under_review";
                entity.StatusLabel = "Em Análise";
                entity.CreatedAt = DateTime.UtcNow;
                entity.UpdatedAt = DateTime.UtcNow;

                Contestation? contestation = await repository.CreateAsync(entity);
                if (contestation is null) return new(null, 400, "Falha ao criar contestação");

                return new(contestation, 201, "Contestação criada com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }
        #endregion

        #region UPDATE
        public async Task<ResponseApi<Contestation?>> UpdateAsync(UpdateContestationRequest request)
        {
            try
            {
                Contestation? existed = await repository.GetByIdAsync(request.Id);
                if (existed is null) return new(null, 404, "Contestação não encontrada");

                if (!string.IsNullOrEmpty(request.Status))
                {
                    existed.Status = request.Status;

                    if (request.Status == "refunded_full")
                    {
                        existed.StatusLabel = "Reembolso Total Cliente";
                        if (!string.IsNullOrEmpty(existed.CustomerId) && existed.Value > 0)
                        {
                            await userService.UpdateWalletBalanceAsync(existed.CustomerId, existed.Value);
                        }
                    }
                    else if (request.Status == "released_pro")
                    {
                        existed.StatusLabel = "Liberado ao Profissional";
                        if (!string.IsNullOrEmpty(existed.ProfessionalId) && existed.Value > 0)
                        {
                            await userService.UpdateWalletBalanceAsync(existed.ProfessionalId, existed.Value);
                        }
                    }
                    else if (request.Status == "refunded_partial")
                    {
                        int pct = request.PartialRefundPercentage > 0 ? request.PartialRefundPercentage : 50;
                        existed.StatusLabel = $"Reembolso Parcial ({pct}%)";
                        decimal customerRefund = existed.Value * (pct / 100m);
                        decimal proRelease = existed.Value - customerRefund;

                        if (!string.IsNullOrEmpty(existed.CustomerId) && customerRefund > 0)
                        {
                            await userService.UpdateWalletBalanceAsync(existed.CustomerId, customerRefund);
                        }
                        if (!string.IsNullOrEmpty(existed.ProfessionalId) && proRelease > 0)
                        {
                            await userService.UpdateWalletBalanceAsync(existed.ProfessionalId, proRelease);
                        }
                    }
                    else if (request.Status == "info_requested")
                    {
                        existed.StatusLabel = "Aguardando Informações";
                    }
                }

                if (!string.IsNullOrEmpty(request.StatusLabel)) existed.StatusLabel = request.StatusLabel;
                if (!string.IsNullOrEmpty(request.AdminDecision)) existed.AdminDecision = request.AdminDecision;
                if (!string.IsNullOrEmpty(request.DecidedBy)) existed.DecidedBy = request.DecidedBy;
                if (!string.IsNullOrEmpty(request.ProNotes)) existed.ProNotes = request.ProNotes;
                existed.DecidedAt = DateTime.UtcNow;
                existed.UpdatedAt = DateTime.UtcNow;

                Contestation? updated = await repository.UpdateAsync(existed);
                if (updated is null) return new(null, 400, "Falha ao atualizar contestação");

                return new(updated, 200, "Contestação atualizada com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }
        #endregion

        #region DELETE
        public async Task<ResponseApi<Contestation?>> DeleteAsync(DeleteRequest request)
        {
            try
            {
                Contestation? existedContestation = await repository.GetByIdAsync(request.Id);
                if (existedContestation is null) return new(null, 404, "Contestação não encontrada");

                existedContestation.Deleted = true;
                existedContestation.DeletedAt = DateTime.UtcNow;
                existedContestation.DeletedBy = request.DeletedBy;

                Contestation contestation = await repository.DeleteAsync(existedContestation);
                if (contestation is null) return new(null, 400, "Falha ao excluir contestação");

                return new(contestation, 204, "Contestação excluída com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }
        #endregion
    }
}
