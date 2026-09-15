using api_bora_trampar.src.Models;
using api_bora_trampar.src.Models._Base;
using api_bora_trampar.src.Models.Base;
using api_bora_trampar.src.Requests;
using api_bora_trampar.src.Requests._Base;
using api_bora_trampar.src.Requests.Asaas;
using api_bora_trampar.src.Requests.Base;

namespace api_bora_trampar.src.Interfaces
{
    public interface ITransferService
    {
        Task<ResponseApi<PaginationApi<List<dynamic>>>> GetAllAsync(GetAllRequest request);
        Task<ResponseApi<List<dynamic>>> GetByUserAsync(string userId);
        Task<ResponseApi<Transfer?>> GetByIdAsync(string id);
        Task<ResponseApi<Transfer?>> CreateAsync(CreateTransferRequest request);
        Task<ResponseApi<Transfer?>> CheckTransferAsync(CheckTransferRequest request);
        Task<ResponseApi<Transfer?>> UpdateAsync(UpdateTransferRequest request);
        Task<ResponseApi<Transfer?>> DeleteAsync(DeleteRequest request);
    }
}
