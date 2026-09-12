using System.ComponentModel.DataAnnotations;
using api_bora_trampar.src.Requests.Base;

namespace api_bora_trampar.src.Requests
{
    public class UpdateDailyWordRequest : RequestBase
    {
        [Required(ErrorMessage = "O Id é obrigatório.")]
        [Display(Order = 1)]
        public string Id { get; set; } = string.Empty;

        public string Title { get; set; } = "PALAVRA DO DIA";

        [Required(ErrorMessage = "O Versículo é obrigatório.")]
        [Display(Order = 2)]
        public string Verse { get; set; } = string.Empty;

        [Required(ErrorMessage = "A Referência é obrigatória.")]
        [Display(Order = 3)]
        public string Reference { get; set; } = string.Empty;

        public string Message { get; set; } = string.Empty;

        [Required(ErrorMessage = "O Público-alvo é obrigatório.")]
        [Display(Order = 4)]
        public string TargetAudience { get; set; } = "both";

        public bool IsActive { get; set; } = true;

        public DateTime StartDate { get; set; } = DateTime.UtcNow;

        public DateTime? EndDate { get; set; }
    }
}
