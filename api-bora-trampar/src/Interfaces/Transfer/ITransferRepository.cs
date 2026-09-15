using api_bora_trampar.src.Models;
using MongoDB.Bson;

namespace api_bora_trampar.src.Interfaces
{
    public interface ITransferRepository
    {
        Task<List<dynamic>> GetAllAsync(List<BsonDocument> pipeline);
        Task<long> GetCountAsync(List<BsonDocument> pipeline);
        Task<Transfer?> GetByIdAsync(string id);
        Task<Transfer?> GetByAsaasIdAsync(string asaasId);
        Task<Transfer?> CreateAsync(Transfer entity);
        Task<Transfer?> UpdateAsync(Transfer entity);
        Task<Transfer> DeleteAsync(Transfer entity);
    }
}
