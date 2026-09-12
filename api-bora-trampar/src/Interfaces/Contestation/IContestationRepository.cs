using api_bora_trampar.src.Models;
using MongoDB.Bson;

namespace api_bora_trampar.src.Interfaces
{
    public interface IContestationRepository
    {
        Task<List<dynamic>> GetAllAsync(List<BsonDocument> pipeline);
        Task<long> GetCountAsync(List<BsonDocument> pipeline);
        Task<Contestation?> GetByIdAsync(string id);
        Task<Contestation?> GetByAppointmentIdAsync(string appointmentId);
        Task<Contestation?> CreateAsync(Contestation entity);
        Task<Contestation?> UpdateAsync(Contestation entity);
        Task<Contestation> DeleteAsync(Contestation entity);
    }
}
