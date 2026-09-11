using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;
using api_bora_trampar.src.Requests.Base;

namespace api_bora_trampar.src.Requests
{
    public class CreateContestationRequest : RequestBase
    {
        [Required(ErrorMessage = "O AppointmentId é obrigatório.")]
        [Display(Order = 1)]
        [JsonPropertyName("appointmentId")]
        public string AppointmentId { get; set; } = string.Empty;

        [Required(ErrorMessage = "O Motivo é obrigatório.")]
        [Display(Order = 2)]
        [JsonPropertyName("reason")]
        public string Reason { get; set; } = string.Empty;

        [JsonPropertyName("description")]
        public string Description { get; set; } = string.Empty;

        [JsonPropertyName("customerEvidenceUrl")]
        public string CustomerEvidenceUrl { get; set; } = string.Empty;

        [JsonPropertyName("customerId")]
        public string CustomerId { get; set; } = string.Empty;

        [JsonPropertyName("professionalId")]
        public string ProfessionalId { get; set; } = string.Empty;

        [JsonPropertyName("value")]
        public decimal Value { get; set; }
    }
}
