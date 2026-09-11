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
            var list = await appDbContext.Contestations
                .Find(x => !x.Deleted)
                .SortByDescending(x => x.CreatedAt)
                .ToListAsync();

            return list.Select(c => (dynamic)new
            {
                id = c.Id,
                appointmentId = c.AppointmentId,
                customerId = c.CustomerId,
                customerName = c.CustomerName,
                professionalId = c.ProfessionalId,
                professionalName = c.ProfessionalName,
                serviceName = c.ServiceName,
                totalValue = c.Value,
                value = c.Value,
                reason = c.Reason,
                description = c.Description,
                customerEvidenceUrl = c.CustomerEvidenceUrl,
                proNotes = c.ProNotes,
                status = c.Status,
                statusLabel = c.StatusLabel,
                adminDecision = c.AdminDecision,
                decidedBy = c.DecidedBy,
                decidedAt = c.DecidedAt,
                createdAt = c.CreatedAt,
                openedAt = c.CreatedAt
            }).ToList();
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
