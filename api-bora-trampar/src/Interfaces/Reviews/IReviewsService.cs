using api_bora_trampar.src.Models;
using api_bora_trampar.src.Models.Base;
using api_bora_trampar.src.Requests;
using api_bora_trampar.src.Requests.Base;

namespace api_bora_trampar.src.Interfaces
{
    public interface IReviewsService
    {
        Task<ResponseApi<List<dynamic>>> GetAllAsync();
        Task<ResponseApi<Reviews?>> GetByIdAsync(string id);
        Task<ResponseApi<Reviews?>> CreateAsync(CreateReviewsRequest request);
        Task<ResponseApi<Reviews?>> UpdateAsync(UpdateReviewsRequest request);
        Task<ResponseApi<Reviews?>> DeleteAsync(DeleteRequest request);
    }
}
