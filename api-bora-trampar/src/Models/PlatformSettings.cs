using System.Text.Json.Serialization;
using MongoDB.Bson.Serialization.Attributes;

namespace api_bora_trampar.src.Models
{
    [BsonIgnoreExtraElements]
    public class PlatformSettings : ModelBase
    {
        [BsonElement("platform_fee_percentage")]
        [JsonPropertyName("platformFeePercentage")]
        public decimal PlatformFeePercentage { get; set; } = 10;

        [BsonElement("dispute_retention_days")]
        [JsonPropertyName("disputeRetentionDays")]
        public int DisputeRetentionDays { get; set; } = 5;

        [BsonElement("require_selfie_verification")]
        [JsonPropertyName("requireSelfieVerification")]
        public bool RequireSelfieVerification { get; set; } = true;

        [BsonElement("pix_expiration_minutes")]
        [JsonPropertyName("pixExpirationMinutes")]
        public int PixExpirationMinutes { get; set; } = 30;

        [BsonElement("pix_provider")]
        [JsonPropertyName("pixProvider")]
        public string PixProvider { get; set; } = "Asaas / Gerencianet Pix";

        [BsonElement("pix_webhook_url")]
        [JsonPropertyName("pixWebhookUrl")]
        public string PixWebhookUrl { get; set; } = "https://api.boratrampar.com/api/webhooks/pix";

        [BsonElement("support_email")]
        [JsonPropertyName("supportEmail")]
        public string SupportEmail { get; set; } = "suporte@boratrampar.com";

        [BsonElement("maintenance_mode")]
        [JsonPropertyName("maintenanceMode")]
        public bool MaintenanceMode { get; set; } = false;
    }
}
