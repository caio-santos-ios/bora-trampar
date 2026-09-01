using api_bora_trampar.src.Models;
using api_bora_trampar.src.Models.Base;
using api_bora_trampar.src.Requests;
using api_bora_trampar.src.Requests.Base;

namespace api_bora_trampar.src.Interfaces
{
    public interface IApprovalService
    {
        Task<ResponseApi<List<dynamic>>> GetAllAsync();
        Task<ResponseApi<Approval?>> GetByIdAsync(string id);
        Task<ResponseApi<Approval?>> CreateAsync(CreateApprovalRequest request);
        Task<ResponseApi<Approval?>> UpdateAsync(UpdateApprovalRequest request);
        Task<ResponseApi<Approval?>> DeleteAsync(DeleteRequest request);
    }
}
