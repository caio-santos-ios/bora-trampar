using api_bora_trampar.src.Interfaces.Address;
using api_bora_trampar.src.Models.Base;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace api_bora_trampar.src.Controllers
{
    [ApiController]
    [Authorize]
    [Route("api/addresses")]
    public class AddressController(IAddressService service) : ControllerBase
    {
        [HttpGet("{zipCode}")]
        public async Task<IActionResult> GetByZipCode(string zipCode)
        {
            ResponseApi<dynamic?> response = await service.GetByZipCodeAsync(zipCode);
            return StatusCode(response.StatusCode, new { response.Result });
        }
        
        [HttpGet("search")]
        public async Task<IActionResult> GetSearch([FromQuery] string q)
        {
            ResponseApi<List<dynamic>> response = await service.GetSearchAsync(q);
            return StatusCode(response.StatusCode, new { response.Result });
        }
        
        [HttpGet("distance")]
        public async Task<IActionResult> GetDistance([FromQuery] string profile, [FromQuery] string lonOrigin, [FromQuery] string latOrigin, [FromQuery] string lonDestination, [FromQuery] string latDestination)
        {
            ResponseApi<dynamic?> response = await service.GetDistanceAsync(profile, lonOrigin, latOrigin, lonDestination, latDestination);
            return StatusCode(response.StatusCode, new { response.Result });
        }
    }
}
