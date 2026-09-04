namespace api_bora_trampar.src.Requests._Base
{
    public class GetAllRequest
    {
        public GetAllRequest(IQueryCollection queries)
        {
            foreach (var query in queries)
            {
                QueryParams.Add(query.Key, query.Value!);
            }
        }
        public Dictionary<string, string> QueryParams { get; set; } = [];
    }
}