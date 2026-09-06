using api_bora_trampar.src.Models.Enums;
using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace api_bora_trampar.src.Models
{
    [BsonIgnoreExtraElements]
    public class Notification : ModelBase
    {
        [BsonElement("type")]
        [BsonRepresentation(BsonType.String)]
        public NotificationTypeEnum Type { get; set; } = NotificationTypeEnum.General;

        [BsonElement("title")]
        public string Title { get; set; } = string.Empty;

        [BsonElement("message")]
        public string Message { get; set; } = string.Empty;

        [BsonElement("subtitle")]
        [BsonIgnoreIfNull]
        public string? Subtitle { get; set; }

        [BsonElement("appointment_id")]
        [BsonIgnoreIfNull]
        public string? AppointmentId { get; set; }

        [BsonElement("user_id")]
        public string UserId { get; set; } = string.Empty;

        [BsonElement("read")]
        public bool Read { get; set; } = false;

        [BsonElement("send")]
        public bool Send { get; set; } = false;

        [BsonElement("sendAt")]
        [BsonDateTimeOptions(Kind = DateTimeKind.Utc)]
        public DateTime SendAt { get; set; } = DateTime.UtcNow;
    }
}
