using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;
using api_bora_trampar.src.Requests.Base;

namespace api_bora_trampar.src.Requests
{
    public class UpdateApprovalRequest : RequestBase
    {
        [Required(ErrorMessage = "O Id é obrigatório.")]
        [Display(Order = 1)]
        [JsonPropertyName("id")]
        public string Id { get; set; } = string.Empty;

        [JsonPropertyName("profissionalId")]
        public string ProfissionalId { get; set; } = string.Empty;

        [JsonPropertyName("documentType")]
        public string DocumentType { get; set; } = "CNH";

        [JsonPropertyName("documentNumber")]
        public string DocumentNumber { get; set; } = string.Empty;

        [JsonPropertyName("rgFrontUrl")]
        public string RgFrontUrl { get; set; } = string.Empty;

        [JsonPropertyName("rgBackUrl")]
        public string RgBackUrl { get; set; } = string.Empty;

        [JsonPropertyName("selfieUrl")]
        public string SelfieUrl { get; set; } = string.Empty;

        [JsonPropertyName("status")]
        public string Status { get; set; } = "analysis";

        [JsonPropertyName("approved")]
        public bool Approved { get; set; } = false;

        [JsonPropertyName("reviewNotes")]
        public string ReviewNotes { get; set; } = string.Empty;

        [JsonPropertyName("reviewedBy")]
        public string ReviewedBy { get; set; } = string.Empty;

        [JsonPropertyName("reviewedAt")]
        public string ReviewedAt { get; set; } = string.Empty;
    }
}
