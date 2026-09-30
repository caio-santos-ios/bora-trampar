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

        [BsonElement("vehicle_id")]
        public string VehicleId { get; set; } = string.Empty;

        [BsonElement("origin_address")]
        public Address OriginAddress { get; set; } = new();

        [BsonElement("destination_address")]
        public Address DestinationAddress { get; set; } = new();

        [BsonElement("cargo_type")]
        public string CargoType { get; set; } = string.Empty;

        [BsonElement("cargo_weight")]
        public double CargoWeight { get; set; } = 0.0;

        [BsonElement("distance_km")]
        public double DistanceKm { get; set; } = 0.0;

        [BsonElement("duration_label")]
        public string DurationLabel { get; set; } = string.Empty;

        [BsonElement("scheduled_date")]
        public DateTime? ScheduledDate { get; set; }

        [BsonElement("vehicle_type")]
        public string VehicleType { get; set; } = string.Empty;

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
