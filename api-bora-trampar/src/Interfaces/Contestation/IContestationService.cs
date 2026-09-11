using api_bora_trampar.src.Models;
using api_bora_trampar.src.Models._Base;
using api_bora_trampar.src.Models.Base;
using api_bora_trampar.src.Requests;
using api_bora_trampar.src.Requests._Base;
using api_bora_trampar.src.Requests.Base;

namespace api_bora_trampar.src.Interfaces
{
    public interface IContestationService
    {
        Task<ResponseApi<PaginationApi<List<dynamic>>>> GetAllAsync(GetAllRequest request);
        Task<ResponseApi<List<dynamic>>> GetSelectAsync(GetAllRequest request);
        Task<ResponseApi<Contestation?>> GetByIdAsync(string id);
        Task<ResponseApi<Contestation?>> CreateAsync(CreateContestationRequest request);
        Task<ResponseApi<Contestation?>> UpdateAsync(UpdateContestationRequest request);
        Task<ResponseApi<Contestation?>> DeleteAsync(DeleteRequest request);
    }
}
