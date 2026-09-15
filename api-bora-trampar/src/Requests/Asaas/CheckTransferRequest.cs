namespace api_bora_trampar.src.Requests.Asaas
{
    public class CheckTransferRequest
    {
        public string Event { get; set; } = string.Empty;
        public TransferRequest Transfer { get; set; } = new();
    }
    
    public class TransferRequest
    {
        public string Id { get; set; } = string.Empty;
        public string Status { get; set; } = string.Empty;
        public string TransactionReceiptUrl { get; set; } = string.Empty;
    }
}