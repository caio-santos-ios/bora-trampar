using System.ComponentModel.DataAnnotations;
using api_bora_trampar.src.Requests.Base;

namespace api_bora_trampar.src.Requests
{
    public class CreateReviewsRequest : RequestBase
    {
        [Required(ErrorMessage = "O ProfessionalId é obrigatório.")]
        [Display(Order = 1)]
        public string ProfessionalId { get; set; } = string.Empty;

        [Required(ErrorMessage = "O CustomerId é obrigatório.")]
        [Display(Order = 2)]
        public string CustomerId { get; set; } = string.Empty;

        [Required(ErrorMessage = "O ServiceId é obrigatório.")]
        [Display(Order = 3)]
        public string ServiceId { get; set; } = string.Empty;

        [Required(ErrorMessage = "A Pontuação é obrigatória.")]
        [Range(1, 5, ErrorMessage = "A pontuação deve ser entre 1 e 5.")]
        [Display(Order = 4)]
        public int Point { get; set; } = 5;

        [Display(Order = 5)]
        public string Comment { get; set; } = string.Empty;

        [Required(ErrorMessage = "O AppointmentId é obrigatório.")]
        [Display(Order = 7)]
        public string AppointmentId { get; set; } = string.Empty;

    }
}
