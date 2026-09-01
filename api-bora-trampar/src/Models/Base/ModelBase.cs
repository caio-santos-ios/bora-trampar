using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace api_bora_trampar.src.Models
{
    public class ModelBase
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string Id { get; set; } = string.Empty;
        [BsonElement("deleted")]
        public bool Deleted { get; set; } = false;

        [BsonElement("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [BsonElement("created_by")]
        public string CreatedBy { get; set; } = string.Empty;

        [BsonElement("updated_at")]
        public DateTime? UpdatedAt { get; set; }

        [BsonElement("updated_by")]
        public string UpdatedBy { get; set; } = string.Empty;

        [BsonElement("deleted_at")]
        public DateTime? DeletedAt { get; set; }

        [BsonElement("deleted_by")]
        public string DeletedBy { get; set; } = string.Empty;
    }
}