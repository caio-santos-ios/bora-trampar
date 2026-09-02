using MongoDB.Bson.Serialization.Attributes;

namespace api_bora_trampar.src.Models
{
    public class Approval : ModelBase
    {
        [BsonElement("profissional_id")]
        public string ProfissionalId { get; set; } = string.Empty;

        [BsonElement("document_type")]
        public string DocumentType { get; set; } = "CNH";

        [BsonElement("document_number")]
        public string DocumentNumber { get; set; } = string.Empty;

        [BsonElement("rg_front_url")]
        public string RgFrontUrl { get; set; } = string.Empty;

        [BsonElement("rg_back_url")]
        public string RgBackUrl { get; set; } = string.Empty;

        [BsonElement("selfie_url")]
        public string SelfieUrl { get; set; } = string.Empty;

        [BsonElement("status")]
        public string Status { get; set; } = "analysis";

        [BsonElement("approved")]
        public bool Approved { get; set; } = false;

        [BsonElement("review_notes")]
        public string ReviewNotes { get; set; } = string.Empty;

        [BsonElement("reviewed_by")]
        public string ReviewedBy { get; set; } = string.Empty;

        [BsonElement("reviewed_at")]
        public string ReviewedAt { get; set; } = string.Empty;
    }
}