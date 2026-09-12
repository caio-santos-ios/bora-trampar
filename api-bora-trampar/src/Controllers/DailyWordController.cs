using System.Security.Claims;
using api_bora_trampar.src.Interfaces;
using api_bora_trampar.src.Models;
using api_bora_trampar.src.Models._Base;
using api_bora_trampar.src.Models.Base;
using api_bora_trampar.src.Requests;
using api_bora_trampar.src.Requests._Base;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace api_bora_trampar.src.Controllers
{
    [ApiController]
    [Authorize]
    [Route("api/daily-words")]
    public class DailyWordController(IDailyWordService service) : ControllerBase
    {
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            GetAllRequest request = new(Request.Query);
            ResponseApi<PaginationApi<List<dynamic>>> response = await service.GetAllAsync(request);
            return StatusCode(response.StatusCode, new { response.Result });
        }

        [AllowAnonymous]
        [HttpGet("today")]
        public async Task<IActionResult> GetToday([FromQuery] string audience = "")
        {
            ResponseApi<DailyWord?> response = await service.GetTodayAsync(audience);
            return StatusCode(response.StatusCode, new { response.Result });
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetByIdAsync(string id)
        {
            ResponseApi<DailyWord?> response = await service.GetByIdAsync(id);
            return StatusCode(response.StatusCode, new { response.Result });
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateDailyWordRequest request)
        {
            if (request == null) return BadRequest("Dados inválidos.");

            request.UpdatedBy = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "";

            ResponseApi<DailyWord?> response = await service.CreateAsync(request);
            return StatusCode(response.StatusCode, new { response.Result });
        }

        [HttpPut]
        public async Task<IActionResult> Update([FromBody] UpdateDailyWordRequest request)
        {
            if (request == null) return BadRequest("Dados inválidos.");

            request.UpdatedBy = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "";

            ResponseApi<DailyWord?> response = await service.UpdateAsync(request);
            return StatusCode(response.StatusCode, new { response.Result });
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id)
        {
            string userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "";
            ResponseApi<DailyWord?> response = await service.DeleteAsync(new() { Id = id, DeletedBy = userId });
            return StatusCode(response.StatusCode, new { response.Message });
        }
    }
}
