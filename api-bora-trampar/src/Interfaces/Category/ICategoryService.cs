using api_bora_trampar.src.Models;
using api_bora_trampar.src.Models.Base;
using api_bora_trampar.src.Requests;
using api_bora_trampar.src.Requests.Base;

namespace api_bora_trampar.src.Interfaces
{
    public interface ICategoryService
    {
        Task<ResponseApi<List<dynamic>>> GetAllAsync();
        Task<ResponseApi<Category?>> GetByIdAsync(string id);
        Task<ResponseApi<Category?>> CreateAsync(CreateCategoryRequest request);
        Task<ResponseApi<Category?>> UpdateAsync(UpdateCategoryRequest request);
        Task<ResponseApi<Category?>> DeleteAsync(DeleteRequest request);
    }
}