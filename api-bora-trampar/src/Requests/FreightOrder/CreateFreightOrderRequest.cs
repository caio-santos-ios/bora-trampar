using System.ComponentModel.DataAnnotations;
using api_bora_trampar.src.Requests.Base;

namespace api_bora_trampar.src.Requests
{
    public class CreateFreightOrderRequest : RequestBase
    {
        [Required(ErrorMessage = "O endereço de origem é obrigatório.")]
        [Display(Order = 1)]
        public string OriginAddress { get; set; } = string.Empty;

        [Required(ErrorMessage = "O endereço de destino é obrigatório.")]
        [Display(Order = 2)]
        public string DestinationAddress { get; set; } = string.Empty;

        [Required(ErrorMessage = "A descrição é obrigatória.")]
        [Display(Order = 3)]
        public string Description { get; set; } = string.Empty;

        [Required(ErrorMessage = "O tipo de veículo é obrigatório.")]
        [Display(Order = 4)]
        public string VehicleType { get; set; } = string.Empty;

        [Required(ErrorMessage = "O preço é obrigatório.")]
        [Range(1, double.MaxValue, ErrorMessage = "O valor deve ser maior que zero.")]
        [Display(Order = 5)]
        public double Price { get; set; }

        public string Notes { get; set; } = string.Empty;
        public string ProfessionalId { get; set; } = string.Empty;
    }
}
