using api_bora_trampar.src.Models;
using MongoDB.Bson;

namespace api_bora_trampar.src.Interfaces
{
    public interface IApprovalRepository
    {
        Task<List<dynamic>> GetAllAsync(List<BsonDocument> pipeline);
        Task<Approval?> GetByIdAsync(string id);
        Task<Approval?> CreateAsync(Approval entity);
        Task<Approval?> UpdateAsync(Approval entity);
        Task<Approval> DeleteAsync(Approval entity);
    }
}
