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
                    new("$addFields", new BsonDocument
                    {
                        {"customerObjectId", new BsonDocument("$convert", new BsonDocument
                        {
                            {"input", "$customer_id"},
                            {"to", "objectId"},
                            {"onError", BsonNull.Value},
                            {"onNull", BsonNull.Value}
                        })},
                        {"professionalObjectId", new BsonDocument("$convert", new BsonDocument
                        {
                            {"input", "$professional_id"},
                            {"to", "objectId"},
                            {"onError", BsonNull.Value},
                            {"onNull", BsonNull.Value}
                        })},
                        {"appointmentObjectId", new BsonDocument("$convert", new BsonDocument
                        {
                            {"input", "$appointment_id"},
                            {"to", "objectId"},
                            {"onError", BsonNull.Value},
                            {"onNull", BsonNull.Value}
                        })},
                        {"id", new BsonDocument("$toString", "$_id")}
                    }),
                    new("$lookup", new BsonDocument
                    {
                        {"from", "users"},
                        {"localField", "customerObjectId"},
                        {"foreignField", "_id"},
                        {"as", "customer_lookup"}
                    }),
                    new("$lookup", new BsonDocument
                    {
                        {"from", "users"},
                        {"localField", "professionalObjectId"},
                        {"foreignField", "_id"},
                        {"as", "professional_lookup"}
                    }),
                    new("$lookup", new BsonDocument
                    {
                        {"from", "appointments"},
                        {"localField", "appointmentObjectId"},
                        {"foreignField", "_id"},
                        {"as", "appointment_lookup"}
                    }),
                    new("$project", new BsonDocument
                    {
                        {"_id", 0},
                        {"id", new BsonDocument("$toString", "$_id")},
                        {"appointmentId", "$appointment_id"},
                        {"appointment_id", 1},
                        {"customerId", "$customer_id"},
                        {"customer_id", 1},
                        {"customerName", new BsonDocument("$ifNull", new BsonArray
                        {
                            new BsonDocument("$arrayElemAt", new BsonArray { "$customer_lookup.name", 0 }),
                            ""
                        })},
                        {"customer_name", new BsonDocument("$ifNull", new BsonArray
                        {
                            new BsonDocument("$arrayElemAt", new BsonArray { "$customer_lookup.name", 0 }),
                            ""
                        })},
                        {"professionalId", "$professional_id"},
                        {"professional_id", 1},
                        {"professionalName", new BsonDocument("$ifNull", new BsonArray
                        {
                            new BsonDocument("$arrayElemAt", new BsonArray { "$professional_lookup.name", 0 }),
                            ""
                        })},
                        {"professional_name", new BsonDocument("$ifNull", new BsonArray
                        {
                            new BsonDocument("$arrayElemAt", new BsonArray { "$professional_lookup.name", 0 }),
                            ""
                        })},
                        {"serviceName", new BsonDocument("$ifNull", new BsonArray
                        {
                            new BsonDocument("$arrayElemAt", new BsonArray { "$appointment_lookup.service_names", 0 }),
                            new BsonDocument("$ifNull", new BsonArray
                            {
                                new BsonDocument("$arrayElemAt", new BsonArray { "$appointment_lookup.category_name", 0 }),
                                "Serviço Prestado"
                            })
                        })},
                        {"service_name", new BsonDocument("$ifNull", new BsonArray
                        {
                            new BsonDocument("$arrayElemAt", new BsonArray { "$appointment_lookup.service_names", 0 }),
                            new BsonDocument("$ifNull", new BsonArray
                            {
                                new BsonDocument("$arrayElemAt", new BsonArray { "$appointment_lookup.category_name", 0 }),
                                "Serviço Prestado"
                            })
                        })},
                        {"value", 1},
                        {"totalValue", "$value"},
                        {"reason", 1},
                        {"customerEvidenceUrl", "$customer_evidence_url"},
                        {"customer_evidence_url", 1},
                        {"proNotes", "$pro_notes"},
                        {"pro_notes", 1},
                        {"status", 1},
                        {"statusLabel", "$status_label"},
                        {"status_label", 1},
                        {"adminDecision", "$admin_decision"},
                        {"admin_decision", 1},
                        {"decidedBy", "$decided_by"},
                        {"decided_by", 1},
                        {"decidedAt", "$decided_at"},
                        {"decided_at", 1},
                        {"createdAt", "$created_at"},
                        {"created_at", 1},
                        {"openedAt", "$created_at"}
                    }),
                    new("$sort", pagination.PipelineSort),
                    new("$skip", pagination.Skip),
                    new("$limit", pagination.Limit)
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
                    new("$addFields", new BsonDocument
                    {
                        {"customerObjectId", new BsonDocument("$convert", new BsonDocument
                        {
                            {"input", "$customer_id"},
                            {"to", "objectId"},
                            {"onError", BsonNull.Value},
                            {"onNull", BsonNull.Value}
                        })},
                        {"professionalObjectId", new BsonDocument("$convert", new BsonDocument
                        {
                            {"input", "$professional_id"},
                            {"to", "objectId"},
                            {"onError", BsonNull.Value},
                            {"onNull", BsonNull.Value}
                        })},
                        {"id", new BsonDocument("$toString", "$_id")}
                    }),
                    new("$lookup", new BsonDocument
                    {
                        {"from", "users"},
                        {"localField", "customerObjectId"},
                        {"foreignField", "_id"},
                        {"as", "customer_lookup"}
                    }),
                    new("$lookup", new BsonDocument
                    {
                        {"from", "users"},
                        {"localField", "professionalObjectId"},
                        {"foreignField", "_id"},
                        {"as", "professional_lookup"}
                    }),
                    new("$project", new BsonDocument
                    {
                        {"_id", 0},
                        {"id", 1},
                        {"appointmentId", "$appointment_id"},
                        {"customerName", new BsonDocument("$ifNull", new BsonArray
                        {
                            new BsonDocument("$arrayElemAt", new BsonArray { "$customer_lookup.name", 0 }),
                            ""
                        })},
                        {"customer_name", new BsonDocument("$ifNull", new BsonArray
                        {
                            new BsonDocument("$arrayElemAt", new BsonArray { "$customer_lookup.name", 0 }),
                            ""
                        })},
                        {"professionalName", new BsonDocument("$ifNull", new BsonArray
                        {
                            new BsonDocument("$arrayElemAt", new BsonArray { "$professional_lookup.name", 0 }),
                            ""
                        })},
                        {"professional_name", new BsonDocument("$ifNull", new BsonArray
                        {
                            new BsonDocument("$arrayElemAt", new BsonArray { "$professional_lookup.name", 0 }),
                            ""
                        })},
                        {"reason", 1},
                        {"status", 1},
                        {"created_at", 1}
                    }),
                    new("$sort", pagination.PipelineSort)
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

                if (!string.IsNullOrEmpty(contestation.CustomerId))
                {
                    User? customer = await userRepository.GetByIdAsync(contestation.CustomerId);
                    if (customer != null) contestation.CustomerName = customer.Name;
                }

                if (!string.IsNullOrEmpty(contestation.ProfessionalId))
                {
                    User? pro = await userRepository.GetByIdAsync(contestation.ProfessionalId);
                    if (pro != null) contestation.ProfessionalName = pro.Name;
                }

                if (!string.IsNullOrEmpty(contestation.AppointmentId))
                {
                    Appointment? appointment = await appointmentRepository.GetByIdAsync(contestation.AppointmentId);
                    if (appointment != null) contestation.ServiceName = appointment.ServiceNames ?? appointment.CategoryName ?? "Serviço Prestado";
                }

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
                        if (entity.Value <= 0) entity.Value = appointment.TotalPrice;

                        appointment.Status = "Disputed";
                        appointment.UpdatedAt = DateTime.UtcNow;
                        await appointmentRepository.UpdateAsync(appointment);
                    }
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
