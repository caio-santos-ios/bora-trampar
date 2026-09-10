namespace api_bora_trampar.src.Requests.Payment
{
    public class CheckPaymentRequest
    {
        public string Event { get; set; } = string.Empty;
        public PaymentRequest Payment { get; set; } = new();
    }
    public class PaymentRequest
    {
        public string Id { get; set; } = string.Empty;
    }
}