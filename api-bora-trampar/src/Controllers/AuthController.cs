using api_bora_trampar.src.Interfaces.Auth;
using api_bora_trampar.src.Models.Base;
using api_bora_trampar.src.Requests.Auth;
using Microsoft.AspNetCore.Mvc;

namespace api_bora_trampar.src.Controllers
{
    [ApiController]
    [Route("api/auth")]
    public class AuthController(IAuthService service) : ControllerBase
    {
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            if (request == null) return BadRequest("Dados inválidos.");

            ResponseApi<dynamic> response = await service.LoginAsync(request);
            return StatusCode(response.StatusCode, new { response.Result });
        }

        [HttpPost("registers")]
        public async Task<IActionResult> Register([FromBody] RegisterRequest request)
        {
            if (request == null) return BadRequest("Dados inválidos.");

            ResponseApi<dynamic> response = await service.RegisterAsync(request);
            return StatusCode(response.StatusCode, new { response.Result, response.Message });
        }

        [HttpPost("refresh-token")]
        public async Task<IActionResult> RefreshToken([FromBody] RefreshTokenRequest request)
        {
            if (request == null) return BadRequest("Dados inválidos.");

            ResponseApi<dynamic> response = await service.RefreshTokenAsync(request);
            return StatusCode(response.StatusCode, new { response.Result, response.Message });
        }

        [HttpPost("forgot-password")]
        public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordRequest request)
        {
            if (request == null) return BadRequest("Dados inválidos.");

            ResponseApi<dynamic> response = await service.ForgotPasswordAsync(request);
            return StatusCode(response.StatusCode, new { response.Result, response.Message });
        }

        [HttpPost("reset-password")]
        public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordRequest request)
        {
            if (request == null) return BadRequest("Dados inválidos.");

            ResponseApi<dynamic> response = await service.ResetPasswordAsync(request);
            return StatusCode(response.StatusCode, new { response.Result, response.Message });
        }
    }
}
