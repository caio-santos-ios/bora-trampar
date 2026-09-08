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
    }
}