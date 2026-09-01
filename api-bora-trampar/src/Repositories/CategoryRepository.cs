using api_bora_trampar.src.Configuration;
using api_bora_trampar.src.Interfaces;
using api_bora_trampar.src.Models;
using MongoDB.Bson;
using MongoDB.Bson.Serialization;
using MongoDB.Driver;

namespace api_bora_trampar.src.Repositories
{
    public class CategoryRepository(AppDbContext appDbContext) : ICategoryRepository
    {
        public async Task<List<dynamic>> GetAllAsync(List<BsonDocument> pipeline)
        {
            List<BsonDocument> list = await appDbContext.Users.Aggregate<BsonDocument>(pipeline).ToListAsync();
            return list.Select(doc => BsonSerializer.Deserialize<dynamic>(doc)).ToList();
        }

        public async Task<Category?> GetByIdAsync(string id)
        {
            return await appDbContext.Categories.Find(x => !x.Deleted && x.Id.Equals(id)).FirstOrDefaultAsync();
        }
        public async Task<Category?> CreateAsync(Category entity)
        {
            await appDbContext.Categories.InsertOneAsync(entity);
            return entity;
        }
        public async Task<Category?> UpdateAsync(Category entity)
        {
            await appDbContext.Categories.ReplaceOneAsync(x => x.Id.Equals(entity.Id), entity);
            return entity;
        }
        public async Task<Category> DeleteAsync(Category entity)
        {
            await appDbContext.Categories.ReplaceOneAsync(x => x.Id.Equals(entity.Id), entity);
            return entity;
        }
    }
}