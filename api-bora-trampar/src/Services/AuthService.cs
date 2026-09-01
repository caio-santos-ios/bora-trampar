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

        public async Task<ResponseApi<dynamic>> RefreshTokenAsync(RefreshTokenRequest request)
        {
            try
            {
                string secretKey = Environment.GetEnvironmentVariable("JWT_KEY") ?? "";
                string issuer = Environment.GetEnvironmentVariable("JWT_ISSUER") ?? "";
                string audience = Environment.GetEnvironmentVariable("JWT_AUDIENCE") ?? "";

                TokenValidationParameters validationParameters = new()
                {
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey)),
                    ValidateIssuer = !string.IsNullOrEmpty(issuer),
                    ValidIssuer = issuer,
                    ValidateAudience = !string.IsNullOrEmpty(audience),
                    ValidAudience = audience,
                    ValidateLifetime = true,
                    ClockSkew = TimeSpan.Zero
                };

                JwtSecurityTokenHandler tokenHandler = new();
                ClaimsPrincipal principal;
                try
                {
                    principal = tokenHandler.ValidateToken(request.RefreshToken, validationParameters, out _);
                }
                catch
                {
                    return new(null, 401, "Refresh token inválido ou expirado.");
                }

                string? tokenType = principal.FindFirst("type")?.Value;
                if (tokenType != "refresh")
                {
                    return new(null, 401, "Token informado não é um refresh token válido.");
                }

                string? userId = principal.FindFirst(JwtRegisteredClaimNames.Sub)?.Value 
                    ?? principal.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(userId))
                {
                    return new(null, 401, "Token inválido.");
                }

                User? user = await authRepository.GetByIdAsync(userId);
                if (user is null)
                {
                    return new(null, 404, "Usuário não encontrado.");
                }

                string newToken = GenerateJwtToken(user);
                string newRefreshToken = GenerateJwtToken(user, true);

                var result = new
                {
                    token = newToken,
                    refreshToken = newRefreshToken,
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

                return new(result, 200, "Token renovado com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }

        public async Task<ResponseApi<dynamic>> ForgotPasswordAsync(ForgotPasswordRequest request)
        {
            try
            {
                User? user = await authRepository.GetByEmailAsync(request.Email);
                if (user is null)
                {
                    return new(null, 200, "Se o e-mail estiver cadastrado, um link de recuperação foi enviado.");
                }

                string resetToken = Convert.ToHexString(System.Security.Cryptography.RandomNumberGenerator.GetBytes(32)).ToLower();
                user.PasswordResetToken = resetToken;
                user.PasswordResetExpires = DateTime.UtcNow.AddHours(2);
                user.UpdatedAt = DateTime.UtcNow;

                await authRepository.UpdateAsync(user);

                string frontendUrl = Environment.GetEnvironmentVariable("FRONTEND_URL") ?? "http://localhost:4300";
                string resetLink = $"{frontendUrl}/reset-password?token={resetToken}";

                Console.WriteLine($"[EMAIL RECOVERY LINK] Para: {user.Email} | Link: {resetLink}");

                return new(new { resetLink, token = resetToken }, 200, "E-mail com instruções de recuperação enviado com sucesso.");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }

        public async Task<ResponseApi<dynamic>> ResetPasswordAsync(ResetPasswordRequest request)
        {
            try
            {
                if (!request.Password.Equals(request.ConfirmPassword))
                {
                    return new(null, 400, "As senhas informadas não coincidem.");
                }

                User? user = await authRepository.GetByResetTokenAsync(request.Token);
                if (user is null || user.PasswordResetExpires == null || user.PasswordResetExpires < DateTime.UtcNow)
                {
                    return new(null, 400, "Token de recuperação inválido ou expirado.");
                }

                user.Password = BCrypt.Net.BCrypt.HashPassword(request.Password);
                user.PasswordResetToken = null;
                user.PasswordResetExpires = null;
                user.UpdatedAt = DateTime.UtcNow;

                await authRepository.UpdateAsync(user);

                return new(null, 200, "Senha redefinida com sucesso.");
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