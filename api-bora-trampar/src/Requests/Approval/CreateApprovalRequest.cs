using System.ComponentModel.DataAnnotations;
using api_bora_trampar.src.Requests.Base;

namespace api_bora_trampar.src.Requests
{
    public class CreateApprovalRequest : RequestBase
    {
        [Required(ErrorMessage = "O ProfissionalId é obrigatório.")]
        [Display(Order = 1)]
        public string ProfissionalId { get; set; } = string.Empty;
    }
}
