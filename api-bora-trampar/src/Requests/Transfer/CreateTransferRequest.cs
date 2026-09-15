using System.ComponentModel.DataAnnotations;
using api_bora_trampar.src.Requests.Base;

namespace api_bora_trampar.src.Requests
{
    public class CreateTransferRequest : RequestBase
    {
        [Required(ErrorMessage = "O Usuário é obrigatório.")]
        [Display(Order = 1)]
        public string UserId { get; set; } = string.Empty;

        [Required(ErrorMessage = "O Valor é obrigatório.")]
        [Range(0.01, double.MaxValue, ErrorMessage = "O valor deve ser maior que zero.")]
        [Display(Order = 2)]
        public decimal Amount { get; set; }

        [Required(ErrorMessage = "O Tipo da Chave PIX é obrigatório.")]
        [Display(Order = 3)]
        public string PixKeyType { get; set; } = string.Empty;

        [Required(ErrorMessage = "A Chave PIX é obrigatória.")]
        [Display(Order = 4)]
        public string PixKey { get; set; } = string.Empty;

        public string Status { get; set; } = "PENDING";
        public string Notes { get; set; } = string.Empty;
    }
}
