using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;
using api_bora_trampar.src.Requests.Base;

namespace api_bora_trampar.src.Requests
{
    public class CreateAppointmentRequest : RequestBase
    {
        [Required(ErrorMessage = "O ProfissionalId é obrigatório.")]
        [Display(Order = 1)]
        [JsonPropertyName("profissionalId")]
        public string ProfissionalId { get; set; } = string.Empty;

        [JsonPropertyName("profissional_id")]
        public string ProfissionalIdSnake
        {
            get => ProfissionalId;
            set
            {
                if (!string.IsNullOrEmpty(value)) ProfissionalId = value;
            }
        }

        [Required(ErrorMessage = "O CustomerId é obrigatório.")]
        [Display(Order = 2)]
        [JsonPropertyName("customerId")]
        public string CustomerId { get; set; } = string.Empty;

        [JsonPropertyName("customer_id")]
        public string CustomerIdSnake
        {
            get => CustomerId;
            set
            {
                if (!string.IsNullOrEmpty(value)) CustomerId = value;
            }
        }

        [Required(ErrorMessage = "A Data é obrigatória.")]
        [Display(Order = 3)]
        [JsonPropertyName("date")]
        public DateTime Date { get; set; }

        [Required(ErrorMessage = "O Horário é obrigatório.")]
        [Display(Order = 4)]
        [JsonPropertyName("hour")]
        public string Hour { get; set; } = string.Empty;

        [Display(Order = 5)]
        [JsonPropertyName("status")]
        public string Status { get; set; } = "PendingPayment";

        [Display(Order = 6)]
        [JsonPropertyName("serviceNames")]
        public string ServiceNames { get; set; } = string.Empty;

        [JsonPropertyName("service_names")]
        public string ServiceNamesSnake
        {
            get => ServiceNames;
            set
            {
                if (!string.IsNullOrEmpty(value)) ServiceNames = value;
            }
        }

        [Display(Order = 7)]
        [JsonPropertyName("categoryName")]
        public string CategoryName { get; set; } = string.Empty;

        [JsonPropertyName("category_name")]
        public string CategoryNameSnake
        {
            get => CategoryName;
            set
            {
                if (!string.IsNullOrEmpty(value)) CategoryName = value;
            }
        }

        [Display(Order = 8)]
        [JsonPropertyName("address")]
        public string Address { get; set; } = string.Empty;

        [Display(Order = 9)]
        [JsonPropertyName("description")]
        public string Description { get; set; } = string.Empty;

        [Display(Order = 10)]
        [JsonPropertyName("notes")]
        public string Notes { get; set; } = string.Empty;

        [Display(Order = 11)]
        [JsonPropertyName("photoUrls")]
        public List<string> PhotoUrls { get; set; } = new();

        [JsonPropertyName("photo_urls")]
        public List<string> PhotoUrlsSnake
        {
            get => PhotoUrls;
            set
            {
                if (value != null && value.Count > 0) PhotoUrls = value;
            }
        }

        [Display(Order = 12)]
        [JsonPropertyName("totalPrice")]
        public decimal TotalPrice { get; set; }

        [JsonPropertyName("total_price")]
        public decimal TotalPriceSnake
        {
            get => TotalPrice;
            set
            {
                if (value > 0) TotalPrice = value;
            }
        }

        [Display(Order = 13)]
        [JsonPropertyName("asaasPaymentId")]
        public string AsaasPaymentId { get; set; } = string.Empty;

        [JsonPropertyName("asaas_payment_id")]
        public string AsaasPaymentIdSnake
        {
            get => AsaasPaymentId;
            set
            {
                if (!string.IsNullOrEmpty(value)) AsaasPaymentId = value;
            }
        }
    }
}

