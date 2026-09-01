using System.ComponentModel.DataAnnotations;

namespace api_bora_trampar.src.Requests.Auth
{
    public class ResetPasswordRequest
    {
        [Required(ErrorMessage = "O Token/Código é obrigatório.")]
        [Display(Order = 1)]
        public string Token { get; set; } = string.Empty;

        [Required(ErrorMessage = "A Senha é obrigatória.")]
        [MinLength(6, ErrorMessage = "A senha deve conter no mínimo 6 caracteres.")]
        [Display(Order = 2)]
        public string Password { get; set; } = string.Empty;

        [Required(ErrorMessage = "A Confirmação de Senha é obrigatória.")]
        [Compare("Password", ErrorMessage = "As senhas informadas não coincidem.")]
        [Display(Order = 3)]
        public string ConfirmPassword { get; set; } = string.Empty;
    }
}
