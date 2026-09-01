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
    public class AuthService(IAuthRepository authRepository) : IAuthService
    {
        public async Task<ResponseApi<dynamic>> LoginAsync(LoginRequest request)
        {
            try
            {
                User? user = await authRepository.GetByEmailAsync(request.Email);
                if (user is null)
                {
                    return new(null, 401, "E-mail ou senha inválidos.");
                }

                bool isPasswordValid = BCrypt.Net.BCrypt.Verify(request.Password, user.Password);
                if (!isPasswordValid)
                {
                    return new(null, 401, "E-mail ou senha inválidos.");
                }

                string token = GenerateJwtToken(user);
                string refreshToken = GenerateJwtToken(user, true);

                dynamic result = new
                {
                    token,
                    refreshToken,
                    user = new
                    {
                        id = user.Id,
                        name = user.Name,
                        email = user.Email,
                        role = user.Role.ToString(),
                        photo = user.Photo,
                        whatsapp = user.WhatsApp
                    }
                };

                return new(result, 200, "Login realizado com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }

        public async Task<ResponseApi<dynamic>> RegisterAsync(RegisterRequest request)
        {
            try
            {
                User user = new()
                {
                    Name = request.Name,
                    Email = request.Email,
                    WhatsApp = request.WhatsApp,
                    Password = BCrypt.Net.BCrypt.HashPassword(request.Password),
                    Role = request.Role,
                    CreatedAt = DateTime.UtcNow
                };

                User? createdUserRes = await authRepository.RegisterAsync(user);

                return new(null, 201, "Conta criada com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }

        private static string GenerateJwtToken(User user, bool refresh = false)
        {
            string secretKey = Environment.GetEnvironmentVariable("JWT_KEY") ?? "";
            string issuer = Environment.GetEnvironmentVariable("JWT_ISSUER") ?? "";
            string audience = Environment.GetEnvironmentVariable("JWT_AUDIENCE") ?? "";

            SymmetricSecurityKey key = new(Encoding.UTF8.GetBytes(secretKey));

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
                issuer: issuer,
                audience: audience,
                claims: claims,
                expires: refresh ? DateTime.UtcNow.AddDays(7) : DateTime.UtcNow.AddHours(2),
                signingCredentials: creds
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }
}