using System.ComponentModel.DataAnnotations;
using api_bora_trampar.src.Requests.Base;

namespace api_bora_trampar.src.Requests
{
    public class CreateAppointmentRequest : RequestBase
    {
        [Required(ErrorMessage = "O ProfissionalId é obrigatório.")]
        [Display(Order = 1)]
        public string ProfissionalId { get; set; } = string.Empty;

        [Required(ErrorMessage = "O CustomerId é obrigatório.")]
        [Display(Order = 2)]
        public string CustomerId { get; set; } = string.Empty;

        [Required(ErrorMessage = "A Data é obrigatória.")]
        [Display(Order = 3)]
        public DateTime Date { get; set; }

        [Required(ErrorMessage = "O Horário é obrigatório.")]
        [Display(Order = 4)]
        public string Hour { get; set; } = string.Empty;

        [Display(Order = 5)]
        public string Status { get; set; } = "PendingPayment";

        [Display(Order = 6)]
        public string ServiceNames { get; set; } = string.Empty;

        [Display(Order = 7)]
        public string CategoryName { get; set; } = string.Empty;

        [Display(Order = 8)]
        public string Address { get; set; } = string.Empty;

        [Display(Order = 9)]
        public string Description { get; set; } = string.Empty;

        [Display(Order = 10)]
        public string Notes { get; set; } = string.Empty;

        [Display(Order = 11)]
        public List<string> PhotoUrls { get; set; } = new();

        [Display(Order = 12)]
        public decimal TotalPrice { get; set; }

        [Display(Order = 13)]
        public string AsaasPaymentId { get; set; } = string.Empty;
    }
}
