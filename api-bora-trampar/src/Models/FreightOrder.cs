using MongoDB.Bson.Serialization.Attributes;

namespace api_bora_trampar.src.Models
{
    [BsonIgnoreExtraElements]
    public class FreightOrder : ModelBase
    {
        [BsonElement("customer_id")]
        public string CustomerId { get; set; } = string.Empty;

        [BsonElement("customer_name")]
        public string CustomerName { get; set; } = string.Empty;

        [BsonElement("professional_id")]
        public string ProfessionalId { get; set; } = string.Empty;

        [BsonElement("professional_name")]
        public string ProfessionalName { get; set; } = string.Empty;

        [BsonElement("origin_address")]
        public string OriginAddress { get; set; } = string.Empty;

        [BsonElement("destination_address")]
        public string DestinationAddress { get; set; } = string.Empty;

        [BsonElement("description")]
        public string Description { get; set; } = string.Empty;

        [BsonElement("vehicle_type")]
        public string VehicleType { get; set; } = string.Empty;

        [BsonElement("price")]
        public double Price { get; set; } = 0.0;

        [BsonElement("status")]
        public string Status { get; set; } = "Pending";

        [BsonElement("notes")]
        public string Notes { get; set; } = string.Empty;
    }
}
