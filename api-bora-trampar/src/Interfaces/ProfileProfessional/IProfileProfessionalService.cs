using api_bora_trampar.src.Models;
using api_bora_trampar.src.Models.Base;
using api_bora_trampar.src.Requests;

namespace api_bora_trampar.src.Interfaces
{
    public interface IProfileProfessionalService
    {
        Task<ResponseApi<ProfileProfessional?>> GetByUserIdAsync(string userId);
        Task<ResponseApi<ProfileProfessional?>> GetByIdAsync(string id);
        Task<ResponseApi<ProfileProfessional?>> SaveAsync(CreateProfileProfessionalRequest request, string userId);
        Task<ResponseApi<bool>> UpdateAvailabilityAsync(string userId, bool isAvailable);
        Task<ResponseApi<bool>> SaveIdentityVerificationAsync(string userId, string docType, string docNumber, string frontUrl, string backUrl, string selfieUrl);
    }
}
