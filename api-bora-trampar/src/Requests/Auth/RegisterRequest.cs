using System.ComponentModel.DataAnnotations;
using api_bora_trampar.src.Enums;
using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace api_bora_trampar.src.Requests.Auth
{
    public class RegisterRequest
    {
        [Required(ErrorMessage = "O Nome é obrigatório.")]
        [Display(Order = 1)]
        public string Name { get; set; } = string.Empty;
        
        [Required(ErrorMessage = "O E-mail é obrigatório.")]
        [Display(Order = 2)]
        public string Email { get; set; } = string.Empty;
        public string WhatsApp { get; set; } = string.Empty;
        
        [Required(ErrorMessage = "A Senha é obrigatória.")]
        [Display(Order = 3)]
        public string Password { get; set; } = string.Empty;

        [BsonRepresentation(BsonType.String)]
        public RoleUserEnum Role { get; set; }
    }
}