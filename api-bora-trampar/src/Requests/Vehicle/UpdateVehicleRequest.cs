using System.ComponentModel.DataAnnotations;
using api_bora_trampar.src.Requests.Base;

namespace api_bora_trampar.src.Requests
{
    public class UpdateVehicleRequest : RequestBase
    {
        [Required(ErrorMessage = "O Id é obrigatório.")]
        [Display(Order = 1)]
        public string Id { get; set; } = string.Empty;

        public string VehicleType { get; set; } = string.Empty;
        public string Brand { get; set; } = string.Empty;
        public string Model { get; set; } = string.Empty;
        public int Year { get; set; }
        public string PlateNumber { get; set; } = string.Empty;
        public double ApproximateCapacityKg { get; set; } = 0.0;
        public string Dimensions { get; set; } = string.Empty;
        public string PhotoUrl { get; set; } = string.Empty;
        public string DocumentUrl { get; set; } = string.Empty;
        public bool IsDefault { get; set; } = false;
        public bool? IsActive { get; set; }
        public string ApprovalStatus { get; set; } = string.Empty;
        public string ApprovalNotes { get; set; } = string.Empty;
    }
}