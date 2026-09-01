using api_bora_trampar.src.Configuration;
using api_bora_trampar.src.Interfaces;
using api_bora_trampar.src.Models;
using MongoDB.Bson;
using MongoDB.Bson.Serialization;
using MongoDB.Driver;

namespace api_bora_trampar.src.Repositories
{
    public class ApprovalRepository(AppDbContext appDbContext) : IApprovalRepository
    {
        public async Task<List<dynamic>> GetAllAsync(List<BsonDocument> pipeline)
        {
            List<BsonDocument> list = await appDbContext.Approvals.Aggregate<BsonDocument>(pipeline).ToListAsync();
            return list.Select(doc => BsonSerializer.Deserialize<dynamic>(doc)).ToList();
        }

        public async Task<Approval?> GetByIdAsync(string id)
        {
            return await appDbContext.Approvals.Find(x => !x.Deleted && x.Id.Equals(id)).FirstOrDefaultAsync();
        }

        public async Task<Approval?> CreateAsync(Approval entity)
        {
            await appDbContext.Approvals.InsertOneAsync(entity);
            return entity;
        }

        public async Task<Approval?> UpdateAsync(Approval entity)
        {
            await appDbContext.Approvals.ReplaceOneAsync(x => x.Id.Equals(entity.Id), entity);
            return entity;
        }

        public async Task<Approval> DeleteAsync(Approval entity)
        {
            await appDbContext.Approvals.ReplaceOneAsync(x => x.Id.Equals(entity.Id), entity);
            return entity;
        }
    }
}
