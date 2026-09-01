using System.ComponentModel.DataAnnotations;

namespace api_bora_trampar.src.Requests.Auth
{
    public class RefreshTokenRequest
    {
        [Required(ErrorMessage = "O RefreshToken é obrigatório.")]
        [Display(Order = 1)]
        public string RefreshToken { get; set; } = string.Empty;
    }
}
