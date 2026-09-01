using MongoDB.Bson.Serialization.Attributes;

namespace api_bora_trampar.src.Models
{
    public class Appointment : ModelBase
    {
        [BsonElement("profissional_id")]
        public string ProfissionalId { get; set; } = string.Empty;

        [BsonElement("customer_id")]
        public string CustomerId { get; set; } = string.Empty;

        [BsonElement("date")]
        public DateTime Date { get; set; }

        [BsonElement("hour")]
        public string Hour { get; set; } = string.Empty;
    }
}