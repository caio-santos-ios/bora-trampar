using api_bora_trampar.src.Models;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;
using api_bora_trampar.src.Models.Base;
using api_bora_trampar.src.Interfaces.Auth;
using api_bora_trampar.src.Requests.Auth;


namespace api_bora_trampar.src.Services
{
    public class AuthService : IAuthService
    {
        public Task<ResponseApi<dynamic>> LoginAsync(LoginRequest request)
        {
            throw new NotImplementedException();
        }

        public Task<ResponseApi<dynamic>> RegisterAsync(RegisterRequest request)
        {
            throw new NotImplementedException();
        }

        private static string GenerateJwtToken(User user, bool refresh = false)
        {
            string? SecretKey = Environment.GetEnvironmentVariable("SECRET_KEY") ?? "";
            string? Issuer = Environment.GetEnvironmentVariable("ISSUER") ?? "";
            string? Audience = Environment.GetEnvironmentVariable("AUDIENCE") ?? "";

            SymmetricSecurityKey key = new(Encoding.UTF8.GetBytes(SecretKey));

            Claim[] claims =
            [
                new Claim(JwtRegisteredClaimNames.Sub, user.Id),
                new Claim(JwtRegisteredClaimNames.Email, user.Email),
                new Claim(ClaimTypes.Role, user.Role.ToString()),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
                new Claim("type", refresh ? "refresh" : "access"),
                new Claim("role", user.Role.ToString()),
                new Claim("name", user.Name),
                new Claim("photo", user.Photo)
            ];

            SigningCredentials creds = new(key, SecurityAlgorithms.HmacSha256);

            JwtSecurityToken token = new(
                issuer: Issuer,
                audience: Audience,
                claims: claims,
                expires: refresh ? DateTime.UtcNow.AddDays(7) : DateTime.UtcNow.AddHours(2),
                signingCredentials: creds
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }
}