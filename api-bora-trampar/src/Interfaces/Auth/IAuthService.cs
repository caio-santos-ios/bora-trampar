using api_bora_trampar.src.Models.Base;
using api_bora_trampar.src.Requests.Auth;

namespace api_bora_trampar.src.Interfaces.Auth
{
    public interface IAuthService
    {
        Task<ResponseApi<dynamic>> LoginAsync(LoginRequest request);
        Task<ResponseApi<dynamic>> RegisterAsync(RegisterRequest request);
        Task<ResponseApi<dynamic>> RefreshTokenAsync(RefreshTokenRequest request);
        Task<ResponseApi<dynamic>> ForgotPasswordAsync(ForgotPasswordRequest request);
        Task<ResponseApi<dynamic>> ResetPasswordAsync(ResetPasswordRequest request);
    }
}