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
using MongoDB.Driver;

namespace api_bora_trampar.src.Services
{
    public class FreightOrderService(IFreightOrderRepository repository, AppDbContext appDbContext) : IFreightOrderService
    {
        #region READ
        public async Task<ResponseApi<PaginationApi<List<dynamic>>>> GetAllAsync(GetAllRequest request)
        {
            try
            {
                Pagination<FreightOrder> pagination = new(request.QueryParams);

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
                        {"customerId", new BsonDocument("$ifNull", new BsonArray { "$customerId", "$customer_id", "" })},
                        {"customerName", new BsonDocument("$ifNull", new BsonArray { "$customerName", "$customer_name", "" })},
                        {"professionalId", new BsonDocument("$ifNull", new BsonArray { "$professionalId", "$professional_id", "" })},
                        {"professionalName", new BsonDocument("$ifNull", new BsonArray { "$professionalName", "$professional_name", "" })},
                        {"originAddress", new BsonDocument("$ifNull", new BsonArray { "$originAddress", "$origin_address", "" })},
                        {"destinationAddress", new BsonDocument("$ifNull", new BsonArray { "$destinationAddress", "$destination_address", "" })},
                        {"description", 1},
                        {"vehicleType", new BsonDocument("$ifNull", new BsonArray { "$vehicleType", "$vehicle_type", "" })},
                        {"price", 1},
                        {"status", 1},
                        {"notes", 1},
                        {"created_at", 1}
                    })
                ];

                long count = await repository.GetCountAsync(countPipeline);
                List<dynamic> list = await repository.GetAllAsync(pipeline);

                PaginationApi<List<dynamic>> data = new(list, count, pagination.PageNumber, pagination.PageSize);

                return new(data, 200, "Pedidos de frete listados com sucesso");
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
                Pagination<FreightOrder> pagination = new(request.QueryParams);

                List<BsonDocument> pipeline =
                [
                    new("$match", pagination.PipelineFilter),
                    new("$sort", pagination.PipelineSort),
                    new("$project", new BsonDocument
                    {
                        {"_id", 0},
                        {"id", new BsonDocument("$toString", "$_id")},
                        {"customerId", new BsonDocument("$ifNull", new BsonArray { "$customerId", "$customer_id", "" })},
                        {"customerName", new BsonDocument("$ifNull", new BsonArray { "$customerName", "$customer_name", "" })},
                        {"professionalId", new BsonDocument("$ifNull", new BsonArray { "$professionalId", "$professional_id", "" })},
                        {"professionalName", new BsonDocument("$ifNull", new BsonArray { "$professionalName", "$professional_name", "" })},
                        {"originAddress", new BsonDocument("$ifNull", new BsonArray { "$originAddress", "$origin_address", "" })},
                        {"destinationAddress", new BsonDocument("$ifNull", new BsonArray { "$destinationAddress", "$destination_address", "" })},
                        {"description", 1},
                        {"vehicleType", new BsonDocument("$ifNull", new BsonArray { "$vehicleType", "$vehicle_type", "" })},
                        {"price", 1},
                        {"status", 1},
                        {"notes", 1},
                        {"created_at", 1}
                    })
                ];

                List<dynamic> list = await repository.GetAllAsync(pipeline);

