using api_bora_trampar.src.Models;
using MongoDB.Bson;

namespace api_bora_trampar.src.Interfaces
{
    public interface IVehicleRepository
    {
        Task<List<dynamic>> GetAllAsync(List<BsonDocument> pipeline);
        Task<long> GetCountAsync(List<BsonDocument> pipeline);
        Task<Vehicle?> GetByIdAsync(string id);
        Task<List<Vehicle>> GetByProfessionalIdAsync(string professionalId);
        Task<Vehicle?> CreateAsync(Vehicle entity);
        Task<Vehicle?> UpdateAsync(Vehicle entity);
        Task<Vehicle> DeleteAsync(Vehicle entity);
    }
}