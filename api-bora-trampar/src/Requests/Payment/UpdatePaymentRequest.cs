using System.ComponentModel.DataAnnotations;
using api_bora_trampar.src.Requests.Base;

namespace api_bora_trampar.src.Requests
{
    public class UpdatePaymentRequest : RequestBase
    {
        [Required(ErrorMessage = "O Id é obrigatório.")]
        [Display(Order = 1)]
        public string Id { get; set; } = string.Empty;

        [Required(ErrorMessage = "O Método de Pagamento é obrigatório.")]
        [Display(Order = 2)]
        public string MethodPayment { get; set; } = string.Empty;

        [Required(ErrorMessage = "A Data é obrigatória.")]
        [Display(Order = 3)]
        public DateTime Date { get; set; }

        [Required(ErrorMessage = "O Valor é obrigatório.")]
        [Display(Order = 4)]
        public decimal Value { get; set; }
    }
}
