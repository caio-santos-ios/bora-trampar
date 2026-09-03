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
    [Route("api/approvals")]
    public class ApprovalController(IApprovalService service) : ControllerBase
    {
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            ResponseApi<List<dynamic>> response = await service.GetAllAsync();
            return StatusCode(response.StatusCode, new { response.Result, response.Message });
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetByIdAsync(string id)
        {
            ResponseApi<Approval?> response = await service.GetByIdAsync(id);
            return StatusCode(response.StatusCode, new { response.Result, response.Message });
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateApprovalRequest request)
        {
            if (request == null) return BadRequest(new { message = "Dados inválidos." });

            request.UpdatedBy = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "";

            ResponseApi<Approval?> response = await service.CreateAsync(request);
            return StatusCode(response.StatusCode, new { response.Result, response.Message });
        }

        [HttpPut]
        public async Task<IActionResult> Update([FromBody] UpdateApprovalRequest request)
        {
            if (request == null) return BadRequest(new { message = "Dados inválidos." });

            request.UpdatedBy = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "";

            ResponseApi<Approval?> response = await service.UpdateAsync(request);
            return StatusCode(response.StatusCode, new { response.Result, response.Message });
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id)
        {
            string userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "";
            ResponseApi<Approval?> response = await service.DeleteAsync(new() { Id = id, DeletedBy = userId });
            return StatusCode(response.StatusCode, new { response.Message });
        }
    }
}
