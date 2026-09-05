using System.Text.Json.Serialization;

namespace api_bora_trampar.src.Requests
{
    public class UpdateSettingsRequest
    {
        [JsonPropertyName("platformFeePercentage")]
        public decimal PlatformFeePercentage { get; set; } = 10;

        [JsonPropertyName("disputeRetentionDays")]
        public int DisputeRetentionDays { get; set; } = 5;

        [JsonPropertyName("requireSelfieVerification")]
        public bool RequireSelfieVerification { get; set; } = true;

        [JsonPropertyName("pixExpirationMinutes")]
        public int PixExpirationMinutes { get; set; } = 30;

        [JsonPropertyName("pixProvider")]
        public string PixProvider { get; set; } = "Asaas / Gerencianet Pix";

        [JsonPropertyName("pixWebhookUrl")]
        public string PixWebhookUrl { get; set; } = "https://api.boratrampar.com/api/webhooks/pix";

        [JsonPropertyName("supportEmail")]
        public string SupportEmail { get; set; } = "suporte@boratrampar.com";

        [JsonPropertyName("maintenanceMode")]
        public bool MaintenanceMode { get; set; } = false;
    }
}
