using MailKit.Net.Smtp;
using MimeKit;

namespace api_bora_trampar.src.Handlers
{
    // public class MailHandler
    // {
    //     private readonly string EmailFrom = Environment.GetEnvironmentVariable("SMTP_FROM_EMAIL") ?? "";
    //     private readonly string Password = Environment.GetEnvironmentVariable("SMTP_PASSWORD") ?? "";
    //     public async Task<string> SendMailAsync(string recipient, string subject, string body)
    //     {
    //         try
    //         {
    //             MimeMessage mensagem = new();
    //             mensagem.From.Add(MailboxAddress.Parse(EmailFrom));
    //             mensagem.To.Add(MailboxAddress.Parse(recipient));
    //             mensagem.Subject = subject;

    //             mensagem.Body = new TextPart("html")
    //             {
    //                 Text = body
    //             };

    //             using SmtpClient smtp = new();
    //             await smtp.ConnectAsync("smtp.gmail.com", 587, MailKit.Security.SecureSocketOptions.StartTls);
    //             await smtp.AuthenticateAsync(EmailFrom, Password);
    //             await smtp.SendAsync(mensagem);
    //             await smtp.DisconnectAsync(true);   
    //             return "";             
    //         }
    //         catch(Exception ex)
    //         {
    //             return ex.Message;
    //         }
    //     } 
    // }
    public class MailHandler
    {
        private readonly HttpClient _http;
        private readonly string _apiKey = Environment.GetEnvironmentVariable("RESEND_API_KEY") ?? "";

        public async Task<string> SendMailAsync(string recipient, string subject, string body)
        {
            try
            {
                var payload = new
                {
                    from = Environment.GetEnvironmentVariable("SMTP_FROM_EMAIL"),
                    to = new[] { recipient },
                    subject,
                    html = body
                };

                var req = new HttpRequestMessage(HttpMethod.Post, "https://api.resend.com/emails")
                {
                    Content = JsonContent.Create(payload)
                };
                req.Headers.Authorization = new("Bearer", _apiKey);

                var res = await _http.SendAsync(req);
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
}