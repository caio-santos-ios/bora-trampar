using api_bora_trampar.src.Configuration;
using api_bora_trampar.src.Interfaces;
using api_bora_trampar.src.Models;
using MongoDB.Bson;
using MongoDB.Bson.Serialization;
using MongoDB.Driver;

namespace api_bora_trampar.src.Repositories
{
    public class VehicleRepository(AppDbContext context) : IVehicleRepository
    {
        public async Task<List<dynamic>> GetAllAsync(List<BsonDocument> pipeline)
        {
            var list = await context.Vehicles
                .Find(x => !x.Deleted)
                .SortByDescending(x => x.CreatedAt)
                .ToListAsync();

            return list.Select(c => (dynamic)new
            {
                id = c.Id,
                professionalId = c.ProfessionalId,
                vehicleType = c.VehicleType,
                brand = c.Brand,
                model = c.Model,
                year = c.Year,
                plateNumber = c.PlateNumber,
                approximateCapacityKg = c.ApproximateCapacityKg,
                dimensions = c.Dimensions,
                photoUrl = c.PhotoUrl,
                documentUrl = c.DocumentUrl,
                isDefault = c.IsDefault,
                isActive = c.IsActive,
                approvalStatus = c.ApprovalStatus,
                approvalNotes = c.ApprovalNotes,
                createdAt = c.CreatedAt
            }).ToList();
        }

        public async Task<long> GetCountAsync(List<BsonDocument> pipeline)
        {
            List<BsonDocument> results = await context.Vehicles.Aggregate<BsonDocument>(pipeline).ToListAsync();
            return results.Select(doc => BsonSerializer.Deserialize<dynamic>(doc)).Count();
        }

        public async Task<Vehicle?> GetByIdAsync(string id)
        {
            return await context.Vehicles.Find(x => !x.Deleted && x.Id.Equals(id)).FirstOrDefaultAsync();
        }

        public async Task<List<Vehicle>> GetByProfessionalIdAsync(string professionalId)
        {
            return await context.Vehicles
                .Find(x => !x.Deleted && x.ProfessionalId == professionalId)
                .SortByDescending(x => x.CreatedAt)
                .ToListAsync();
        }

        public async Task<Vehicle?> CreateAsync(Vehicle entity)
        {
            await context.Vehicles.InsertOneAsync(entity);
            return entity;
        }

        public async Task<Vehicle?> UpdateAsync(Vehicle entity)
        {
            await context.Vehicles.ReplaceOneAsync(x => x.Id.Equals(entity.Id), entity);
            return entity;
        }

        public async Task<Vehicle> DeleteAsync(Vehicle entity)
        {
            await context.Vehicles.ReplaceOneAsync(x => x.Id.Equals(entity.Id), entity);
            return entity;
        }
    }
}