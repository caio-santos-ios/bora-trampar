using System.ComponentModel.DataAnnotations;
using api_bora_trampar.src.Requests.Base;

namespace api_bora_trampar.src.Requests
{
    public class UpdateDocumentRequest : RequestBase
    {
        [Required(ErrorMessage = "O Id é obrigatório.")]
        [Display(Order = 1)]
        public string Id { get; set; } = string.Empty;

        [Required(ErrorMessage = "O Nome é obrigatório.")]
        [Display(Order = 2)]
        public string Name { get; set; } = string.Empty;

        [Required(ErrorMessage = "O Número é obrigatório.")]
        [Display(Order = 3)]
        public string Number { get; set; } = string.Empty;

        [Required(ErrorMessage = "A URI do arquivo é obrigatória.")]
        [Display(Order = 4)]
        public string UriFile { get; set; } = string.Empty;
    }
}
