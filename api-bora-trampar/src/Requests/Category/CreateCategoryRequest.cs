using System.ComponentModel.DataAnnotations;
using api_bora_trampar.src.Requests.Base;

namespace api_bora_trampar.src.Requests
{
    public class CreateCategoryRequest : RequestBase
    {
        [Required(ErrorMessage = "O Nome é obrigatório.")]
        [Display(Order = 1)]
        public string Name { get; set; } = string.Empty;

        [Required(ErrorMessage = "O Icone é obrigatório.")]
        [Display(Order = 2)]
        public string Icon { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
    }
}