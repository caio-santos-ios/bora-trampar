using System.ComponentModel.DataAnnotations;
using api_bora_trampar.src.Enums;
using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace api_bora_trampar.src.Requests.Auth
{
    public class LoginRequest
    {
        [Required(ErrorMessage = "O E-mail é obrigatório.")]
        [Display(Order = 1)]
        public string Email { get; set; } = string.Empty;
        
        [Required(ErrorMessage = "A Senha é obrigatória.")]
        [Display(Order = 2)]
        public string Password { get; set; } = string.Empty;

        [BsonRepresentation(BsonType.String)]
        public RoleUserEnum Role { get; set; }
    }
}