using MongoDB.Bson.Serialization.Attributes;

namespace api_bora_trampar.src.Models
{
    public class Transfer : ModelBase
    {
        [BsonElement("user_id")]
        public string UserId { get; set; } = string.Empty;

        [BsonElement("amount")]
        public decimal Amount { get; set; }

        [BsonElement("pix_key_type")]
        public string PixKeyType { get; set; } = string.Empty;

        [BsonElement("pix_key")]
        public string PixKey { get; set; } = string.Empty;

        [BsonElement("status")]
        public string Status { get; set; } = "PENDING";

        [BsonElement("notes")]
        public string Notes { get; set; } = string.Empty;

        [BsonElement("asaas_id")]
        public string AsaasId { get; set; } = string.Empty;

        [BsonElement("proof")]
        public string Proof { get; set; } = string.Empty;
    }
}
