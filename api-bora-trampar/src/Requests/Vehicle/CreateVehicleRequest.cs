using System.ComponentModel.DataAnnotations;
using api_bora_trampar.src.Requests.Base;

namespace api_bora_trampar.src.Requests
{
    public class CreateVehicleRequest : RequestBase
    {
        [Required(ErrorMessage = "O tipo de veículo é obrigatório.")]
        [Display(Order = 1)]
        public string VehicleType { get; set; } = string.Empty;

        [Required(ErrorMessage = "A marca é obrigatória.")]
        [Display(Order = 2)]
        public string Brand { get; set; } = string.Empty;

        [Required(ErrorMessage = "O modelo é obrigatório.")]
        [Display(Order = 3)]
        public string Model { get; set; } = string.Empty;

        [Required(ErrorMessage = "O ano é obrigatório.")]
        [Range(1950, 2100, ErrorMessage = "Informe um ano válido.")]
        [Display(Order = 4)]
        public int Year { get; set; }

        [Required(ErrorMessage = "A placa é obrigatória.")]
        [Display(Order = 5)]
        public string PlateNumber { get; set; } = string.Empty;

        public double ApproximateCapacityKg { get; set; } = 0.0;
        public string Dimensions { get; set; } = string.Empty;
        public string PhotoUrl { get; set; } = string.Empty;
        public string DocumentUrl { get; set; } = string.Empty;
        public bool IsDefault { get; set; } = false;
    }
}