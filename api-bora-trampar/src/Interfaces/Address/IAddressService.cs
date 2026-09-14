using api_bora_trampar.src.Models.Base;

namespace api_bora_trampar.src.Interfaces.Address
{
    public interface IAddressService
    {
        public Task<ResponseApi<dynamic?>> GetByZipCodeAsync(string zipCode);
        public Task<ResponseApi<List<dynamic>>> GetSearchAsync(string search);
    }
}