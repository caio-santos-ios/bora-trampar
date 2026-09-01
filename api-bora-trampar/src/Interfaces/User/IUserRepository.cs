using api_bora_trampar.src.Models;
using MongoDB.Bson;

namespace api_bora_trampar.src.Interfaces
{
    public interface IUserRepository
    {
        Task<List<dynamic>> GetAllAsync(List<BsonDocument> pipeline);
        Task<User?> GetByIdAsync(string id);
        Task<User?> UpdateAsync(User entity);
        Task<User> DeleteAsync(User entity);
    }
}