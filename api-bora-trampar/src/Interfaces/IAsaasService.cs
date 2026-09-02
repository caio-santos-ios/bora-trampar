namespace api_bora_trampar.src.Interfaces
{
    public interface IAsaasService
    {
        Task<string> GetOrCreateCustomerAsync(string name, string cpfCnpj, string email, string phone);
        Task<(string paymentId, string qrCodeImage, string qrCodePayload)?> CreatePixPaymentAsync(string customerId, decimal value, string description);
        Task<bool> IsPaymentReceivedAsync(string paymentId);
    }
}
