using api_bora_trampar.src.Interfaces;
using api_bora_trampar.src.Models.Base;
using api_bora_trampar.src.Requests;
using api_bora_trampar.src.Requests.Base;
using api_bora_trampar.src.Utils;
using MongoDB.Bson;
using ServiceModel = api_bora_trampar.src.Models.Services;

namespace api_bora_trampar.src.Services
{
    public class ServicesService(IServicesRepository repository) : IServicesService
    {
        #region READ
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
                    new("$project", new BsonDocument
                    {
                        {"_id", 0},
                        {"id", new BsonDocument("$toString", "$_id")},
                        {"name", 1},
                        {"categoryId", 1},
                        {"icon", 1},
                        {"createdAt", 1}
                    }),
                    new("$sort", new BsonDocument { { "createdAt", -1 } } )
                ];

                List<dynamic> services = await repository.GetAllAsync(pipeline);

                return new(services, 200, "Serviços listados com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }

        public async Task<ResponseApi<ServiceModel?>> GetByIdAsync(string id)
        {
            try
            {
                ServiceModel? service = await repository.GetByIdAsync(id);
                if (service is null) return new(null, 404, "Serviço não encontrado");

                return new(service, 200, "Serviço buscado com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }
        #endregion

        #region CREATE
        public async Task<ResponseApi<ServiceModel?>> CreateAsync(CreateServicesRequest request)
        {
            try
            {
                ServiceModel entity = ObjectMapper.Map<CreateServicesRequest, ServiceModel>(request);

                entity.CreatedAt = DateTime.UtcNow;
                entity.UpdatedAt = DateTime.UtcNow;
                ServiceModel? service = await repository.CreateAsync(entity);
                if (service is null) return new(null, 400, "Falha ao criar serviço");

                return new(service, 201, "Serviço criado com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }
        #endregion

        #region UPDATE
        public async Task<ResponseApi<ServiceModel?>> UpdateAsync(UpdateServicesRequest request)
        {
            try
            {
                ServiceModel entity = ObjectMapper.Map<UpdateServicesRequest, ServiceModel>(request);

                entity.UpdatedAt = DateTime.UtcNow;
                ServiceModel? service = await repository.UpdateAsync(entity);
                if (service is null) return new(null, 400, "Falha ao atualizar serviço");

                return new(service, 200, "Serviço atualizado com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }
        #endregion

        #region DELETE
        public async Task<ResponseApi<ServiceModel?>> DeleteAsync(DeleteRequest request)
        {
            try
            {
                ServiceModel? existedService = await repository.GetByIdAsync(request.Id);
                if (existedService is null) return new(null, 404, "Serviço não encontrado");

                existedService.Deleted = true;
                existedService.DeletedAt = DateTime.UtcNow;
                existedService.DeletedBy = request.DeletedBy;

                ServiceModel service = await repository.DeleteAsync(existedService);
                if (service is null) return new(null, 400, "Falha ao excluir serviço");

                return new(service, 204, "Serviço excluído com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }
        #endregion
    }
}
