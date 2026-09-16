using api_bora_trampar.src.Models;
using MongoDB.Bson;

namespace api_bora_trampar.src.Interfaces
{
    public interface IFreightOrderRepository
    {
        Task<List<dynamic>> GetAllAsync(List<BsonDocument> pipeline);
        Task<long> GetCountAsync(List<BsonDocument> pipeline);
        Task<FreightOrder?> GetByIdAsync(string id);
        Task<FreightOrder?> CreateAsync(FreightOrder entity);
        Task<FreightOrder?> UpdateAsync(FreightOrder entity);
        Task<FreightOrder> DeleteAsync(FreightOrder entity);
    }
}
