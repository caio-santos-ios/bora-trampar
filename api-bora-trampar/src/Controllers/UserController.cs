using System.Security.Claims;
using api_bora_trampar.src.Interfaces;
using api_bora_trampar.src.Models;
using api_bora_trampar.src.Models.Base;
using api_bora_trampar.src.Requests;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace api_bora_trampar.src.Controllers
{
    [ApiController]
    [Authorize]
    [Route("api/users")]
    public class UserController(IUserService service) : ControllerBase
    {
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            ResponseApi<List<dynamic>> response = await service.GetAllAsync();
            return StatusCode(response.StatusCode, new { response.Result });
        }

        [HttpGet("me")]
        public async Task<IActionResult> GetMe()
        {
            string userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "";
            ResponseApi<User?> response = await service.GetByIdAsync(userId);
            return StatusCode(response.StatusCode, new { response.Result });
        }

        [HttpPost("wallet/credit")]
        public async Task<IActionResult> CreditWallet([FromBody] CreditWalletRequest request)
        {
            if (request == null || request.Amount <= 0) return BadRequest("Valor inválido.");

            string userId = !string.IsNullOrEmpty(request.UserId) ? request.UserId : (User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "");
            ResponseApi<decimal> response = await service.UpdateWalletBalanceAsync(userId, request.Amount);
            return StatusCode(response.StatusCode, new { newBalance = response.Result });
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetByIdAsync(string id)
        {
            ResponseApi<User?> response = await service.GetByIdAsync(id);
            return StatusCode(response.StatusCode, new { response.Result });
        }

        [HttpPut]
        public async Task<IActionResult> Update([FromBody] UpdateUserRequest request)
        {
            if (request == null) return BadRequest("Dados inválidos.");

            request.UpdatedBy = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "";

            ResponseApi<User?> response = await service.UpdateAsync(request);
            return StatusCode(response.StatusCode, new { response.Result });
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id)
        {
            string userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "";
            ResponseApi<User?> response = await service.DeleteAsync(new () { Id = id, DeletedBy = userId });
            return StatusCode(response.StatusCode, new { response.Message });
        }
    }
}