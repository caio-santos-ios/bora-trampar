using MongoDB.Bson.Serialization.Attributes;

namespace api_bora_trampar.src.Models
{
    public class Payment : ModelBase
    {
        [BsonElement("appointment_id")]
        public string AppointmentId { get; set; } = string.Empty;

        [BsonElement("method_payment")]
        public string MethodPayment { get; set; } = string.Empty;

        [BsonElement("date")]
        public DateTime Date { get; set; }

        [BsonElement("value")]
        public decimal Value { get; set; }

        [BsonElement("status")]
        public string Status { get; set; } = "PENDING";

        [BsonElement("asaas_id")]
        public string AsaasId { get; set; } = string.Empty;

        [BsonElement("qr_code_image")]
        public string QrCodeImage { get; set; } = string.Empty;

        [BsonElement("qr_code_payload")]
        public string QrCodePayload { get; set; } = string.Empty;
    }
}