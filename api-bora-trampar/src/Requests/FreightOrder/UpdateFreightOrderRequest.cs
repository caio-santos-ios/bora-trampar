using System.ComponentModel.DataAnnotations;
using api_bora_trampar.src.Models;
using api_bora_trampar.src.Requests.Base;

namespace api_bora_trampar.src.Requests
{
    public class UpdateFreightOrderRequest : RequestBase
    {
        [Required(ErrorMessage = "O Id é obrigatório.")]
        [Display(Order = 1)]
        public string Id { get; set; } = string.Empty;

        public Address OriginAddress { get; set; } = new();
        public Address DestinationAddress { get; set; } = new();
        public string Description { get; set; } = string.Empty;
        public string VehicleType { get; set; } = string.Empty;
        public double Price { get; set; }
        public string Status { get; set; } = string.Empty;
        public string ProfessionalId { get; set; } = string.Empty;
        public string Notes { get; set; } = string.Empty;
    }
}
