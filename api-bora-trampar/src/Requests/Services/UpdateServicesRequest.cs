using System.ComponentModel.DataAnnotations;
using api_bora_trampar.src.Requests.Base;

namespace api_bora_trampar.src.Requests
{
    public class UpdateServicesRequest : RequestBase
    {
        [Required(ErrorMessage = "O Id é obrigatório.")]
        [Display(Order = 1)]
        public string Id { get; set; } = string.Empty;

        [Required(ErrorMessage = "O Nome é obrigatório.")]
        [Display(Order = 2)]
        public string Name { get; set; } = string.Empty;

        [Required(ErrorMessage = "O CategoryId é obrigatório.")]
        [Display(Order = 3)]
        public string CategoryId { get; set; } = string.Empty;

        [Required(ErrorMessage = "O Icone é obrigatório.")]
        [Display(Order = 4)]
        public string Icon { get; set; } = string.Empty;
    }
}
