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
    [Route("api/settings")]
    public class SettingsController(ISettingsService service) : ControllerBase
    {
        [HttpGet]
        public async Task<IActionResult> Get()
        {
            ResponseApi<PlatformSettings> response = await service.GetAsync();
            return StatusCode(response.StatusCode, new { response.Result });
        }

        [HttpPut]
        public async Task<IActionResult> Update([FromBody] UpdateSettingsRequest request)
        {
            ResponseApi<PlatformSettings> response = await service.UpdateAsync(request);
            return StatusCode(response.StatusCode, new { response.Result });
        }
    }
}
