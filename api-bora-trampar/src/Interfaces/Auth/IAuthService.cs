using api_bora_trampar.src.Models.Base;
using api_bora_trampar.src.Requests.Auth;

namespace api_bora_trampar.src.Interfaces.Auth
{
    public interface IAuthService
    {
        Task<ResponseApi<dynamic>> LoginAsync(LoginRequest request);
        Task<ResponseApi<dynamic>> RegisterAsync(RegisterRequest request);
    }
}