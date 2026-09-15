namespace api_bora_trampar.src.Requests.Asaas
{
    public class TransferPixRequest
    {
        public decimal Value { get; set; }
        public string PixAddressKey { get; set; } = string.Empty;
        public string PixAddressKeyType { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
    }
}