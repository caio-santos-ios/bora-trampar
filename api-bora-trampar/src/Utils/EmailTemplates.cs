namespace api_bora_trampar.src.Utils
{
    public static class EmailTemplates
    {
        public static string AccountConfirmation(string name, string code, string link, bool isLoginAttempt = false)
        {
            string greetingName = string.IsNullOrWhiteSpace(name) ? "Cliente / Profissional" : name.Trim();
            string subjectTitle = isLoginAttempt ? "Confirme sua conta para acessar" : "Bem-vindo ao Bora Trampar!";
            string messageIntro = isLoginAttempt
                ? "Identificamos uma tentativa de login na sua conta. Para sua segurança e para liberar o seu acesso, confirme seu endereço de e-mail clicando no botão abaixo ou utilizando o código de validação."
                : "Seu cadastro foi realizado com sucesso! Para ativar sua conta e começar a contratar ou oferecer serviços, confirme seu endereço de e-mail.";

            return $@"<!DOCTYPE html>
<html lang=""pt-BR"">
<head>
    <meta charset=""UTF-8"">
    <meta name=""viewport"" content=""width=device-width, initial-scale=1.0"">
    <title>{subjectTitle}</title>
</head>
<body style=""margin: 0; padding: 0; background-color: #0f172a; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; -webkit-font-smoothing: antialiased;"">
    <table role=""presentation"" border=""0"" cellpadding=""0"" cellspacing=""0"" width=""100%"" style=""background-color: #0f172a; padding: 40px 15px;"">
        <tr>
            <td align=""center"">
                <table role=""presentation"" border=""0"" cellpadding=""0"" cellspacing=""0"" width=""100%"" style=""max-width: 560px; background-color: #1e293b; border-radius: 16px; overflow: hidden; border: 1px solid #334155; box-shadow: 0 10px 25px rgba(0, 0, 0, 0.4);"">
                    <tr>
                        <td style=""background: linear-gradient(135deg, #111827 0%, #1e293b 100%); padding: 32px 30px; text-align: center; border-bottom: 3px solid #f59e0b;"">
                            <div style=""display: inline-block; background-color: #f59e0b; color: #111827; font-weight: 900; font-size: 20px; padding: 8px 18px; border-radius: 10px; letter-spacing: 1.5px; text-transform: uppercase;"">
                                BORA TRAMPAR
                            </div>
                            <p style=""margin: 12px 0 0 0; color: #94a3b8; font-size: 13px; font-weight: 500;"">
                                Conectando profissionais e clientes com agilidade e confiança
                            </p>
                        </td>
                    </tr>
                    <tr>
                        <td style=""padding: 36px 32px; background-color: #1e293b;"">
                            <h1 style=""margin: 0 0 12px 0; color: #f8fafc; font-size: 22px; font-weight: 700; text-align: left;"">
                                {subjectTitle}
                            </h1>
                            <p style=""margin: 0 0 18px 0; color: #cbd5e1; font-size: 15px; line-height: 1.6;"">
                                Olá, <strong style=""color: #f59e0b;"">{greetingName}</strong>!
                            </p>
                            <p style=""margin: 0 0 28px 0; color: #94a3b8; font-size: 14px; line-height: 1.6;"">
                                {messageIntro}
                            </p>
                            <table role=""presentation"" border=""0"" cellpadding=""0"" cellspacing=""0"" width=""100%"" style=""margin-bottom: 28px;"">
                                <tr>
                                    <td align=""center"">
                                        <a href=""{link}"" target=""_blank"" style=""display: inline-block; background-color: #f59e0b; color: #0f172a; font-size: 15px; font-weight: 700; text-decoration: none; padding: 14px 34px; border-radius: 10px; box-shadow: 0 4px 12px rgba(245, 158, 11, 0.35); text-align: center;"">
                                            Confirmar Minha Conta
                                        </a>
                                    </td>
                                </tr>
                            </table>
                            <div style=""background-color: #0f172a; border: 1px dashed #475569; border-radius: 12px; padding: 20px; text-align: center; margin-bottom: 28px;"">
                                <p style=""margin: 0 0 8px 0; color: #94a3b8; font-size: 12px; font-weight: 600; text-transform: uppercase; letter-spacing: 1px;"">
                                    Ou informe o código no aplicativo
                                </p>
                                <div style=""color: #f59e0b; font-size: 30px; font-weight: 800; letter-spacing: 8px; font-family: 'Courier New', Courier, monospace;"">
                                    {code}
                                </div>
                            </div>
                            <div style=""border-top: 1px solid #334155; padding-top: 20px;"">
                                <p style=""margin: 0 0 6px 0; color: #64748b; font-size: 12px;"">
                                    Se o botão acima não funcionar, copie e cole o link abaixo em seu navegador:
                                </p>
                                <p style=""margin: 0; word-break: break-all;"">
                                    <a href=""{link}"" style=""color: #38bdf8; font-size: 12px; text-decoration: underline;"">{link}</a>
                                </p>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <td style=""background-color: #0f172a; padding: 24px 30px; text-align: center; border-top: 1px solid #334155;"">
                            <p style=""margin: 0 0 6px 0; color: #64748b; font-size: 12px;"">
                                Se você não solicitou este e-mail, nenhuma ação é necessária e você pode desconsiderá-lo com segurança.
                            </p>
                            <p style=""margin: 0; color: #475569; font-size: 11px;"">
                                &copy; {DateTime.UtcNow.Year} Bora Trampar. Todos os direitos reservados.
                            </p>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>";
        }
    }
}
