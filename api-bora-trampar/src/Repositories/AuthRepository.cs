using api_bora_trampar.src.Configuration;
using api_bora_trampar.src.Interfaces.Auth;
using api_bora_trampar.src.Models;
using MongoDB.Driver;

namespace api_bora_trampar.src.Repositories
{
    public class AuthRepository(AppDbContext appDbContext) : IAuthRepository
    {
        public async Task<User?> RegisterAsync(User entity)
        {
            await appDbContext.Users.InsertOneAsync(entity);
            return entity;
        }

        public async Task<User?> GetByEmailAsync(string email)
        {
            return await appDbContext.Users.Find(x => !x.Deleted && x.Email.Equals(email)).FirstOrDefaultAsync();
        }
    }
}