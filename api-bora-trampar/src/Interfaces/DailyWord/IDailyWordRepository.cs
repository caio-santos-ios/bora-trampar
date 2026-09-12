using api_bora_trampar.src.Models;
using MongoDB.Bson;

namespace api_bora_trampar.src.Interfaces
{
    public interface IDailyWordRepository
    {
        Task<List<dynamic>> GetAllAsync(List<BsonDocument> pipeline);
        Task<long> GetCountAsync(List<BsonDocument> pipeline);
        Task<DailyWord?> GetByIdAsync(string id);
        Task<DailyWord?> GetTodayAsync(string audience);
        Task<DailyWord?> CreateAsync(DailyWord entity);
        Task<DailyWord?> UpdateAsync(DailyWord entity);
        Task<DailyWord> DeleteAsync(DailyWord entity);
    }
}
