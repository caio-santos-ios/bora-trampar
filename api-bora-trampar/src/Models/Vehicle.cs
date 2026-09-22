using MongoDB.Bson.Serialization.Attributes;

namespace api_bora_trampar.src.Models
{
    public class Vehicle : ModelBase
    {
        [BsonElement("professional_id")]
        public string ProfessionalId { get; set; } = string.Empty;

        [BsonElement("vehicle_type")]
        public string VehicleType { get; set; } = string.Empty;

        [BsonElement("brand")]
        public string Brand { get; set; } = string.Empty;

        [BsonElement("model")]
        public string Model { get; set; } = string.Empty;

        [BsonElement("year")]
        public int Year { get; set; } = 0;

        [BsonElement("plate_number")]
        public string PlateNumber { get; set; } = string.Empty;

        [BsonElement("approximate_capacity_kg")]
        public double ApproximateCapacityKg { get; set; } = 0.0;

        [BsonElement("dimensions")]
        public string Dimensions { get; set; } = string.Empty;

        [BsonElement("photo_url")]
        public string PhotoUrl { get; set; } = string.Empty;

        [BsonElement("document_url")]
        public string DocumentUrl { get; set; } = string.Empty;

        [BsonElement("is_default")]
        public bool IsDefault { get; set; } = false;

        [BsonElement("is_active")]
        public bool IsActive { get; set; } = true;

        [BsonElement("approval_status")]
        public string ApprovalStatus { get; set; } = "Pending";

        [BsonElement("approval_notes")]
        public string ApprovalNotes { get; set; } = string.Empty;
    }
}