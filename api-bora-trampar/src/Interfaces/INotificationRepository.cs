using api_bora_trampar.src.Models;
using MongoDB.Bson;

namespace api_bora_trampar.src.Interfaces
{
    public interface INotificationRepository
    {
        Task<List<dynamic>> GetAllByUserIdAsync(string userId);
        Task<Notification?> GetByIdAsync(string id);
        Task<Notification?> GetByAppointmentIdAsync(string appointmentId);
        Task<Notification> CreateAsync(Notification entity);
        Task<List<Notification>> CreateManyAsync(List<Notification> entities);
        Task<Notification> UpdateAsync(Notification entity);
        Task<Notification> DeleteAsync(Notification entity);
    }
}
