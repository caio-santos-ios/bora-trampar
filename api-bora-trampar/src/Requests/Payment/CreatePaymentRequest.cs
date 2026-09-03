using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;
using api_bora_trampar.src.Requests.Base;

namespace api_bora_trampar.src.Requests
{
    public class CreatePaymentRequest : RequestBase
    {
        [Required(ErrorMessage = "O Método de Pagamento é obrigatório.")]
        [Display(Order = 1)]
        [JsonPropertyName("methodPayment")]
        public string MethodPayment { get; set; } = string.Empty;

        [JsonPropertyName("method_payment")]
        public string MethodPaymentSnake
        {
            get => MethodPayment;
            set
            {
                if (!string.IsNullOrEmpty(value)) MethodPayment = value;
            }
        }

        [Required(ErrorMessage = "A Data é obrigatória.")]
        [Display(Order = 2)]
        [JsonPropertyName("date")]
        public DateTime Date { get; set; }

        [Required(ErrorMessage = "O Valor é obrigatório.")]
        [Display(Order = 3)]
        [JsonPropertyName("value")]
        public decimal Value { get; set; }

        [Display(Order = 4)]
        [JsonPropertyName("appointmentId")]
        public string AppointmentId { get; set; } = string.Empty;

        [JsonPropertyName("appointment_id")]
        public string AppointmentIdSnake
        {
            get => AppointmentId;
            set
            {
                if (!string.IsNullOrEmpty(value)) AppointmentId = value;
            }
        }

        [Display(Order = 5)]
        [JsonPropertyName("status")]
        public string Status { get; set; } = "PENDING";

        [Display(Order = 6)]
        [JsonPropertyName("asaasId")]
        public string AsaasId { get; set; } = string.Empty;

        [Display(Order = 7)]
        [JsonPropertyName("qrCodeImage")]
        public string QrCodeImage { get; set; } = string.Empty;

        [Display(Order = 8)]
        [JsonPropertyName("qrCodePayload")]
        public string QrCodePayload { get; set; } = string.Empty;
    }
}

