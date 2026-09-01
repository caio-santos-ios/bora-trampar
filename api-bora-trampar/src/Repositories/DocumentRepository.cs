using api_bora_trampar.src.Configuration;
using api_bora_trampar.src.Interfaces;
using api_bora_trampar.src.Models;
using MongoDB.Bson;
using MongoDB.Bson.Serialization;
using MongoDB.Driver;

namespace api_bora_trampar.src.Repositories
{
    public class DocumentRepository(AppDbContext appDbContext) : IDocumentRepository
    {
        public async Task<List<dynamic>> GetAllAsync(List<BsonDocument> pipeline)
        {
            List<BsonDocument> list = await appDbContext.Documents.Aggregate<BsonDocument>(pipeline).ToListAsync();
            return list.Select(doc => BsonSerializer.Deserialize<dynamic>(doc)).ToList();
        }

        public async Task<Document?> GetByIdAsync(string id)
        {
            return await appDbContext.Documents.Find(x => !x.Deleted && x.Id.Equals(id)).FirstOrDefaultAsync();
        }

        public async Task<Document?> CreateAsync(Document entity)
        {
            await appDbContext.Documents.InsertOneAsync(entity);
            return entity;
        }

        public async Task<Document?> UpdateAsync(Document entity)
        {
            await appDbContext.Documents.ReplaceOneAsync(x => x.Id.Equals(entity.Id), entity);
            return entity;
        }

        public async Task<Document> DeleteAsync(Document entity)
        {
            await appDbContext.Documents.ReplaceOneAsync(x => x.Id.Equals(entity.Id), entity);
            return entity;
        }
    }
}
