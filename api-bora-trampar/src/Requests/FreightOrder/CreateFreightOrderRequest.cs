using System.ComponentModel.DataAnnotations;
using api_bora_trampar.src.Models;
using api_bora_trampar.src.Requests.Base;

namespace api_bora_trampar.src.Requests
{
    public class CreateFreightOrderRequest : RequestBase
    {
        [Required(ErrorMessage = "O endereço de origem é obrigatório.")]
        [Display(Order = 1)]
        public Address OriginAddress { get; set; } = new();

        [Required(ErrorMessage = "O endereço de destino é obrigatório.")]
        [Display(Order = 2)]
        public Address DestinationAddress { get; set; } = new();

        [Required(ErrorMessage = "O tipo de carga é obrigatório.")]
        [Display(Order = 3)]
        public string CargoType { get; set; } = string.Empty;

        [Required(ErrorMessage = "O peso estimado é obrigatório.")]
        [Range(0.1, double.MaxValue, ErrorMessage = "O peso deve ser maior que zero.")]
        [Display(Order = 4)]
        public double CargoWeight { get; set; }

        [Required(ErrorMessage = "A distância é obrigatória.")]
        [Display(Order = 5)]
        public double DistanceKm { get; set; }

        public string DurationLabel { get; set; } = string.Empty;

        [Required(ErrorMessage = "A data agendada é obrigatória.")]
        [Display(Order = 6)]
        public DateTime ScheduledDate { get; set; }

        public string VehicleType { get; set; } = string.Empty;

        [Required(ErrorMessage = "O preço é obrigatório.")]
        [Range(1, double.MaxValue, ErrorMessage = "O valor deve ser maior que zero.")]
        [Display(Order = 7)]
        public double Price { get; set; }

        public string Description { get; set; } = string.Empty;
        public string Notes { get; set; } = string.Empty;
        public string ProfessionalId { get; set; } = string.Empty;
    }
}
