using MongoDB.Bson.Serialization.Attributes;

namespace api_bora_trampar.src.Models
{
    public class DailyWord : ModelBase
    {
        [BsonElement("title")]
        public string Title { get; set; } = "PALAVRA DO DIA";

        [BsonElement("verse")]
        public string Verse { get; set; } = string.Empty;

        [BsonElement("reference")]
        public string Reference { get; set; } = string.Empty;

        [BsonElement("message")]
        public string Message { get; set; } = string.Empty;

        [BsonElement("target_audience")]
        public string TargetAudience { get; set; } = "both"; // "customer", "professional", "both"

        [BsonElement("is_active")]
        public bool IsActive { get; set; } = true;

        [BsonElement("start_date")]
        public DateTime StartDate { get; set; } = DateTime.UtcNow;

        [BsonElement("end_date")]
        public DateTime? EndDate { get; set; }
    }
}
