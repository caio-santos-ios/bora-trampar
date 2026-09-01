using api_bora_trampar.src.Enums;
using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace api_bora_trampar.src.Models
{
    public class User : ModelBase
    {
        [BsonElement("name")]
        public string Name { get; set; } = string.Empty;

        [BsonElement("email")]
        public string Email { get; set; } = string.Empty;

        [BsonElement("whatsapp")]
        public string WhatsApp { get; set; } = string.Empty;

        [BsonElement("password")]
        public string Password { get; set; } = string.Empty;

        [BsonElement("photo")]
        public string Photo { get; set; } = string.Empty;

        [BsonElement("role")]
        [BsonRepresentation(BsonType.String)]
        public RoleUserEnum Role { get; set; }

        [BsonElement("password_reset_token")]
        public string? PasswordResetToken { get; set; }

        [BsonElement("password_reset_expires")]
        public DateTime? PasswordResetExpires { get; set; }
    }
}