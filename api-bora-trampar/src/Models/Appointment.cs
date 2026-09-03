using MongoDB.Bson.Serialization.Attributes;

namespace api_bora_trampar.src.Models
{
    public class Appointment : ModelBase
    {
        [BsonElement("profissional_id")]
        public string ProfissionalId { get; set; } = string.Empty;

        [BsonElement("customer_id")]
        public string CustomerId { get; set; } = string.Empty;

        [BsonElement("date")]
        public DateTime Date { get; set; }

        [BsonElement("hour")]
        public string Hour { get; set; } = string.Empty;

        [BsonElement("status")]
        public string Status { get; set; } = "PendingPayment";

        [BsonElement("category_id")]
        public string CategoryId { get; set; } = string.Empty;

        [BsonElement("service_id")]
        public string ServiceId { get; set; } = string.Empty;

        [BsonElement("service_names")]
        [BsonIgnoreIfNull]
        [BsonIgnoreIfDefault]
        public string? ServiceNames { get; set; }

        [BsonElement("category_name")]
        [BsonIgnoreIfNull]
        [BsonIgnoreIfDefault]
        public string? CategoryName { get; set; }

        [BsonElement("address")]
        public string Address { get; set; } = string.Empty;

        [BsonElement("description")]
        public string Description { get; set; } = string.Empty;

        [BsonElement("notes")]
        public string Notes { get; set; } = string.Empty;

        [BsonElement("photo_urls")]
        public List<string> PhotoUrls { get; set; } = new();

        [BsonElement("total_price")]
        public decimal TotalPrice { get; set; }

        [BsonElement("asaas_payment_id")]
        public string AsaasPaymentId { get; set; } = string.Empty;
    }
}