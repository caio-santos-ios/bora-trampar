using api_bora_trampar.src.Models;
using api_bora_trampar.src.Models.Base;
using api_bora_trampar.src.Requests;
using api_bora_trampar.src.Requests.Base;

namespace api_bora_trampar.src.Interfaces
{
    public interface IPaymentService
    {
        Task<ResponseApi<List<dynamic>>> GetAllAsync();
        Task<ResponseApi<Payment?>> GetByIdAsync(string id);
        Task<ResponseApi<Payment?>> CreateAsync(CreatePaymentRequest request);
        Task<ResponseApi<Payment?>> UpdateAsync(UpdatePaymentRequest request);
        Task<ResponseApi<Payment?>> DeleteAsync(DeleteRequest request);
    }
}
