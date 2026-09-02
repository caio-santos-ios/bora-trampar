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
    [Route("api/payments")]
    public class PaymentController(IPaymentService service, IAsaasService asaasService) : ControllerBase
    {
        [AllowAnonymous]
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            ResponseApi<List<dynamic>> response = await service.GetAllAsync();
            return StatusCode(response.StatusCode, new { response.Result });
        }

        [AllowAnonymous]
        [HttpGet("{id}")]
        public async Task<IActionResult> GetByIdAsync(string id)
        {
            ResponseApi<Payment?> response = await service.GetByIdAsync(id);
            return StatusCode(response.StatusCode, new { response.Result });
        }

        [AllowAnonymous]
        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreatePaymentRequest request)
        {
            if (request == null) return BadRequest("Dados inválidos.");

            request.UpdatedBy = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "";

            ResponseApi<Payment?> response = await service.CreateAsync(request);
            return StatusCode(response.StatusCode, new { response.Result });
        }

        [AllowAnonymous]
        [HttpPost("asaas/pix")]
        public async Task<IActionResult> CreateAsaasPix([FromBody] CreatePaymentRequest request)
        {
            if (request == null) return BadRequest("Dados inválidos.");

            string customerName = User.FindFirst(ClaimTypes.Name)?.Value ?? "Cliente Bora Trampar";
            string customerEmail = User.FindFirst(ClaimTypes.Email)?.Value ?? "cliente@boratrampar.com.br";

            string asaasCustomerId = await asaasService.GetOrCreateCustomerAsync(customerName, "00000000000", customerEmail, "11999999999");
            var asaasPix = await asaasService.CreatePixPaymentAsync(asaasCustomerId, request.Value, $"Diária de Serviço - Bora Trampar");

            request.MethodPayment = "PIX Instantâneo";
            request.Status = "PENDING";
            if (asaasPix != null)
            {
                request.AsaasId = asaasPix.Value.paymentId;
                request.QrCodeImage = asaasPix.Value.qrCodeImage;
                request.QrCodePayload = asaasPix.Value.qrCodePayload;
            }
            else
            {
                request.AsaasId = $"pay_asaas_{Guid.NewGuid().ToString("N")[..12]}";
                request.QrCodeImage = "https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=00020126580014br.gov.bcb.pix0136boratrampar@pix.com.br5204000053039865405" + request.Value.ToString("F2") + "5802BR5912BORA TRAMPAR6009SAO PAULO62070503***6304";
                request.QrCodePayload = "00020126580014br.gov.bcb.pix0136boratrampar@pix.com.br5204000053039865405" + request.Value.ToString("F2").Replace(",", ".") + "5802BR5912BORA TRAMPAR6009SAO PAULO62070503***6304ABCD";
            }

            request.UpdatedBy = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "";

            ResponseApi<Payment?> response = await service.CreateAsync(request);
            return StatusCode(response.StatusCode, new { response.Result });
        }

        [AllowAnonymous]
        [HttpPost("confirm/{id}")]
        public async Task<IActionResult> ConfirmPayment(string id)
        {
            string userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "";
            ResponseApi<Payment?> response = await service.ConfirmPaymentAsync(id, userId);
            return StatusCode(response.StatusCode, new { response.Result });
        }

        [AllowAnonymous]
        [HttpPut]
        public async Task<IActionResult> Update([FromBody] UpdatePaymentRequest request)
        {
            if (request == null) return BadRequest("Dados inválidos.");

            request.UpdatedBy = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "";

            ResponseApi<Payment?> response = await service.UpdateAsync(request);
            return StatusCode(response.StatusCode, new { response.Result });
        }

        [AllowAnonymous]
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id)
        {
            string userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "";
            ResponseApi<Payment?> response = await service.DeleteAsync(new() { Id = id, DeletedBy = userId });
            return StatusCode(response.StatusCode, new { response.Message });
        }
    }
}
