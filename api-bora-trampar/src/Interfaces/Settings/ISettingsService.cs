using api_bora_trampar.src.Models;
using api_bora_trampar.src.Models.Base;
using api_bora_trampar.src.Requests;

namespace api_bora_trampar.src.Interfaces
{
    public interface ISettingsService
    {
        Task<ResponseApi<PlatformSettings>> GetAsync();
        Task<ResponseApi<PlatformSettings>> UpdateAsync(UpdateSettingsRequest request);
    }
}
