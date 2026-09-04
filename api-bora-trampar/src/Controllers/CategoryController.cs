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
    [Route("api/categories")]
    public class CategoryController(ICategoryService service) : ControllerBase
    {
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            GetAllRequest request = new(Request.Query);
            ResponseApi<PaginationApi<List<dynamic>>> response = await service.GetAllAsync(request);
            return StatusCode(response.StatusCode, new { response.Result });
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetByIdAsync(string id)
        {
            ResponseApi<Category?> response = await service.GetByIdAsync(id);
            return StatusCode(response.StatusCode, new { response.Result });
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateCategoryRequest request)
        {
            if (request == null) return BadRequest("Dados inválidos.");

            request.UpdatedBy = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "";

            ResponseApi<Category?> response = await service.CreateAsync(request);
            return StatusCode(response.StatusCode, new { response.Result });
        }
        
        [HttpPut]
        public async Task<IActionResult> Update([FromBody] UpdateCategoryRequest request)
        {
            if (request == null) return BadRequest("Dados inválidos.");

            request.UpdatedBy = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "";

            ResponseApi<Category?> response = await service.UpdateAsync(request);
            return StatusCode(response.StatusCode, new { response.Result });
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id)
        {
            string userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "";
            ResponseApi<Category?> response = await service.DeleteAsync(new () { Id = id, DeletedBy = userId });
            return StatusCode(response.StatusCode, new { response.Message });
        }
    }
}