using api_bora_trampar.src.Models;
using MongoDB.Bson;

namespace api_bora_trampar.src.Interfaces
{
    public interface ICategoryRepository
    {
        Task<List<dynamic>> GetAllAsync(List<BsonDocument> pipeline);
        Task<long> GetCountAsync(List<BsonDocument> pipeline);
        Task<Category?> GetByIdAsync(string id);
        Task<Category?> CreateAsync(Category entity);
        Task<Category?> UpdateAsync(Category entity);
        Task<Category> DeleteAsync(Category entity);
    }
}