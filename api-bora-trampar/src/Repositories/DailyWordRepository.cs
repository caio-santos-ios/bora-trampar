using api_bora_trampar.src.Configuration;
using api_bora_trampar.src.Interfaces;
using api_bora_trampar.src.Models;
using MongoDB.Bson;
using MongoDB.Bson.Serialization;
using MongoDB.Driver;

namespace api_bora_trampar.src.Repositories
{
    public class DailyWordRepository(AppDbContext appDbContext) : IDailyWordRepository
    {
        public async Task<List<dynamic>> GetAllAsync(List<BsonDocument> pipeline)
        {
            List<BsonDocument> list = await appDbContext.DailyWords.Aggregate<BsonDocument>(pipeline).ToListAsync();
            return list.Select(doc => BsonSerializer.Deserialize<dynamic>(doc)).ToList();
        }

        public async Task<long> GetCountAsync(List<BsonDocument> pipeline)
        {
            List<BsonDocument> results = await appDbContext.DailyWords.Aggregate<BsonDocument>(pipeline).ToListAsync();
            return results.Select(doc => BsonSerializer.Deserialize<dynamic>(doc)).Count();
        }

        public async Task<DailyWord?> GetByIdAsync(string id)
        {
            return await appDbContext.DailyWords.Find(x => !x.Deleted && x.Id.Equals(id)).FirstOrDefaultAsync();
        }

        public async Task<DailyWord?> GetTodayAsync(string audience)
        {
            var now = DateTime.UtcNow;
            var builder = Builders<DailyWord>.Filter;
            var filter = builder.Eq(x => x.Deleted, false) &
                         builder.Eq(x => x.IsActive, true) &
                         builder.Lte(x => x.StartDate, now) &
                         (builder.Eq(x => x.EndDate, null) | builder.Gte(x => x.EndDate, now));

            if (!string.IsNullOrWhiteSpace(audience))
            {
                var audLower = audience.Trim().ToLower();
                filter &= (builder.Eq(x => x.TargetAudience, audLower) | builder.Eq(x => x.TargetAudience, "both"));
            }

            return await appDbContext.DailyWords.Find(filter)
                .SortByDescending(x => x.StartDate)
                .ThenByDescending(x => x.CreatedAt)
                .FirstOrDefaultAsync();
        }

        public async Task<DailyWord?> CreateAsync(DailyWord entity)
        {
            await appDbContext.DailyWords.InsertOneAsync(entity);
            return entity;
        }

        public async Task<DailyWord?> UpdateAsync(DailyWord entity)
        {
            await appDbContext.DailyWords.ReplaceOneAsync(x => x.Id.Equals(entity.Id), entity);
            return entity;
        }

        public async Task<DailyWord> DeleteAsync(DailyWord entity)
        {
            await appDbContext.DailyWords.ReplaceOneAsync(x => x.Id.Equals(entity.Id), entity);
            return entity;
        }
    }
}
