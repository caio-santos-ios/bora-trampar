using api_bora_trampar.src.Interfaces.Dashboard;
using api_bora_trampar.src.Models.Base;
using api_bora_trampar.src.Responses.Dashboard;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace api_bora_trampar.src.Controllers
{
    [ApiController]
    [Authorize]
    [Route("api/dashboard")]
    public class DashboardController(IDashboardService service) : ControllerBase
    {
        [HttpGet]
        public async Task<IActionResult> Get([FromQuery] DateTime? startDate, [FromQuery] DateTime? endDate)
        {
            ResponseApi<DashboardResponse> response = await service.GetMetricsAsync(startDate, endDate);
            return StatusCode(response.StatusCode, new { response.Result, response.Message });
        }
    }
}
