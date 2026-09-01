namespace api_bora_trampar.src.Requests.Base
{
    public class RequestBase
    {
        public string CreatedBy { get; set; } = string.Empty;
        public string UpdatedBy { get; set; } = string.Empty;
        public string DeletedBy { get; set; } = string.Empty;
    }
}