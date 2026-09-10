using MongoDB.Bson.Serialization.Attributes;

namespace api_bora_trampar.src.Models
{
    public class Reviews : ModelBase
    {
        [BsonElement("appointment_id")]
        public string AppointmentId { get; set; } = string.Empty;

        [BsonElement("customer_id")]
        public string CustomerId { get; set; } = string.Empty;

        [BsonElement("professional_id")]
        public string ProfessionalId { get; set; } = string.Empty;
        
        [BsonElement("service_id")]
        public string ServiceId { get; set; } = string.Empty;

        [BsonElement("point")]
        public int Point { get; set; } = 0;

        [BsonElement("comment")]
        public string Comment { get; set; } = string.Empty;
    }
}