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
        [AllowAnonymous]
        [HttpGet("{zipCode}")]
        public async Task<IActionResult> GetByZipCode(string zipCode)
        {
            ResponseApi<dynamic?> response = await service.GetByZipCodeAsync(zipCode);
            return StatusCode(response.StatusCode, new { response.Result });
        }
    }
}
