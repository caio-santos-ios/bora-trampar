using api_bora_trampar.src.Models;
using api_bora_trampar.src.Models.Base;
using api_bora_trampar.src.Requests.Base;
using api_bora_trampar.src.Requests.Notification;

namespace api_bora_trampar.src.Interfaces
{
    public interface INotificationService
    {
        Task<ResponseApi<List<dynamic>>> GetAllByUserIdAsync(string userId);
        Task<ResponseApi<Notification?>> GetByIdAsync(string id);
        Task<ResponseApi<Notification>> CreateAsync(CreateNotificationRequest request);
        Task<ResponseApi<Notification?>> MarkAsReadAsync(string id);
        Task<ResponseApi<Notification?>> MarkAsReadAppointmentAsync(string appointmentId);
        Task<ResponseApi<Notification?>> DeleteAsync(DeleteRequest request);
    }
}
