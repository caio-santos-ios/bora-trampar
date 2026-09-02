using MailKit.Net.Smtp;
using MimeKit;

namespace api_bora_trampar.src.Handlers
{
    public class MailHandler
    {
        private readonly string EmailFrom = Environment.GetEnvironmentVariable("EMAIL_FROM") ?? "";
        private readonly string Password = Environment.GetEnvironmentVariable("PASSWORD_EMAIL") ?? "";
        public async Task SendMailAsync(string recipient, string subject, string body)
        {
            try
            {
                MimeMessage mensagem = new();
                mensagem.From.Add(MailboxAddress.Parse(EmailFrom));
                mensagem.To.Add(MailboxAddress.Parse(recipient));
                mensagem.Subject = subject;

                mensagem.Body = new TextPart("html")
                {
                    Text = body
                };

                using SmtpClient smtp = new();
                await smtp.ConnectAsync("smtp.gmail.com", 587, MailKit.Security.SecureSocketOptions.StartTls);
                await smtp.AuthenticateAsync(EmailFrom, Password);
                await smtp.SendAsync(mensagem);
                await smtp.DisconnectAsync(true);                
            }
            catch(Exception ex)
            {
                System.Console.WriteLine(ex.Message);
            }
        } 
    }
}