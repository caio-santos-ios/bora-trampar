using api_bora_trampar.src.Models.Base;
using api_bora_trampar.src.Requests;
using api_bora_trampar.src.Requests.Base;
using ServiceModel = api_bora_trampar.src.Models.Services;

namespace api_bora_trampar.src.Interfaces
{
    public interface IServicesService
    {
        Task<ResponseApi<List<dynamic>>> GetAllAsync();
        Task<ResponseApi<ServiceModel?>> GetByIdAsync(string id);
        Task<ResponseApi<ServiceModel?>> CreateAsync(CreateServicesRequest request);
        Task<ResponseApi<ServiceModel?>> UpdateAsync(UpdateServicesRequest request);
        Task<ResponseApi<ServiceModel?>> DeleteAsync(DeleteRequest request);
    }
}
