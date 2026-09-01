using MongoDB.Bson.Serialization.Attributes;

namespace api_bora_trampar.src.Models
{
    public class Approval : ModelBase
    {
        [BsonElement("profissional_id")]
        public string ProfissionalId { get; set; } = string.Empty;
    }
}