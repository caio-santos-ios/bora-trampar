using System.ComponentModel.DataAnnotations;
using api_bora_trampar.src.Requests.Base;

namespace api_bora_trampar.src.Requests
{
    public class UpdateApprovalRequest : RequestBase
    {
        [Required(ErrorMessage = "O Id é obrigatório.")]
        [Display(Order = 1)]
        public string Id { get; set; } = string.Empty;

        [Required(ErrorMessage = "O ProfissionalId é obrigatório.")]
        [Display(Order = 2)]
        public string ProfissionalId { get; set; } = string.Empty;
    }
}
