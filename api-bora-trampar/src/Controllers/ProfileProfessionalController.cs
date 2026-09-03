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
    [Route("api/profile-professionals")]
    public class ProfileProfessionalController(IProfileProfessionalService service) : ControllerBase
    {
        [HttpGet("me")]
        public async Task<IActionResult> GetMe()
        {
            string userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "";
            if (string.IsNullOrEmpty(userId)) return Unauthorized();

            ResponseApi<ProfileProfessional?> response = await service.GetByUserIdAsync(userId);
            return StatusCode(response.StatusCode, new { response.Result, response.Message });
        }

        [AllowAnonymous]
        [HttpGet("user/{userId}")]
        public async Task<IActionResult> GetByUserId(string userId)
        {
            ResponseApi<ProfileProfessional?> response = await service.GetByUserIdAsync(userId);
            return StatusCode(response.StatusCode, new { response.Result, response.Message });
        }

        [AllowAnonymous]
        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(string id)
        {
            ResponseApi<ProfileProfessional?> response = await service.GetByIdAsync(id);
            return StatusCode(response.StatusCode, new { response.Result, response.Message });
        }

        [AllowAnonymous]
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            ResponseApi<List<ProfileProfessional>> response = await service.GetAllAsync();
            return StatusCode(response.StatusCode, new { response.Result, response.Message });
        }

        [AllowAnonymous]
        [HttpPost]
        public async Task<IActionResult> Save([FromBody] CreateProfileProfessionalRequest request)
        {
            if (request == null) return BadRequest(new { message = "Dados inválidos" });

            string userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? request.UserId;
            ResponseApi<ProfileProfessional?> response = await service.SaveAsync(request, userId);
            return StatusCode(response.StatusCode, new { response.Result, response.Message });
        }

        [AllowAnonymous]
        [HttpPut]
        public async Task<IActionResult> Update([FromBody] CreateProfileProfessionalRequest request)
        {
            if (request == null) return BadRequest(new { message = "Dados inválidos" });

            string userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? request.UserId;
            ResponseApi<ProfileProfessional?> response = await service.SaveAsync(request, userId);
            return StatusCode(response.StatusCode, new { response.Result, response.Message });
        }

        [HttpPatch("availability")]
        public async Task<IActionResult> UpdateAvailability([FromBody] AvailabilityRequest request)
        {
            string userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "";
            ResponseApi<bool> response = await service.UpdateAvailabilityAsync(userId, request.IsAvailable);
            return StatusCode(response.StatusCode, new { response.Result, response.Message });
        }

        [AllowAnonymous]
        [HttpPost("identity")]
        public async Task<IActionResult> SaveIdentity([FromBody] IdentityVerificationRequest request)
        {
            string userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "";
            ResponseApi<bool> response = await service.SaveIdentityVerificationAsync(
                userId,
                request.DocumentType,
                request.DocumentNumber,
                request.FrontUrl,
                request.BackUrl,
                request.SelfieUrl
            );
            return StatusCode(response.StatusCode, new { response.Result, response.Message });
        }
    }

    public class AvailabilityRequest
    {
        public bool IsAvailable { get; set; }
    }

    public class IdentityVerificationRequest
    {
        public string DocumentType { get; set; } = "CNH";
        public string DocumentNumber { get; set; } = string.Empty;
        public string FrontUrl { get; set; } = string.Empty;
        public string BackUrl { get; set; } = string.Empty;
        public string SelfieUrl { get; set; } = string.Empty;
    }
}
