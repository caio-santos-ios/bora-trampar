using api_bora_trampar.src.Models;
using api_bora_trampar.src.Models._Base;
using api_bora_trampar.src.Models.Base;
using api_bora_trampar.src.Requests;
using api_bora_trampar.src.Requests._Base;
using api_bora_trampar.src.Requests.Base;

namespace api_bora_trampar.src.Interfaces
{
    public interface IFreightOrderService
    {
        Task<ResponseApi<PaginationApi<List<dynamic>>>> GetAllAsync(GetAllRequest request);
        Task<ResponseApi<List<dynamic>>> GetSelectAsync(GetAllRequest request);
        Task<ResponseApi<FreightOrder?>> GetByIdAsync(string id);
        Task<ResponseApi<List<FreightOrder>>> GetByCustomerAsync(string customerId);
        Task<ResponseApi<List<FreightOrder>>> GetByProfessionalAsync(string professionalId);
        Task<ResponseApi<FreightOrder?>> CreateAsync(CreateFreightOrderRequest request, string customerId, string customerName);
        Task<ResponseApi<FreightOrder?>> UpdateAsync(UpdateFreightOrderRequest request);
        Task<ResponseApi<FreightOrder?>> AcceptOrderAsync(string id, string professionalId, string professionalName);
        Task<ResponseApi<FreightOrder?>> DeleteAsync(DeleteRequest request);
    }
}
