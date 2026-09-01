using api_bora_trampar.src.Models;
using api_bora_trampar.src.Models.Base;
using api_bora_trampar.src.Requests.Base;
using api_bora_trampar.src.Requests;

namespace api_bora_trampar.src.Interfaces
{
    public interface IUserService
    {
        Task<ResponseApi<List<dynamic>>> GetAllAsync();
        Task<ResponseApi<User?>> GetByIdAsync(string id);
        Task<ResponseApi<User?>> UpdateAsync(UpdateUserRequest request);
        Task<ResponseApi<User?>> DeleteAsync(DeleteRequest request);
    }
}