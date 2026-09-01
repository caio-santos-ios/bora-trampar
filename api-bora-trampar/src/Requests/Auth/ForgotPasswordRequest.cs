using System.ComponentModel.DataAnnotations;

namespace api_bora_trampar.src.Requests.Auth
{
    public class ForgotPasswordRequest
    {
        [Required(ErrorMessage = "O E-mail é obrigatório.")]
        [EmailAddress(ErrorMessage = "Informe um e-mail válido.")]
        [Display(Order = 1)]
        public string Email { get; set; } = string.Empty;
    }
}
