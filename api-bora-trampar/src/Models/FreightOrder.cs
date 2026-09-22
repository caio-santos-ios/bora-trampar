using MongoDB.Bson.Serialization.Attributes;

namespace api_bora_trampar.src.Models
{
    [BsonIgnoreExtraElements]
    public class FreightOrder : ModelBase
    {
        [BsonElement("customer_id")]
        public string CustomerId { get; set; } = string.Empty;

        [BsonElement("professional_id")]
        public string ProfessionalId { get; set; } = string.Empty;

        [BsonElement("vehicle_id")]
        public string VehicleId { get; set; } = string.Empty;
        
        [BsonElement("origin_address")]
        public Address OriginAddress { get; set; } = new();

        [BsonElement("destination_address")]
        public Address DestinationAddress { get; set; } = new();

        [BsonElement("description")]
        public string Description { get; set; } = string.Empty;

        [BsonElement("price")]
        public double Price { get; set; } = 0.0;

        [BsonElement("status")]
        public string Status { get; set; } = "Pending";

        [BsonElement("notes")]
        public string Notes { get; set; } = string.Empty;
    }
}
