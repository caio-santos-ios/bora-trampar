using api_bora_trampar.src.Configuration;
using api_bora_trampar.src.Interfaces;
using api_bora_trampar.src.Models;
using MongoDB.Bson;
using MongoDB.Bson.Serialization;
using MongoDB.Driver;

namespace api_bora_trampar.src.Repositories
{
    public class TransferRepository(AppDbContext appDbContext) : ITransferRepository
    {
        public async Task<List<dynamic>> GetAllAsync(List<BsonDocument> pipeline)
        {
            List<BsonDocument> results = await appDbContext.Transfers.Aggregate<BsonDocument>(pipeline).ToListAsync();
            return results.Select(doc => BsonSerializer.Deserialize<dynamic>(doc)).ToList();
        }

        public async Task<long> GetCountAsync(List<BsonDocument> pipeline)
        {
            List<BsonDocument> results = await appDbContext.Transfers.Aggregate<BsonDocument>(pipeline).ToListAsync();
            return results.Select(doc => BsonSerializer.Deserialize<dynamic>(doc)).Count();
        }

        public async Task<Transfer?> GetByIdAsync(string id)
        {
            return await appDbContext.Transfers.Find(x => !x.Deleted && x.Id.Equals(id)).FirstOrDefaultAsync();
        }
        public async Task<Transfer?> GetByAsaasIdAsync(string asaasId)
        {
            return await appDbContext.Transfers.Find(x => !x.Deleted && x.AsaasId.Equals(asaasId)).FirstOrDefaultAsync();
        }

        public async Task<Transfer?> CreateAsync(Transfer entity)
        {
            await appDbContext.Transfers.InsertOneAsync(entity);
            return entity;
        }

        public async Task<Transfer?> UpdateAsync(Transfer entity)
        {
            await appDbContext.Transfers.ReplaceOneAsync(x => x.Id.Equals(entity.Id), entity);
            return entity;
        }

        public async Task<Transfer> DeleteAsync(Transfer entity)
        {
            await appDbContext.Transfers.ReplaceOneAsync(x => x.Id.Equals(entity.Id), entity);
            return entity;
        }
    }
}
