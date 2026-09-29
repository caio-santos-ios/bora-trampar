using api_bora_trampar.src.Configuration;
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
    public class VehicleService(IVehicleRepository repository) : IVehicleService
    {
        #region READ
        public async Task<ResponseApi<PaginationApi<List<dynamic>>>> GetAllAsync(GetAllRequest request)
        {
            try
            {
                Pagination<Vehicle> pagination = new(request.QueryParams);

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
                        {"professionalId", new BsonDocument("$ifNull", new BsonArray { "$professionalId", "$professional_id", "" })},
                        {"vehicleType", new BsonDocument("$ifNull", new BsonArray { "$vehicleType", "$vehicle_type", "" })},
                        {"brand", 1},
                        {"model", 1},
                        {"year", 1},
                        {"plateNumber", new BsonDocument("$ifNull", new BsonArray { "$plateNumber", "$plate_number", "" })},
                        {"isDefault", new BsonDocument("$ifNull", new BsonArray { "$isDefault", "$is_default", false })},
                        {"isActive", new BsonDocument("$ifNull", new BsonArray { "$isActive", "$is_active", true })},
                        {"approvalStatus", new BsonDocument("$ifNull", new BsonArray { "$approvalStatus", "$approval_status", "" })},
                        {"created_at", 1}
                    })
                ];

                long count = await repository.GetCountAsync(countPipeline);
                List<dynamic> list = await repository.GetAllAsync(pipeline);

                PaginationApi<List<dynamic>> data = new(list, count, pagination.PageNumber, pagination.PageSize);

                return new(data, 200, "Veículos listados com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado: {ex.Message}");
            }
        }

        public async Task<ResponseApi<List<dynamic>>> GetSelectAsync(GetAllRequest request)
        {
            try
            {
                Pagination<Vehicle> pagination = new(request.QueryParams);

                List<BsonDocument> pipeline =
                [
                    new("$match", pagination.PipelineFilter),
                    new("$sort", pagination.PipelineSort),
                    new("$project", new BsonDocument
                    {
                        {"_id", 0},
                        {"id", new BsonDocument("$toString", "$_id")},
                        {"vehicleType", new BsonDocument("$ifNull", new BsonArray { "$vehicleType", "$vehicle_type", "" })},
                        {"brand", 1},
                        {"model", 1},
                        {"plateNumber", new BsonDocument("$ifNull", new BsonArray { "$plateNumber", "$plate_number", "" })}
                    })
                ];

                List<dynamic> list = await repository.GetAllAsync(pipeline);

                return new(list, 200, "Veículos listados com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado: {ex.Message}");
            }
        }

        public async Task<ResponseApi<Vehicle?>> GetByIdAsync(string id)
        {
            try
            {
                Vehicle? vehicle = await repository.GetByIdAsync(id);
                if (vehicle is null) return new(null, 404, "Veículo não encontrado");

                return new(vehicle, 200, "Veículo buscado com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado: {ex.Message}");
            }
        }

        public async Task<ResponseApi<List<Vehicle>>> GetByProfessionalAsync(string professionalId)
        {
            try
            {
                List<Vehicle> vehicles = await repository.GetByProfessionalIdAsync(professionalId);
                return new(vehicles, 200, "Veículos listados com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado: {ex.Message}");
            }
        }
        #endregion

        #region CREATE
        public async Task<ResponseApi<Vehicle?>> CreateAsync(CreateVehicleRequest request, string professionalId)
        {
            try
            {
                Vehicle entity = ObjectMapper.Map<CreateVehicleRequest, Vehicle>(request);

                entity.ProfessionalId = professionalId;
                entity.ApprovalStatus = "Pending";
                entity.IsActive = true;
                entity.CreatedAt = DateTime.UtcNow;
                entity.UpdatedAt = DateTime.UtcNow;
                entity.CreatedBy = professionalId;

                // Primeiro veículo do profissional já nasce como padrão
                List<Vehicle> existing = await repository.GetByProfessionalIdAsync(professionalId);
                entity.IsDefault = request.IsDefault || existing.Count == 0;

                Vehicle? vehicle = await repository.CreateAsync(entity);
                if (vehicle is null) return new(null, 400, "Falha ao cadastrar veículo");

                if (vehicle.IsDefault)
                {
                    await UnsetOtherDefaultsAsync(professionalId, vehicle.Id);
                }

                return new(vehicle, 201, "Veículo cadastrado com sucesso e enviado para aprovação");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado: {ex.Message}");
            }
        }
        #endregion

        #region UPDATE
        public async Task<ResponseApi<Vehicle?>> UpdateAsync(UpdateVehicleRequest request)
        {
            try
            {
                Vehicle? existed = await repository.GetByIdAsync(request.Id);
                if (existed is null) return new(null, 404, "Veículo não encontrado");

                if (!string.IsNullOrWhiteSpace(request.VehicleType)) existed.VehicleType = request.VehicleType;
                if (!string.IsNullOrWhiteSpace(request.Brand)) existed.Brand = request.Brand;
                if (!string.IsNullOrWhiteSpace(request.Model)) existed.Model = request.Model;
                if (request.Year > 0) existed.Year = request.Year;
                if (!string.IsNullOrWhiteSpace(request.PlateNumber)) existed.PlateNumber = request.PlateNumber;
                if (request.ApproximateCapacityKg > 0) existed.ApproximateCapacityKg = request.ApproximateCapacityKg;
                if (!string.IsNullOrWhiteSpace(request.Dimensions)) existed.Dimensions = request.Dimensions;
                if (!string.IsNullOrWhiteSpace(request.PhotoUrl)) existed.PhotoUrl = request.PhotoUrl;
                if (!string.IsNullOrWhiteSpace(request.DocumentUrl)) existed.DocumentUrl = request.DocumentUrl;

                // Alterar dados de cadastro manda o veículo de volta para análise
                bool changedRegistrationData = !string.IsNullOrWhiteSpace(request.PhotoUrl) ||
                    !string.IsNullOrWhiteSpace(request.DocumentUrl) ||
                    !string.IsNullOrWhiteSpace(request.PlateNumber);
                if (changedRegistrationData && existed.ApprovalStatus == "Approved")
                {
                    existed.ApprovalStatus = "Pending";
                }

                // Campos exclusivos de admin
                if (request.IsActive.HasValue) existed.IsActive = request.IsActive.Value;
                if (!string.IsNullOrWhiteSpace(request.ApprovalStatus)) existed.ApprovalStatus = request.ApprovalStatus;
                if (!string.IsNullOrWhiteSpace(request.ApprovalNotes)) existed.ApprovalNotes = request.ApprovalNotes;

                existed.UpdatedAt = DateTime.UtcNow;

                Vehicle? updated = await repository.UpdateAsync(existed);
                if (updated is null) return new(null, 400, "Falha ao atualizar veículo");

                if (request.IsDefault && !updated.IsDefault)
                {
                    updated.IsDefault = true;
                    await repository.UpdateAsync(updated);
                    await UnsetOtherDefaultsAsync(updated.ProfessionalId, updated.Id);
                }

                return new(updated, 200, "Veículo atualizado com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado: {ex.Message}");
            }
        }

        public async Task<ResponseApi<Vehicle?>> SetDefaultAsync(string id, string professionalId)
        {
            try
            {
                Vehicle? existed = await repository.GetByIdAsync(id);
                if (existed is null) return new(null, 404, "Veículo não encontrado");
                if (existed.ProfessionalId != professionalId) return new(null, 403, "Este veículo não pertence a você");

                existed.IsDefault = true;
                existed.UpdatedAt = DateTime.UtcNow;

                Vehicle? updated = await repository.UpdateAsync(existed);
                if (updated is null) return new(null, 400, "Falha ao definir veículo padrão");

                await UnsetOtherDefaultsAsync(professionalId, id);

                return new(updated, 200, "Veículo definido como padrão");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado: {ex.Message}");
            }
        }

        private async Task UnsetOtherDefaultsAsync(string professionalId, string keepId)
        {
            List<Vehicle> others = await repository.GetByProfessionalIdAsync(professionalId);
            foreach (Vehicle other in others.Where(v => v.Id != keepId && v.IsDefault))
            {
                other.IsDefault = false;
                other.UpdatedAt = DateTime.UtcNow;
                await repository.UpdateAsync(other);
            }
        }
        #endregion

        #region DELETE
        public async Task<ResponseApi<Vehicle?>> DeleteAsync(DeleteRequest request)
        {
            try
            {
                Vehicle? existed = await repository.GetByIdAsync(request.Id);
                if (existed is null) return new(null, 404, "Veículo não encontrado");

                existed.Deleted = true;
                existed.DeletedAt = DateTime.UtcNow;
                existed.DeletedBy = request.DeletedBy;

                Vehicle deleted = await repository.DeleteAsync(existed);
                if (deleted is null) return new(null, 400, "Falha ao excluir veículo");

                return new(deleted, 204, "Veículo excluído com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado: {ex.Message}");
            }
        }
        #endregion
    }
}