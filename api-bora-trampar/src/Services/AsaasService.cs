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

            if (string.IsNullOrEmpty(_apiKey))
            {
                var possiblePaths = new[]
                {
                    Path.Combine(Directory.GetCurrentDirectory(), ".env"),
                    Path.Combine(AppContext.BaseDirectory, ".env"),
                    Path.Combine(Directory.GetParent(AppContext.BaseDirectory)?.Parent?.Parent?.FullName ?? "", ".env")
                };

                foreach (var path in possiblePaths)
                {
                    if (File.Exists(path))
                    {
                        foreach (var line in File.ReadAllLines(path))
                        {
                            var trimmed = line.Trim();
                            if (trimmed.StartsWith("ASAAS_API_KEY="))
                            {
                                _apiKey = trimmed.Substring("ASAAS_API_KEY=".Length).Trim('\'', '"', ' ', '\r', '\n');
                                break;
                            }
                        }
                        if (!string.IsNullOrEmpty(_apiKey)) break;
                    }
                }
            }

            var cleanBaseUrl = _baseUrl.TrimEnd('/') + "/";

            _httpClient = new HttpClient
            {
                BaseAddress = new Uri(cleanBaseUrl)
            };
            _httpClient.DefaultRequestHeaders.Add("User-Agent", "BoraTrampar/1.0");
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

                string? cleanPhone = null;
                if (!string.IsNullOrWhiteSpace(phone))
                {
                    var digits = new string(phone.Where(char.IsDigit).ToArray());
                    if (digits.Length >= 10 && digits.Length <= 11 && !digits.All(c => c == digits[0]))
                    {
                        cleanPhone = digits;
                    }
                }

                string? cleanCpf = null;
                if (!string.IsNullOrWhiteSpace(cpfCnpj))
                {
                    var digits = new string(cpfCnpj.Where(char.IsDigit).ToArray());
                    if ((digits.Length == 11 || digits.Length == 14) && !digits.All(c => c == digits[0]))
                    {
                        cleanCpf = digits;
                    }
                }

                if (string.IsNullOrEmpty(cleanCpf))
                {
                    cleanCpf = "08630628570";
                }

                var searchResponse = await _httpClient.GetAsync($"customers?email={Uri.EscapeDataString(email)}");
                if (searchResponse.IsSuccessStatusCode)
                {
                    var searchContent = await searchResponse.Content.ReadAsStringAsync();
                    using var doc = JsonDocument.Parse(searchContent);
                    var data = doc.RootElement.GetProperty("data");
                    if (data.GetArrayLength() > 0)
                    {
                        var cust = data[0];
                        var existingId = cust.GetProperty("id").GetString() ?? "cus_default";
                        var hasCpf = cust.TryGetProperty("cpfCnpj", out var cpfProp) && !string.IsNullOrEmpty(cpfProp.GetString());
                        if (!hasCpf && !string.IsNullOrEmpty(cleanCpf))
                        {
                            var updatePayload = new { cpfCnpj = cleanCpf };
                            var updateContent = new StringContent(JsonSerializer.Serialize(updatePayload), Encoding.UTF8, "application/json");
                            await _httpClient.PostAsync($"customers/{existingId}", updateContent);
                        }
                        return existingId;
                    }
                }

                var createPayload = new
                {
                    name = string.IsNullOrWhiteSpace(name) ? "Cliente Bora Trampar" : name,
                    cpfCnpj = cleanCpf,
                    email = string.IsNullOrWhiteSpace(email) ? "cliente@boratrampar.com.br" : email,
                    mobilePhone = cleanPhone
                };

                var content = new StringContent(JsonSerializer.Serialize(createPayload), Encoding.UTF8, "application/json");
                var response = await _httpClient.PostAsync("customers", content);

                if (response.IsSuccessStatusCode)
                {
                    var responseContent = await response.Content.ReadAsStringAsync();
                    using var doc = JsonDocument.Parse(responseContent);
                    return doc.RootElement.GetProperty("id").GetString() ?? "cus_created";
                }

                var customerError = await response.Content.ReadAsStringAsync();
                Console.WriteLine($"ASAAS CUSTOMER ERROR ({response.StatusCode}): {customerError}");
                return "cus_fallback";
            }
            catch (Exception ex)
            {
                Console.WriteLine($"ASAAS CUSTOMER EXCEPTION: {ex.Message}");
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
                    var paymentError = await paymentResponse.Content.ReadAsStringAsync();
                    Console.WriteLine($"ASAAS PAYMENT ERROR ({paymentResponse.StatusCode}): {paymentError}");
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

                var qrError = await qrResponse.Content.ReadAsStringAsync();
                Console.WriteLine($"ASAAS QR ERROR ({qrResponse.StatusCode}): {qrError}");
                return (paymentId, "", "");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"ASAAS PAYMENT EXCEPTION: {ex.Message}");
                return null;
            }
        }

        public async Task<bool> IsPaymentReceivedAsync(string paymentId)
        {
            try
            {
                if (string.IsNullOrEmpty(_apiKey)) return false;

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
