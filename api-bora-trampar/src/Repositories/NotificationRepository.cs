using api_bora_trampar.src.Configuration;
using api_bora_trampar.src.Interfaces;
using api_bora_trampar.src.Models;
using MongoDB.Bson;
using MongoDB.Bson.Serialization;
using MongoDB.Driver;

namespace api_bora_trampar.src.Repositories
{
    public class NotificationRepository(AppDbContext appDbContext) : INotificationRepository
    {
        public async Task<List<dynamic>> GetAllByUserIdAsync(string userId)
        {
            List<BsonDocument> pipeline =
            [
                new("$match", new BsonDocument
                {
                    { "deleted", false },
                    { "user_id", userId }
                }),
                new("$project", new BsonDocument
                {
                    { "_id", 0 },
                    { "id", new BsonDocument("$toString", "$_id") },
                    { "userId", "$user_id" },
                    { "title", 1 },
                    { "message", 1 },
                    { "subtitle", new BsonDocument("$ifNull", new BsonArray { "$subtitle", "$message" }) },
                    { "appointmentId", new BsonDocument("$ifNull", new BsonArray { "$appointment_id", "" }) },
                    { "appointment_id", new BsonDocument("$ifNull", new BsonArray { "$appointment_id", "" }) },
                    { "type", 1 },
                    { "read", 1 },
                    { "send", 1 },
                    { "sendAt", 1 },
                    { "createdAt", "$created_at" }
                }),
                new("$sort", new BsonDocument { { "createdAt", -1 } })
            ];

            List<BsonDocument> results = await appDbContext.Notifications.Aggregate<BsonDocument>(pipeline).ToListAsync();
            return results.Select(doc => BsonSerializer.Deserialize<dynamic>(doc)).ToList();
        }

 public async Task<Notification?> GetByIdAsync(string id)
 {
 return await appDbContext.Notifications.Find(x => !x.Deleted && x.Id.Equals(id)).FirstOrDefaultAsync();
 }

 public async Task<Notification> CreateAsync(Notification entity)
 {
 await appDbContext.Notifications.InsertOneAsync(entity);
 return entity;
 }

 public async Task<List<Notification>> CreateManyAsync(List<Notification> entities)
 {
 if (entities.Count > 0)
 {
 await appDbContext.Notifications.InsertManyAsync(entities);
 }
 return entities;
 }

 public async Task<Notification> UpdateAsync(Notification entity)
 {
 await appDbContext.Notifications.ReplaceOneAsync(x => x.Id.Equals(entity.Id), entity);
 return entity;
 }

 public async Task<Notification> DeleteAsync(Notification entity)
 {
 await appDbContext.Notifications.ReplaceOneAsync(x => x.Id.Equals(entity.Id), entity);
 return entity;
 }
 }
}
