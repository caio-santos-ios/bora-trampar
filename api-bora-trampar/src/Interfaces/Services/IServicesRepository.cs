using api_bora_trampar.src.Models;
using MongoDB.Bson;
using ServiceModel = api_bora_trampar.src.Models.Services;

namespace api_bora_trampar.src.Interfaces
{
    public interface IServicesRepository
    {
        Task<List<dynamic>> GetAllAsync(List<BsonDocument> pipeline);
        Task<ServiceModel?> GetByIdAsync(string id);
        Task<ServiceModel?> CreateAsync(ServiceModel entity);
        Task<ServiceModel?> UpdateAsync(ServiceModel entity);
        Task<ServiceModel> DeleteAsync(ServiceModel entity);
    }
}
