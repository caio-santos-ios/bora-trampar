using api_bora_trampar.src.Models;
using MongoDB.Bson;

namespace api_bora_trampar.src.Interfaces
{
    public interface IAppointmentRepository
    {
        Task<List<dynamic>> GetAllAsync(List<BsonDocument> pipeline);
        Task<Appointment?> GetByIdAsync(string id);
        Task<Appointment?> CreateAsync(Appointment entity);
        Task<Appointment?> UpdateAsync(Appointment entity);
        Task<Appointment> DeleteAsync(Appointment entity);
    }
}
