using api_bora_trampar.src.Configuration;
using api_bora_trampar.src.Interfaces;
using MongoDB.Bson;
using MongoDB.Driver;
using ServiceModel = api_bora_trampar.src.Models.Services;

namespace api_bora_trampar.src.Repositories
{
    public class ServicesRepository(AppDbContext appDbContext) : IServicesRepository
    {
        public async Task<List<dynamic>> GetAllAsync(List<BsonDocument> pipeline)
        {
            var list = await appDbContext.Services
                .Find(x => !x.Deleted)
                .SortByDescending(x => x.CreatedAt)
                .ToListAsync();

            return list.Select(s => (dynamic)new
            {
                id = s.Id,
                name = s.Name,
                categoryId = s.CategoryId,
                icon = s.Icon,
                createdAt = s.CreatedAt
            }).ToList();
        }

        public async Task<ServiceModel?> GetByIdAsync(string id)
        {
            return await appDbContext.Services.Find(x => !x.Deleted && x.Id.Equals(id)).FirstOrDefaultAsync();
        }

        public async Task<ServiceModel?> CreateAsync(ServiceModel entity)
        {
            await appDbContext.Services.InsertOneAsync(entity);
            return entity;
        }

        public async Task<ServiceModel?> UpdateAsync(ServiceModel entity)
        {
            await appDbContext.Services.ReplaceOneAsync(x => x.Id.Equals(entity.Id), entity);
            return entity;
        }

        public async Task<ServiceModel> DeleteAsync(ServiceModel entity)
        {
            await appDbContext.Services.ReplaceOneAsync(x => x.Id.Equals(entity.Id), entity);
            return entity;
        }
    }
}
