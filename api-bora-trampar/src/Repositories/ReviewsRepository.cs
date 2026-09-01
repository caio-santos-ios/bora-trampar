using api_bora_trampar.src.Configuration;
using api_bora_trampar.src.Interfaces;
using api_bora_trampar.src.Models;
using MongoDB.Bson;
using MongoDB.Bson.Serialization;
using MongoDB.Driver;

namespace api_bora_trampar.src.Repositories
{
    public class ReviewsRepository(AppDbContext appDbContext) : IReviewsRepository
    {
        public async Task<List<dynamic>> GetAllAsync(List<BsonDocument> pipeline)
        {
            List<BsonDocument> list = await appDbContext.Reviews.Aggregate<BsonDocument>(pipeline).ToListAsync();
            return list.Select(doc => BsonSerializer.Deserialize<dynamic>(doc)).ToList();
        }

        public async Task<Reviews?> GetByIdAsync(string id)
        {
            return await appDbContext.Reviews.Find(x => !x.Deleted && x.Id.Equals(id)).FirstOrDefaultAsync();
        }

        public async Task<Reviews?> CreateAsync(Reviews entity)
        {
            await appDbContext.Reviews.InsertOneAsync(entity);
            return entity;
        }

        public async Task<Reviews?> UpdateAsync(Reviews entity)
        {
            await appDbContext.Reviews.ReplaceOneAsync(x => x.Id.Equals(entity.Id), entity);
            return entity;
        }

        public async Task<Reviews> DeleteAsync(Reviews entity)
        {
            await appDbContext.Reviews.ReplaceOneAsync(x => x.Id.Equals(entity.Id), entity);
            return entity;
        }
    }
}
