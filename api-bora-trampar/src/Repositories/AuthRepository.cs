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

        public async Task<User?> GetByIdAsync(string id)
        {
            return await appDbContext.Users.Find(x => !x.Deleted && x.Id.Equals(id)).FirstOrDefaultAsync();
        }

        public async Task<User?> GetByResetTokenAsync(string token)
        {
            return await appDbContext.Users.Find(x => !x.Deleted && x.PasswordResetToken != null && x.PasswordResetToken.Equals(token)).FirstOrDefaultAsync();
        }

        public async Task<User?> UpdateAsync(User entity)
        {
            await appDbContext.Users.ReplaceOneAsync(x => x.Id.Equals(entity.Id), entity);
            return entity;
        }
    }
}