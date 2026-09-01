using api_bora_trampar.src.Configuration;
using api_bora_trampar.src.Interfaces;
using api_bora_trampar.src.Models;
using MongoDB.Bson;
using MongoDB.Bson.Serialization;
using MongoDB.Driver;

namespace api_bora_trampar.src.Repositories
{
    public class UserRepository(AppDbContext appDbContext) : IUserRepository
    {
        public async Task<List<dynamic>> GetAllAsync(List<BsonDocument> pipeline)
        {
            List<BsonDocument> list = await appDbContext.Users.Aggregate<BsonDocument>(pipeline).ToListAsync();
            return list.Select(doc => BsonSerializer.Deserialize<dynamic>(doc)).ToList();
        }
        public async Task<User?> GetByIdAsync(string id)
        {
            return await appDbContext.Users.Find(x => !x.Deleted && x.Id.Equals(id)).FirstOrDefaultAsync();
        }
        public async Task<User?> UpdateAsync(User entity)
        {
            await appDbContext.Users.ReplaceOneAsync(x => x.Id.Equals(entity.Id), entity);
            return entity;
        }
        public async Task<User> DeleteAsync(User entity)
        {
            await appDbContext.Users.ReplaceOneAsync(x => x.Id.Equals(entity.Id), entity);
            return entity;
        }
    }
}