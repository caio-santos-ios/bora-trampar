using api_bora_trampar.src.Interfaces;
using api_bora_trampar.src.Models;
using api_bora_trampar.src.Models.Base;
using api_bora_trampar.src.Requests;
using api_bora_trampar.src.Requests.Base;
using api_bora_trampar.src.Utils;
using MongoDB.Bson;

namespace api_bora_trampar.src.Services
{
    public class AppointmentService(IAppointmentRepository repository) : IAppointmentService
    {
        public async Task<ResponseApi<List<dynamic>>> GetAllAsync()
        {
            try
            {
                List<BsonDocument> pipeline =
                [
                    new("$match", new BsonDocument
                    {
                        {"deleted", false}
                    }),
                    new("$addFields", new BsonDocument
                    {
                        {"customerObjectId", new BsonDocument("$convert", new BsonDocument
                        {
                            {"input", "$customer_id"},
                            {"to", "objectId"},
                            {"onError", BsonNull.Value},
                            {"onNull", BsonNull.Value}
                        })},
                        {"profissionalObjectId", new BsonDocument("$convert", new BsonDocument
                        {
                            {"input", "$profissional_id"},
                            {"to", "objectId"},
                            {"onError", BsonNull.Value},
                            {"onNull", BsonNull.Value}
                        })},
                        {"categoryObjectId", new BsonDocument("$convert", new BsonDocument
                        {
                            {"input", "$category_id"},
                            {"to", "objectId"},
                            {"onError", BsonNull.Value},
                            {"onNull", BsonNull.Value}
                        })},
                        {"serviceObjectId", new BsonDocument("$convert", new BsonDocument
                        {
                            {"input", "$service_id"},
                            {"to", "objectId"},
                            {"onError", BsonNull.Value},
                            {"onNull", BsonNull.Value}
                        })}
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
                        {"localField", "profissionalObjectId"},
                        {"foreignField", "_id"},
                        {"as", "professional_lookup"}
                    }),
                    new("$lookup", new BsonDocument
                    {
                        {"from", "categories"},
                        {"localField", "categoryObjectId"},
                        {"foreignField", "_id"},
                        {"as", "category_lookup"}
                    }),
                    new("$lookup", new BsonDocument
                    {
                        {"from", "services"},
                        {"localField", "serviceObjectId"},
                        {"foreignField", "_id"},
                        {"as", "service_lookup"}
                    }),
                    new("$project", new BsonDocument
                    {
                        {"_id", 0},
                        {"id", new BsonDocument("$toString", "$_id")},
                        {"profissional_id", 1},
                        {"customer_id", 1},
                        {"category_id", 1},
                        {"service_id", 1},
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
                        {"categoryName", new BsonDocument("$ifNull", new BsonArray
                        {
                            new BsonDocument("$arrayElemAt", new BsonArray { "$category_lookup.name", 0 }),
                            new BsonDocument("$ifNull", new BsonArray { "$category_name", "" })
                        })},
                        {"category_name", new BsonDocument("$ifNull", new BsonArray
                        {
                            new BsonDocument("$arrayElemAt", new BsonArray { "$category_lookup.name", 0 }),
                            new BsonDocument("$ifNull", new BsonArray { "$category_name", "" })
                        })},
                        {"serviceName", new BsonDocument("$ifNull", new BsonArray
                        {
                            new BsonDocument("$arrayElemAt", new BsonArray { "$service_lookup.name", 0 }),
                            new BsonDocument("$ifNull", new BsonArray { "$service_names", "" })
                        })},
                        {"service_names", new BsonDocument("$ifNull", new BsonArray
                        {
                            new BsonDocument("$arrayElemAt", new BsonArray { "$service_lookup.name", 0 }),
                            new BsonDocument("$ifNull", new BsonArray { "$service_names", "" })
                        })},
                        {"date", 1},
                        {"hour", 1},
                        {"status", 1},
                        {"address", 1},
                        {"description", 1},
                        {"notes", 1},
                        {"photo_urls", 1},
                        {"total_price", 1},
                        {"asaas_payment_id", 1},
                        {"createdAt", 1}
                    }),
                    new("$sort", new BsonDocument { { "createdAt", -1 } } )
                ];

                List<dynamic> appointments = await repository.GetAllAsync(pipeline);

                return new(appointments, 200, "Agendamentos listados com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }

        public async Task<ResponseApi<Appointment?>> GetByIdAsync(string id)
        {
            try
            {
                Appointment? appointment = await repository.GetByIdAsync(id);
                if (appointment is null) return new(null, 404, "Agendamento não encontrado");

                return new(appointment, 200, "Agendamento buscado com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }

        public async Task<ResponseApi<Appointment?>> CreateAsync(CreateAppointmentRequest request)
        {
            try
            {
                Appointment entity = ObjectMapper.Map<CreateAppointmentRequest, Appointment>(request);

                entity.ServiceNames = null;
                entity.CategoryName = null;
                entity.CreatedAt = DateTime.UtcNow;
                entity.UpdatedAt = DateTime.UtcNow;
                Appointment? appointment = await repository.CreateAsync(entity);
                if (appointment is null) return new(null, 400, "Falha ao criar agendamento");

                return new(appointment, 201, "Agendamento criado com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }

        public async Task<ResponseApi<Appointment?>> UpdateAsync(UpdateAppointmentRequest request)
        {
            try
            {
                Appointment entity = ObjectMapper.Map<UpdateAppointmentRequest, Appointment>(request);

                entity.ServiceNames = null;
                entity.CategoryName = null;

                entity.UpdatedAt = DateTime.UtcNow;
                Appointment? appointment = await repository.UpdateAsync(entity);
                if (appointment is null) return new(null, 400, "Falha ao atualizar agendamento");

                return new(appointment, 200, "Agendamento atualizado com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }

        public async Task<ResponseApi<Appointment?>> AcceptAsync(string id, string userId)
        {
            try
            {
                Appointment? appointment = await repository.GetByIdAsync(id);
                if (appointment is null) return new(null, 404, "Agendamento não encontrado");

                appointment.Status = "Accepted";
                appointment.UpdatedBy = userId;
                appointment.UpdatedAt = DateTime.UtcNow;

                Appointment? updated = await repository.UpdateAsync(appointment);
                return new(updated, 200, "Agendamento aceito com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }

        public async Task<ResponseApi<Appointment?>> DeclineAsync(string id, string userId)
        {
            try
            {
                Appointment? appointment = await repository.GetByIdAsync(id);
                if (appointment is null) return new(null, 404, "Agendamento não encontrado");

                appointment.Status = "Declined";
                appointment.UpdatedBy = userId;
                appointment.UpdatedAt = DateTime.UtcNow;

                Appointment? updated = await repository.UpdateAsync(appointment);
                return new(updated, 200, "Agendamento recusado");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }

        public async Task<ResponseApi<Appointment?>> DeleteAsync(DeleteRequest request)
        {
            try
            {
                Appointment? existedAppointment = await repository.GetByIdAsync(request.Id);
                if (existedAppointment is null) return new(null, 404, "Agendamento não encontrado");

                existedAppointment.Deleted = true;
                existedAppointment.DeletedAt = DateTime.UtcNow;
                existedAppointment.DeletedBy = request.DeletedBy;

                Appointment appointment = await repository.DeleteAsync(existedAppointment);
                if (appointment is null) return new(null, 400, "Falha ao excluir agendamento");

                return new(appointment, 204, "Agendamento excluído com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }
    }
}
