using api_bora_trampar.src.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace api_bora_trampar.src.Controllers
{
    [ApiController]
    [Authorize]
    [Route("api/uploads")]
    public class UploadController(ICloudinaryHandler cloudinaryHandler) : ControllerBase
    {
        [HttpPost("image")]
        [Consumes("multipart/form-data")]
        public async Task<IActionResult> UploadImage([FromForm] IFormFile file, [FromForm] string? folder)
        {
            if (file == null || file.Length == 0) return BadRequest(new { message = "Arquivo inválido ou não enviado." });

            string targetFolder = string.IsNullOrWhiteSpace(folder) ? "boratrampar/documents" : $"boratrampar/{folder}";
            string url = await cloudinaryHandler.UploadImageAsync(file, targetFolder);

            return Ok(new { url });
        }

        [HttpPost("base64")]
        public async Task<IActionResult> UploadBase64([FromBody] UploadBase64Request request)
        {
            if (string.IsNullOrWhiteSpace(request?.Base64)) return BadRequest(new { message = "Base64 inválido." });

            string targetFolder = string.IsNullOrWhiteSpace(request.Folder) ? "boratrampar/documents" : $"boratrampar/{request.Folder}";
            string url = await cloudinaryHandler.UploadBase64Async(request.Base64, targetFolder);

            return Ok(new { url });
        }
    }

    public class UploadBase64Request
    {
        public string Base64 { get; set; } = string.Empty;
        public string Folder { get; set; } = string.Empty;
    }
}
