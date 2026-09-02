using System.ComponentModel.DataAnnotations;
using api_bora_trampar.src.Requests.Base;

namespace api_bora_trampar.src.Requests
{
    public class CreatePaymentRequest : RequestBase
    {
        [Required(ErrorMessage = "O Método de Pagamento é obrigatório.")]
        [Display(Order = 1)]
        public string MethodPayment { get; set; } = string.Empty;

        [Required(ErrorMessage = "A Data é obrigatória.")]
        [Display(Order = 2)]
        public DateTime Date { get; set; }

        [Required(ErrorMessage = "O Valor é obrigatório.")]
        [Display(Order = 3)]
        public decimal Value { get; set; }

        [Display(Order = 4)]
        public string AppointmentId { get; set; } = string.Empty;

        [Display(Order = 5)]
        public string Status { get; set; } = "PENDING";

        [Display(Order = 6)]
        public string AsaasId { get; set; } = string.Empty;

        [Display(Order = 7)]
        public string QrCodeImage { get; set; } = string.Empty;

        [Display(Order = 8)]
        public string QrCodePayload { get; set; } = string.Empty;
    }
}
