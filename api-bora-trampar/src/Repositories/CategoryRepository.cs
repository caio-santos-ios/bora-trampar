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
            List<BsonDocument> results = await appDbContext.Categories.Aggregate<BsonDocument>(pipeline).ToListAsync();
            return results.Select(c => (dynamic)new
            {
                id = c.Contains("id") ? c["id"].AsString : (c.Contains("_id") ? c["_id"].ToString() : ""),
                name = c.Contains("name") ? c["name"].AsString : "",
                description = c.Contains("description") && !c["description"].IsBsonNull ? c["description"].AsString : "",
                icon = c.Contains("icon") && !c["icon"].IsBsonNull ? c["icon"].AsString : "fa-layer-group",
                createdAt = c.Contains("createdAt") && !c["createdAt"].IsBsonNull ? c["createdAt"].ToUniversalTime() : DateTime.UtcNow
            }).ToList();
        }
        public async Task<long> GetCountAsync(List<BsonDocument> pipeline)
        {
            List<BsonDocument> countPipeline = new(pipeline);
            countPipeline.Add(new BsonDocument("$count", "total"));
            var result = await appDbContext.Categories.Aggregate<BsonDocument>(countPipeline).FirstOrDefaultAsync();
            if (result == null) return 0;
            return result.Contains("total") ? result["total"].ToInt64() : 0;
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