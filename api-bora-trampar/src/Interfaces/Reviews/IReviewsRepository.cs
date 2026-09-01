using api_bora_trampar.src.Models;
using MongoDB.Bson;

namespace api_bora_trampar.src.Interfaces
{
    public interface IReviewsRepository
    {
        Task<List<dynamic>> GetAllAsync(List<BsonDocument> pipeline);
        Task<Reviews?> GetByIdAsync(string id);
        Task<Reviews?> CreateAsync(Reviews entity);
        Task<Reviews?> UpdateAsync(Reviews entity);
        Task<Reviews> DeleteAsync(Reviews entity);
    }
}
