using api_bora_trampar.src.Models;

namespace api_bora_trampar.src.Interfaces.Auth
{
    public interface IAuthRepository
    {
        Task<User?> RegisterAsync(User entity);
        Task<User?> GetByEmailAsync(string email);
    }
}