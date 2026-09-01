using System.ComponentModel.DataAnnotations;
using api_bora_trampar.src.Requests.Base;

namespace api_bora_trampar.src.Requests
{
    public class CreateReviewsRequest : RequestBase
    {
        [Required(ErrorMessage = "O ProfissionalId é obrigatório.")]
        [Display(Order = 1)]
        public string ProfissionalId { get; set; } = string.Empty;

        [Required(ErrorMessage = "A Pontuação é obrigatória.")]
        [Range(1, 5, ErrorMessage = "A pontuação deve ser entre 1 e 5.")]
        [Display(Order = 2)]
        public int Point { get; set; } = 5;

        [Display(Order = 3)]
        public string Notes { get; set; } = string.Empty;
    }
}
