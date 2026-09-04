using System.ComponentModel.DataAnnotations;
using api_bora_trampar.src.Requests.Base;

namespace api_bora_trampar.src.Requests
{
    public class UpdateUserRequest : RequestBase
    {
        [Required(ErrorMessage = "O Id é obrigatório.")]
        [Display(Order = 1)]
        public string Id { get; set; } = string.Empty;

        public string? Name { get; set; }
        public string? Email { get; set; }
        public string? WhatsApp { get; set; }
        public string? Photo { get; set; }
        public bool? Blocked { get; set; }
    }
}