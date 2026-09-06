using System.Security.Claims;
using api_bora_trampar.src.Interfaces;
using api_bora_trampar.src.Models;
using api_bora_trampar.src.Models.Base;
using api_bora_trampar.src.Requests.Base;
using api_bora_trampar.src.Requests.Notification;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace api_bora_trampar.src.Controllers
{
    [ApiController]
    [Authorize]
    [Route("api/notifications")]
    public class NotificationController(INotificationService service) : ControllerBase
    {
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            string userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "";
            if (string.IsNullOrEmpty(userId)) return Unauthorized();

            var response = await service.GetAllByUserIdAsync(userId);
            return StatusCode(response.StatusCode, new { response.Result, response.Message });
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(string id)
        {
            var response = await service.GetByIdAsync(id);
            return StatusCode(response.StatusCode, new { response.Result, response.Message });
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateNotificationRequest request)
        {
            if (string.IsNullOrEmpty(request.UserId))
            {
                request.UserId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "";
            }
            var response = await service.CreateAsync(request);
            return StatusCode(response.StatusCode, new { response.Result, response.Message });
        }

        [HttpPatch("{id}/read")]
        public async Task<IActionResult> MarkAsRead(string id)
        {
            var response = await service.MarkAsReadAsync(id);
            return StatusCode(response.StatusCode, new { response.Result, response.Message });
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id)
        {
            string userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "";
            DeleteRequest request = new()
            {
                Id = id,
                DeletedBy = userId
            };
            var response = await service.DeleteAsync(request);
            return StatusCode(response.StatusCode, new { response.Result, response.Message });
        }
    }
}

