using System.ComponentModel.DataAnnotations;
using api_bora_trampar.src.Requests.Base;

namespace api_bora_trampar.src.Requests
{
    public class UpdateAppointmentRequest : RequestBase
    {
        [Required(ErrorMessage = "O Id é obrigatório.")]
        [Display(Order = 1)]
        public string Id { get; set; } = string.Empty;

        [Required(ErrorMessage = "O ProfissionalId é obrigatório.")]
        [Display(Order = 2)]
        public string ProfissionalId { get; set; } = string.Empty;

        [Required(ErrorMessage = "O CustomerId é obrigatório.")]
        [Display(Order = 3)]
        public string CustomerId { get; set; } = string.Empty;

        [Required(ErrorMessage = "A Data é obrigatória.")]
        [Display(Order = 4)]
        public DateTime Date { get; set; }

        [Required(ErrorMessage = "O Horário é obrigatório.")]
        [Display(Order = 5)]
        public string Hour { get; set; } = string.Empty;
    }
}
