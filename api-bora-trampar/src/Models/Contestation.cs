using MongoDB.Bson.Serialization.Attributes;

namespace api_bora_trampar.src.Models
{
    [BsonIgnoreExtraElements]
    public class Contestation : ModelBase
    {
        [BsonElement("appointment_id")]
        public string AppointmentId { get; set; } = string.Empty;

        [BsonElement("customer_id")]
        public string CustomerId { get; set; } = string.Empty;

        [BsonElement("professional_id")]
        public string ProfessionalId { get; set; } = string.Empty;

        [BsonElement("value")]
        public decimal Value { get; set; }

        [BsonElement("reason")]
        public string Reason { get; set; } = string.Empty;

        [BsonElement("customer_evidence_url")]
        public string CustomerEvidenceUrl { get; set; } = string.Empty;

        [BsonElement("pro_notes")]
        public string ProNotes { get; set; } = string.Empty;

        [BsonElement("status")]
        public string Status { get; set; } = "under_review";

        [BsonElement("status_label")]
        public string StatusLabel { get; set; } = "Em Análise";

        [BsonElement("admin_decision")]
        public string AdminDecision { get; set; } = string.Empty;

        [BsonElement("decided_by")]
        public string DecidedBy { get; set; } = string.Empty;

        [BsonElement("decided_at")]
        public DateTime? DecidedAt { get; set; }

        // Campos não persistidos na collection (preenchidos via lookup no GET)
        [BsonIgnore]
        public string CustomerName { get; set; } = string.Empty;

        [BsonIgnore]
        public string ProfessionalName { get; set; } = string.Empty;

        [BsonIgnore]
        public string ServiceName { get; set; } = string.Empty;
    }
}

