using api_bora_trampar.src.Configuration;
using api_bora_trampar.src.Interfaces;
using api_bora_trampar.src.Models;
using MongoDB.Bson;
using MongoDB.Bson.Serialization;
using MongoDB.Driver;

namespace api_bora_trampar.src.Repositories
{
    public class FreightOrderRepository(AppDbContext appDbContext) : IFreightOrderRepository
    {
        public async Task<List<dynamic>> GetAllAsync(List<BsonDocument> pipeline)
        {
            var list = await appDbContext.FreightOrders
                .Find(x => !x.Deleted)
                .SortByDescending(x => x.CreatedAt)
                .ToListAsync();

            return list.Select(c => (dynamic)new
            {
                id = c.Id,
                customerId = c.CustomerId,
                customerName = c.CustomerName,
                professionalId = c.ProfessionalId,
                professionalName = c.ProfessionalName,
                originAddress = c.OriginAddress,
                destinationAddress = c.DestinationAddress,
                description = c.Description,
                vehicleType = c.VehicleType,
                price = c.Price,
                status = c.Status,
                notes = c.Notes,
                createdAt = c.CreatedAt
            }).ToList();
        }

        public async Task<long> GetCountAsync(List<BsonDocument> pipeline)
        {
            List<BsonDocument> results = await appDbContext.FreightOrders.Aggregate<BsonDocument>(pipeline).ToListAsync();
            return results.Select(doc => BsonSerializer.Deserialize<dynamic>(doc)).Count();
        }

        public async Task<FreightOrder?> GetByIdAsync(string id)
        {
            return await appDbContext.FreightOrders.Find(x => !x.Deleted && x.Id.Equals(id)).FirstOrDefaultAsync();
        }

        public async Task<FreightOrder?> CreateAsync(FreightOrder entity)
        {
            await appDbContext.FreightOrders.InsertOneAsync(entity);
            return entity;
        }

        public async Task<FreightOrder?> UpdateAsync(FreightOrder entity)
        {
            await appDbContext.FreightOrders.ReplaceOneAsync(x => x.Id.Equals(entity.Id), entity);
            return entity;
        }

        public async Task<FreightOrder> DeleteAsync(FreightOrder entity)
        {
            await appDbContext.FreightOrders.ReplaceOneAsync(x => x.Id.Equals(entity.Id), entity);
            return entity;
        }
    }
}
