using api_bora_trampar.src.Configuration;
using api_bora_trampar.src.Interfaces;
using api_bora_trampar.src.Models;
using MongoDB.Bson;
using MongoDB.Bson.Serialization;
using MongoDB.Driver;

namespace api_bora_trampar.src.Repositories
{
    public class ContestationRepository(AppDbContext appDbContext) : IContestationRepository
    {
        public async Task<List<dynamic>> GetAllAsync(List<BsonDocument> pipeline)
        {
            List<BsonDocument> list = await appDbContext.Contestations.Aggregate<BsonDocument>(pipeline).ToListAsync();
            return list.Select(doc => BsonSerializer.Deserialize<dynamic>(doc)).ToList();
        }

        public async Task<long> GetCountAsync(List<BsonDocument> pipeline)
        {
            List<BsonDocument> results = await appDbContext.Contestations.Aggregate<BsonDocument>(pipeline).ToListAsync();
            return results.Select(doc => BsonSerializer.Deserialize<dynamic>(doc)).Count();
        }

        public async Task<Contestation?> GetByIdAsync(string id)
        {
            return await appDbContext.Contestations.Find(x => !x.Deleted && x.Id.Equals(id)).FirstOrDefaultAsync();
        }

        public async Task<Contestation?> GetByAppointmentIdAsync(string appointmentId)
        {
            return await appDbContext.Contestations.Find(x => !x.Deleted && x.AppointmentId.Equals(appointmentId)).FirstOrDefaultAsync();
        }

        public async Task<Contestation?> CreateAsync(Contestation entity)
        {
            await appDbContext.Contestations.InsertOneAsync(entity);
            return entity;
        }

        public async Task<Contestation?> UpdateAsync(Contestation entity)
        {
            await appDbContext.Contestations.ReplaceOneAsync(x => x.Id.Equals(entity.Id), entity);
            return entity;
        }

        public async Task<Contestation> DeleteAsync(Contestation entity)
        {
            await appDbContext.Contestations.ReplaceOneAsync(x => x.Id.Equals(entity.Id), entity);
            return entity;
        }
    }
}
