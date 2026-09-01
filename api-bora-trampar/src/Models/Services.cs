using MongoDB.Bson.Serialization.Attributes;

namespace api_bora_trampar.src.Models
{
    public class Services : ModelBase
    {
        [BsonElement("name")]
        public string Name { get; set; } = string.Empty;
        
        [BsonElement("categoryId")]
        public string CategoryId { get; set; } = string.Empty;

        [BsonElement("icon")]
        public string Icon { get; set; } = string.Empty;
    }
}