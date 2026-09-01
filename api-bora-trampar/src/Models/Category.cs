using MongoDB.Bson.Serialization.Attributes;

namespace api_bora_trampar.src.Models
{
    public class Category : ModelBase
    {
        [BsonElement("name")]
        public string Name { get; set; } = string.Empty;
        
        [BsonElement("description")]
        public string Description { get; set; } = string.Empty;

        [BsonElement("icon")]
        public string Icon { get; set; } = string.Empty;
    }
}