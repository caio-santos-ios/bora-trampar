using api_bora_trampar.src.Models;
using api_bora_trampar.src.Models._Base;
using api_bora_trampar.src.Models.Base;
using api_bora_trampar.src.Requests;
using api_bora_trampar.src.Requests._Base;
using api_bora_trampar.src.Requests.Base;

namespace api_bora_trampar.src.Interfaces
{
    public interface IVehicleService
    {
        Task<ResponseApi<PaginationApi<List<dynamic>>>> GetAllAsync(GetAllRequest request);
        Task<ResponseApi<List<dynamic>>> GetSelectAsync(GetAllRequest request);
        Task<ResponseApi<Vehicle?>> GetByIdAsync(string id);
        Task<ResponseApi<List<Vehicle>>> GetByProfessionalAsync(string professionalId);
        Task<ResponseApi<Vehicle?>> CreateAsync(CreateVehicleRequest request, string professionalId);
        Task<ResponseApi<Vehicle?>> UpdateAsync(UpdateVehicleRequest request);
        Task<ResponseApi<Vehicle?>> SetDefaultAsync(string id, string professionalId);
        Task<ResponseApi<Vehicle?>> DeleteAsync(DeleteRequest request);
    }
}