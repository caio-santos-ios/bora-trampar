using System.Text;
using System.Text.Json;
using api_bora_trampar.src.Interfaces;

namespace api_bora_trampar.src.Services
{
    public class AsaasService : IAsaasService
    {
        private readonly HttpClient _httpClient;
        private readonly string _apiKey;
        private readonly string _baseUrl;

        public AsaasService()
        {
            _apiKey = Environment.GetEnvironmentVariable("ASAAS_API_KEY") ?? "";
            _baseUrl = Environment.GetEnvironmentVariable("ASAAS_BASE_URL") ?? "https://sandbox.asaas.com/api/v3";

            var cleanBaseUrl = _baseUrl.TrimEnd('/') + "/";

            _httpClient = new HttpClient
            {
                BaseAddress = new Uri(cleanBaseUrl)
            };
            if (!string.IsNullOrEmpty(_apiKey))
            {
                _httpClient.DefaultRequestHeaders.Add("access_token", _apiKey);
            }
        }

        public async Task<string> GetOrCreateCustomerAsync(string name, string cpfCnpj, string email, string phone)
        {
            try
            {
                if (string.IsNullOrEmpty(_apiKey)) return "cus_mock_customer";

                var searchResponse = await _httpClient.GetAsync($"customers?email={Uri.EscapeDataString(email)}");
                if (searchResponse.IsSuccessStatusCode)
                {
                    var searchContent = await searchResponse.Content.ReadAsStringAsync();
                    using var doc = JsonDocument.Parse(searchContent);
                    var data = doc.RootElement.GetProperty("data");
                    if (data.GetArrayLength() > 0)
                    {
                        return data[0].GetProperty("id").GetString() ?? "cus_default";
                    }
                }

                var createPayload = new
                {
                    name = string.IsNullOrWhiteSpace(name) ? "Cliente Bora Trampar" : name,
                    cpfCnpj = string.IsNullOrWhiteSpace(cpfCnpj) || cpfCnpj == "00000000000" ? null : cpfCnpj.Replace(".", "").Replace("-", ""),
                    email = string.IsNullOrWhiteSpace(email) ? "cliente@boratrampar.com.br" : email,
                    mobilePhone = string.IsNullOrWhiteSpace(phone) ? "11999999999" : phone.Replace("(", "").Replace(")", "").Replace("-", "").Replace(" ", "")
                };

                var content = new StringContent(JsonSerializer.Serialize(createPayload), Encoding.UTF8, "application/json");
                var response = await _httpClient.PostAsync("customers", content);

                if (response.IsSuccessStatusCode)
                {
                    var responseContent = await response.Content.ReadAsStringAsync();
                    using var doc = JsonDocument.Parse(responseContent);
                    return doc.RootElement.GetProperty("id").GetString() ?? "cus_created";
                }

                return "cus_fallback";
            }
            catch
            {
                return "cus_fallback";
            }
        }

        public async Task<(string paymentId, string qrCodeImage, string qrCodePayload)?> CreatePixPaymentAsync(
            string customerId,
            decimal value,
            string description)
        {
            try
            {
                if (string.IsNullOrEmpty(_apiKey))
                {
                    var mockId = $"pay_{Guid.NewGuid().ToString("N")[..12]}";
                    var mockImg = "https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=boratrampar_pix_sandbox";
                    var mockPayload = "00020126580014br.gov.bcb.pix0136boratrampar@pix.com.br5204000053039865405";
                    return (mockId, mockImg, mockPayload);
                }

                var paymentPayload = new
                {
                    customer = customerId,
                    billingType = "PIX",
                    value = value,
                    dueDate = DateTime.UtcNow.AddDays(1).ToString("yyyy-MM-dd"),
                    description = description
                };

                var content = new StringContent(JsonSerializer.Serialize(paymentPayload), Encoding.UTF8, "application/json");
                var paymentResponse = await _httpClient.PostAsync("payments", content);

                if (!paymentResponse.IsSuccessStatusCode)
                {
                    return null;
                }

                var paymentContent = await paymentResponse.Content.ReadAsStringAsync();
                using var paymentDoc = JsonDocument.Parse(paymentContent);
                var paymentId = paymentDoc.RootElement.GetProperty("id").GetString() ?? "";

                var qrResponse = await _httpClient.GetAsync($"payments/{paymentId}/pixQrCode");
                if (qrResponse.IsSuccessStatusCode)
                {
                    var qrContent = await qrResponse.Content.ReadAsStringAsync();
                    using var qrDoc = JsonDocument.Parse(qrContent);
                    var encodedImage = qrDoc.RootElement.GetProperty("encodedImage").GetString() ?? "";
                    var payload = qrDoc.RootElement.GetProperty("payload").GetString() ?? "";

                    var imageSrc = encodedImage.StartsWith("data:image")
                        ? encodedImage
                        : $"data:image/png;base64,{encodedImage}";

                    return (paymentId, imageSrc, payload);
                }

                return (paymentId, "", "");
            }
            catch
            {
                return null;
            }
        }

        public async Task<bool> IsPaymentReceivedAsync(string paymentId)
        {
            try
            {
                if (string.IsNullOrEmpty(_apiKey)) return true;

                var response = await _httpClient.GetAsync($"payments/{paymentId}");
                if (response.IsSuccessStatusCode)
                {
                    var content = await response.Content.ReadAsStringAsync();
                    using var doc = JsonDocument.Parse(content);
                    var status = doc.RootElement.GetProperty("status").GetString() ?? "";
                    return status == "RECEIVED" || status == "CONFIRMED" || status == "RECEIVED_IN_CASH";
                }
                return false;
            }
            catch
            {
                return false;
            }
        }
    }
}
