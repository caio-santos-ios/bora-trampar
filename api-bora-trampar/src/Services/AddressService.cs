using System.Globalization;
using System.Text.Json;
using api_bora_trampar.src.Interfaces.Address;
using api_bora_trampar.src.Models.Base;

namespace api_bora_trampar.src.Services
{
    public class AddressService(HttpClient httpClient) : IAddressService
    {
        public async Task<ResponseApi<dynamic?>> GetByZipCodeAsync(string zipCode)
        {
            try
            {
                zipCode = zipCode.Replace(".", "").Replace("-", "");
                var brasilApiUrl = $"https://brasilapi.com.br/api/cep/v2/{zipCode}";
                var brasilApiResponse = await httpClient.GetAsync(brasilApiUrl);

                if (!brasilApiResponse.IsSuccessStatusCode) return new(null, 404, "CEP não encontrado");

                var brasilApiJson = await brasilApiResponse.Content.ReadAsStringAsync();
                using var brasilApiDoc = JsonDocument.Parse(brasilApiJson);
                var root = brasilApiDoc.RootElement;

                string street = root.GetProperty("street").GetString() ?? "";
                string neighborhood = root.GetProperty("neighborhood").GetString() ?? "";
                string city = root.GetProperty("city").GetString() ?? "";
                string state = root.GetProperty("state").GetString() ?? "";


                string nominatimUrl = "https://nominatim.openstreetmap.org/search" +
                $"?street={Uri.EscapeDataString(street)}" +
                $"&city={Uri.EscapeDataString(city)}" +
                $"&state={Uri.EscapeDataString(state)}" +
                $"&country=Brazil" +
                $"&format=json&limit=1";

                using var nominatimRequest = new HttpRequestMessage(HttpMethod.Get, nominatimUrl);

                nominatimRequest.Headers.Add("User-Agent", "SeuApp/1.0 (seuemail@exemplo.com)");

                var nominatimResponse = await httpClient.SendAsync(nominatimRequest);

                double? lat = null;
                double? lon = null;

                if (nominatimResponse.IsSuccessStatusCode)
                {
                    var nominatimJson = await nominatimResponse.Content.ReadAsStringAsync();

                    using var nominatimDoc = JsonDocument.Parse(nominatimJson);
                    var results = nominatimDoc.RootElement;

                    if (results.GetArrayLength() > 0)
                    {
                        var primeiroResultado = results[0];
                        lat = double.Parse(primeiroResultado.GetProperty("lat").GetString()!, CultureInfo.InvariantCulture);
                        lon = double.Parse(primeiroResultado.GetProperty("lon").GetString()!, CultureInfo.InvariantCulture);
                    }
                }

                dynamic address = new
                {
                    Cep = zipCode,
                    Street = street,
                    Neighborhood = neighborhood,
                    City = city,
                    State = state,
                    Latitude = lat,
                    Longitude = lon
                };

                string mensagem = lat is null
                    ? "Endereço encontrado, mas não foi possível obter a geolocalização"
                    : "Endereço buscado com sucesso";

                return new(address, 200, mensagem);
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }
        public async Task<ResponseApi<List<dynamic>>> GetSearchAsync(string search)
        {
            try
            {
                string[] array = search.Split(" ");
                string nominatimUrl = $"https://nominatim.openstreetmap.org/search?q={string.Join("+", array)}&format=json&limit=10&addressdetails=1&countrycodes=br";

                using var nominatimRequest = new HttpRequestMessage(HttpMethod.Get, nominatimUrl);

                nominatimRequest.Headers.Add("User-Agent", "SeuApp/1.0 (seuemail@exemplo.com)");

                HttpResponseMessage nominatimResponse = await httpClient.SendAsync(nominatimRequest);

                List<dynamic> addresses = [];
                if (nominatimResponse.IsSuccessStatusCode)
                {
                    string nominatimJson = await nominatimResponse.Content.ReadAsStringAsync();
                    using var nominatimDoc = JsonDocument.Parse(nominatimJson);
                    List<JsonElement> results = nominatimDoc.RootElement.EnumerateArray().ToList();

                    foreach (var item in results)
                    {
                        var addressElem = item.TryGetProperty("address", out var addrProp) ? addrProp : default;

                        string road = addressElem.ValueKind != JsonValueKind.Undefined && addressElem.TryGetProperty("road", out var r) ? r.GetString() ?? "" : "";
                        string suburb = addressElem.ValueKind != JsonValueKind.Undefined && (addressElem.TryGetProperty("suburb", out var sub) || addressElem.TryGetProperty("neighbourhood", out sub)) ? sub.GetString() ?? "" : "";
                        string city = addressElem.ValueKind != JsonValueKind.Undefined && (addressElem.TryGetProperty("city", out var c) || addressElem.TryGetProperty("town", out c) || addressElem.TryGetProperty("municipality", out c)) ? c.GetString() ?? "" : "";
                        string state = addressElem.ValueKind != JsonValueKind.Undefined && addressElem.TryGetProperty("state", out var s) ? s.GetString() ?? "" : "";
                        string postcode = addressElem.ValueKind != JsonValueKind.Undefined && addressElem.TryGetProperty("postcode", out var pc) ? pc.GetString() ?? "" : "";
                        
                        string displayName = item.TryGetProperty("display_name", out var dn) ? dn.GetString() ?? "" : "";
                        string name = item.TryGetProperty("name", out var n) ? n.GetString() ?? "" : "";

                        var parts = new List<string>();
                        if (!string.IsNullOrWhiteSpace(road)) parts.Add(road);
                        if (!string.IsNullOrWhiteSpace(suburb)) parts.Add(suburb);
                        if (!string.IsNullOrWhiteSpace(city)) parts.Add(city);
                        if (!string.IsNullOrWhiteSpace(state)) parts.Add(state);
                        if (!string.IsNullOrWhiteSpace(postcode)) parts.Add(postcode);

                        string fullAddress = parts.Count > 0 ? string.Join(", ", parts) : displayName;

                        addresses.Add(new
                        {
                            addressId = item.TryGetProperty("osm_id", out var osmId) ? osmId.GetInt64() : 0,
                            address = !string.IsNullOrWhiteSpace(name) ? name : (parts.Count > 0 ? parts[0] : fullAddress),
                            fullAddress = fullAddress,
                            lat = item.TryGetProperty("lat", out var latProp) ? latProp.GetString() : null,
                            lon = item.TryGetProperty("lon", out var lonProp) ? lonProp.GetString() : null,
                            city = city,
                            state = state
                        });
                    }
                }

                return new(addresses, 200, "Endereços listados com sucesso");
            }
            catch (Exception ex)
            {
                return new(null, 500, $"Ocorreu um erro inesperado. Por favor, tente novamente mais tarde - {ex.Message}");
            }
        }
    }
}