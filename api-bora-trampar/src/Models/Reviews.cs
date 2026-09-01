using MongoDB.Bson.Serialization.Attributes;

namespace api_bora_trampar.src.Models
{
    public class Reviews : ModelBase
    {
        [BsonElement("profissional_id")]
        public string ProfissionalId { get; set; } = string.Empty;

        [BsonElement("point")]
        public int Point { get; set; } = 0;

        [BsonElement("notes")]
        public string Notes { get; set; } = string.Empty;
    }
}