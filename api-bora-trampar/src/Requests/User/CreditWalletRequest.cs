using System.Text.Json.Serialization;

namespace api_bora_trampar.src.Requests
{
    public class CreditWalletRequest
    {
        [JsonPropertyName("userId")]
        public string UserId { get; set; } = string.Empty;

        [JsonPropertyName("amount")]
        public decimal Amount { get; set; }

        [JsonPropertyName("reason")]
        public string Reason { get; set; } = string.Empty;
    }
}
