using System.Security.Claims;
using api_bora_trampar.src.Interfaces;
using api_bora_trampar.src.Models;
using api_bora_trampar.src.Models._Base;
using api_bora_trampar.src.Models.Base;
using api_bora_trampar.src.Requests;
using api_bora_trampar.src.Requests._Base;
using api_bora_trampar.src.Requests.Asaas;
using api_bora_trampar.src.Requests.Base;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace api_bora_trampar.src.Controllers
{
    [ApiController]
    [Authorize]
    [Route("api/transfers")]
    public class TransferController(ITransferService service) : ControllerBase
    {
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            GetAllRequest request = new(Request.Query);
            ResponseApi<PaginationApi<List<dynamic>>> response = await service.GetAllAsync(request);
            return StatusCode(response.StatusCode, new { response.Result });
        }

        [HttpGet("me")]
        public async Task<IActionResult> GetMyTransfers()
        {
            string userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "";
            if (string.IsNullOrEmpty(userId)) return Unauthorized();

            ResponseApi<List<dynamic>> response = await service.GetByUserAsync(userId);
            return StatusCode(response.StatusCode, new { response.Result });
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetByIdAsync(string id)
        {
            ResponseApi<Transfer?> response = await service.GetByIdAsync(id);
            return StatusCode(response.StatusCode, new { response.Result });
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateTransferRequest request)
        {
            if (request == null) return BadRequest("Dados inválidos.");

            string userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "";
            if (string.IsNullOrEmpty(userId)) return Unauthorized();

            request.UserId = userId;
            request.UpdatedBy = userId;

            ResponseApi<Transfer?> response = await service.CreateAsync(request);
            return StatusCode(response.StatusCode, new { response.Result });
        }
        
        [AllowAnonymous]
        [HttpPost("check-transfer")]
        public async Task<IActionResult> CheckTransfer([FromBody] CheckTransferRequest request)
        {
            string token = Request.Headers["asaas-access-token"].ToString();
            string expectedToken = Environment.GetEnvironmentVariable("ASAAS_WEBHOOK_TRANSFER_TOKEN") ?? "";

            if (token != expectedToken)
                return Unauthorized();

            ResponseApi<Transfer?> response = await service.CheckTransferAsync(request);
            return StatusCode(response.StatusCode, new { response.Result });
        }

        [HttpPut]
        public async Task<IActionResult> Update([FromBody] UpdateTransferRequest request)
        {
            if (request == null) return BadRequest("Dados inválidos.");

            request.UpdatedBy = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "";

            ResponseApi<Transfer?> response = await service.UpdateAsync(request);
            return StatusCode(response.StatusCode, new { response.Result });
        }

        [HttpDelete]
        public async Task<IActionResult> Delete([FromBody] DeleteRequest request)
        {
            if (request == null) return BadRequest("Dados inválidos.");

            request.UpdatedBy = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "";

            ResponseApi<Transfer?> response = await service.DeleteAsync(request);
            return StatusCode(response.StatusCode, new { response.Result });
        }
    }
}
