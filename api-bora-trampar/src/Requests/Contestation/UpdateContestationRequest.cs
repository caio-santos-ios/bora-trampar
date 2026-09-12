using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;
using api_bora_trampar.src.Requests.Base;

namespace api_bora_trampar.src.Requests
{
    public class UpdateContestationRequest : RequestBase
    {
        [Required(ErrorMessage = "O Id é obrigatório.")]
        [Display(Order = 1)]
        [JsonPropertyName("id")]
        public string Id { get; set; } = string.Empty;

        [JsonPropertyName("status")]
        public string Status { get; set; } = string.Empty;

        [JsonPropertyName("statusLabel")]
        public string StatusLabel { get; set; } = string.Empty;

        [JsonPropertyName("adminDecision")]
        public string AdminDecision { get; set; } = string.Empty;

        [JsonPropertyName("decidedBy")]
        public string DecidedBy { get; set; } = string.Empty;

        [JsonPropertyName("partialRefundPercentage")]
        public int PartialRefundPercentage { get; set; } = 50;

        [JsonPropertyName("proNotes")]
        public string ProNotes { get; set; } = string.Empty;

        [JsonPropertyName("description")]
        public string Description { get; set; } = string.Empty;

        [JsonPropertyName("customerEvidenceUrl")]
        public string CustomerEvidenceUrl { get; set; } = string.Empty;

        [JsonPropertyName("photos")]
        public List<string>? Photos { get; set; }

        [JsonPropertyName("videoUrl")]
        public string VideoUrl { get; set; } = string.Empty;
    }
}
