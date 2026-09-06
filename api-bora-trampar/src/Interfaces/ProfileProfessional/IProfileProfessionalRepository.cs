using api_bora_trampar.src.Models;
using MongoDB.Bson;

namespace api_bora_trampar.src.Interfaces
{
    public interface IProfileProfessionalRepository
    {
        Task<ProfileProfessional?> GetByUserIdAsync(string userId);
        Task<ProfileProfessional?> GetByIdAsync(string id);
        Task<ProfileProfessional?> CreateAsync(ProfileProfessional entity);
        Task<ProfileProfessional?> UpdateAsync(ProfileProfessional entity);
        Task<List<dynamic>> GetAllAsync(List<BsonDocument> pipeline);
        Task<List<ProfileProfessional>> GetProfileAllAsync();
        Task<bool> UpdateAvailabilityAsync(string userId, bool isAvailable);
        Task<bool> UpdateIdentityVerificationAsync(string userId, string docType, string docNumber, string frontUrl, string backUrl, string selfieUrl);
    }
}
