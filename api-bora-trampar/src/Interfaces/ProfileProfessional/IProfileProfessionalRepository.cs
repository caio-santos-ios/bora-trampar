using api_bora_trampar.src.Models;

namespace api_bora_trampar.src.Interfaces
{
    public interface IProfileProfessionalRepository
    {
        Task<ProfileProfessional?> GetByUserIdAsync(string userId);
        Task<ProfileProfessional?> GetByIdAsync(string id);
        Task<ProfileProfessional?> CreateAsync(ProfileProfessional entity);
        Task<ProfileProfessional?> UpdateAsync(ProfileProfessional entity);
        Task<List<ProfileProfessional>> GetAllAsync();
        Task<bool> UpdateAvailabilityAsync(string userId, bool isAvailable);
        Task<bool> UpdateIdentityVerificationAsync(string userId, string docType, string docNumber, string frontUrl, string backUrl, string selfieUrl);
    }
}
