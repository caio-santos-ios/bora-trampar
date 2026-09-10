using api_bora_trampar.src.Models;
using MongoDB.Bson;

namespace api_bora_trampar.src.Interfaces
{
    public interface IPaymentRepository
    {
        Task<List<dynamic>> GetAllAsync(List<BsonDocument> pipeline);
        Task<Payment?> GetByIdAsync(string id);
        Task<Payment?> GetByAssasIdAsync(string asaasId);
        Task<Payment?> GetByAppointmentIdAsync(string appointmentId);
        Task<Payment?> CreateAsync(Payment entity);
        Task<Payment?> UpdateAsync(Payment entity);
        Task<Payment> DeleteAsync(Payment entity);
    }
}
