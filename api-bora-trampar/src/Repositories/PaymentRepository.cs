using api_bora_trampar.src.Configuration;
using api_bora_trampar.src.Interfaces;
using api_bora_trampar.src.Models;
using MongoDB.Bson;
using MongoDB.Bson.Serialization;
using MongoDB.Driver;

namespace api_bora_trampar.src.Repositories
{
    public class PaymentRepository(AppDbContext appDbContext) : IPaymentRepository
    {
        public async Task<List<dynamic>> GetAllAsync(List<BsonDocument> pipeline)
        {
            List<BsonDocument> list = await appDbContext.Payments.Aggregate<BsonDocument>(pipeline).ToListAsync();
            return list.Select(doc => BsonSerializer.Deserialize<dynamic>(doc)).ToList();
        }

        public async Task<Payment?> GetByIdAsync(string id)
        {
            return await appDbContext.Payments.Find(x => !x.Deleted && x.Id.Equals(id)).FirstOrDefaultAsync();
        }

        public async Task<Payment?> CreateAsync(Payment entity)
        {
            await appDbContext.Payments.InsertOneAsync(entity);
            return entity;
        }

        public async Task<Payment?> UpdateAsync(Payment entity)
        {
            await appDbContext.Payments.ReplaceOneAsync(x => x.Id.Equals(entity.Id), entity);
            return entity;
        }

        public async Task<Payment> DeleteAsync(Payment entity)
        {
            await appDbContext.Payments.ReplaceOneAsync(x => x.Id.Equals(entity.Id), entity);
            return entity;
        }
    }
}