                return new(list, 200, "Pedidos de frete listados com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado: {ex.Message}");
            }
        }

        public async Task<ResponseApi<FreightOrder?>> GetByIdAsync(string id)
        {
            try
            {
                FreightOrder? order = await repository.GetByIdAsync(id);
                if (order is null) return new(null, 404, "Pedido de frete não encontrado");

                return new(order, 200, "Pedido de frete buscado com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado: {ex.Message}");
            }
        }

        public async Task<ResponseApi<List<FreightOrder>>> GetByCustomerAsync(string customerId)
        {
            try
            {
                var orders = await appDbContext.FreightOrders
                    .Find(x => !x.Deleted && (x.CustomerId == customerId || x.CreatedBy == customerId))
                    .SortByDescending(x => x.CreatedAt)
                    .ToListAsync();

                return new(orders, 200, "Pedidos listados com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado: {ex.Message}");
            }
        }

        public async Task<ResponseApi<List<FreightOrder>>> GetByProfessionalAsync(string professionalId)
        {
            try
            {
                var orders = await appDbContext.FreightOrders
                    .Find(x => !x.Deleted && x.ProfessionalId == professionalId)
                    .SortByDescending(x => x.CreatedAt)
                    .ToListAsync();

                return new(orders, 200, "Pedidos listados com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado: {ex.Message}");
            }
        }
        #endregion

        #region CREATE
        public async Task<ResponseApi<FreightOrder?>> CreateAsync(CreateFreightOrderRequest request, string customerId, string customerName)
        {
            try
            {
                FreightOrder entity = ObjectMapper.Map<CreateFreightOrderRequest, FreightOrder>(request);

                entity.CustomerId = customerId;
                entity.CustomerName = customerName;
                entity.Status = "Pending";
                entity.CreatedAt = DateTime.UtcNow;
                entity.UpdatedAt = DateTime.UtcNow;
                entity.CreatedBy = customerId;

                FreightOrder? order = await repository.CreateAsync(entity);
                if (order is null) return new(null, 400, "Falha ao criar pedido de frete");

                return new(order, 201, "Pedido de frete criado com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado: {ex.Message}");
            }
        }
        #endregion

        #region UPDATE
        public async Task<ResponseApi<FreightOrder?>> UpdateAsync(UpdateFreightOrderRequest request)
        {
            try
            {
                FreightOrder? existed = await repository.GetByIdAsync(request.Id);
                if (existed is null) return new(null, 404, "Pedido de frete não encontrado");

                if (!string.IsNullOrWhiteSpace(request.OriginAddress)) existed.OriginAddress = request.OriginAddress;
                if (!string.IsNullOrWhiteSpace(request.DestinationAddress)) existed.DestinationAddress = request.DestinationAddress;
                if (!string.IsNullOrWhiteSpace(request.Description)) existed.Description = request.Description;
                if (!string.IsNullOrWhiteSpace(request.VehicleType)) existed.VehicleType = request.VehicleType;
                if (request.Price > 0) existed.Price = request.Price;
                if (!string.IsNullOrWhiteSpace(request.Status)) existed.Status = request.Status;
                if (!string.IsNullOrWhiteSpace(request.ProfessionalId)) existed.ProfessionalId = request.ProfessionalId;
                if (!string.IsNullOrWhiteSpace(request.Notes)) existed.Notes = request.Notes;

                existed.UpdatedAt = DateTime.UtcNow;

                FreightOrder? updated = await repository.UpdateAsync(existed);
                if (updated is null) return new(null, 400, "Falha ao atualizar pedido de frete");

                return new(updated, 200, "Pedido de frete atualizado com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado: {ex.Message}");
            }
        }

        public async Task<ResponseApi<FreightOrder?>> AcceptOrderAsync(string id, string professionalId, string professionalName)
        {
            try
            {
                FreightOrder? existed = await repository.GetByIdAsync(id);
                if (existed is null) return new(null, 404, "Pedido de frete não encontrado");

                if (existed.Status != "Pending")
                    return new(null, 400, "Este frete já foi aceito por outro profissional ou não está mais disponível.");

                existed.ProfessionalId = professionalId;
                existed.ProfessionalName = professionalName;
                existed.Status = "Accepted";
                existed.UpdatedAt = DateTime.UtcNow;

                FreightOrder? updated = await repository.UpdateAsync(existed);
                if (updated is null) return new(null, 400, "Falha ao aceitar pedido de frete");

                return new(updated, 200, "Pedido de frete aceito com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado: {ex.Message}");
            }
        }
        #endregion

        #region DELETE
        public async Task<ResponseApi<FreightOrder?>> DeleteAsync(DeleteRequest request)
        {
            try
            {
                FreightOrder? existed = await repository.GetByIdAsync(request.Id);
                if (existed is null) return new(null, 404, "Pedido de frete não encontrado");

                existed.Deleted = true;
                existed.DeletedAt = DateTime.UtcNow;
                existed.DeletedBy = request.DeletedBy;

                FreightOrder deleted = await repository.DeleteAsync(existed);
                if (deleted is null) return new(null, 400, "Falha ao excluir pedido de frete");

                return new(deleted, 204, "Pedido de frete excluído com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado: {ex.Message}");
            }
        }
        #endregion
    }
}
