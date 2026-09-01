using MongoDB.Bson.Serialization.Attributes;

namespace api_bora_trampar.src.Models
{
    public class Payment : ModelBase
    {
        [BsonElement("method_payment")]
        public string MethodPayment { get; set; } = string.Empty;

        [BsonElement("date")]
        public DateTime Date { get; set; }

        [BsonElement("value")]
        public decimal Value { get; set; }
    }
}