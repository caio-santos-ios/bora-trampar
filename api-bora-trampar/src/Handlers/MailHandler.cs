public class MailHandler(HttpClient http)
{
    private readonly string _apiKey = Environment.GetEnvironmentVariable("RESEND_API_KEY") ?? "";
    private readonly string _fromEmail = Environment.GetEnvironmentVariable("SMTP_FROM_EMAIL") ?? "";
    public async Task<string> SendMailAsync(string recipient, string subject, string body)
    {
        try
        {
            var payload = new
            {
                from = _fromEmail,
                to = new[] { recipient },
                subject,
                html = body
            };

            var req = new HttpRequestMessage(HttpMethod.Post, "https://api.resend.com/emails")
            {
                Content = JsonContent.Create(payload)
            };
            req.Headers.Authorization = new("Bearer", _apiKey);

            var res = await http.SendAsync(req);
            if (!res.IsSuccessStatusCode)
                return await res.Content.ReadAsStringAsync();

            return "";
        }
        catch (Exception ex)
        {
            return ex.Message;
        }
    }
}