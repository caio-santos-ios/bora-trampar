using System.ComponentModel.DataAnnotations;
using api_bora_trampar.src.Requests.Base;

namespace api_bora_trampar.src.Requests
{
    public class CreateApprovalRequest : RequestBase
    {
        [Required(ErrorMessage = "O ProfissionalId é obrigatório.")]
        [Display(Order = 1)]
        public string ProfissionalId { get; set; } = string.Empty;
        public string DocumentType { get; set; } = "CNH";
        public string DocumentNumber { get; set; } = string.Empty;
        public string RgFrontUrl { get; set; } = string.Empty;
        public string RgBackUrl { get; set; } = string.Empty;
        public string SelfieUrl { get; set; } = string.Empty;
        public string Status { get; set; } = "analysis";
        public bool Approved { get; set; } = false;
        public string ReviewNotes { get; set; } = string.Empty;
        public string ReviewedBy { get; set; } = string.Empty;
        public string ReviewedAt { get; set; } = string.Empty;
    }
}
