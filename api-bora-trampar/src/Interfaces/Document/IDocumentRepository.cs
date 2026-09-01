using api_bora_trampar.src.Models;
using MongoDB.Bson;

namespace api_bora_trampar.src.Interfaces
{
    public interface IDocumentRepository
    {
        Task<List<dynamic>> GetAllAsync(List<BsonDocument> pipeline);
        Task<Document?> GetByIdAsync(string id);
        Task<Document?> CreateAsync(Document entity);
        Task<Document?> UpdateAsync(Document entity);
        Task<Document> DeleteAsync(Document entity);
    }
}
