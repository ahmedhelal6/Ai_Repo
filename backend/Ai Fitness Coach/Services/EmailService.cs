using System.Net;
using System.Net.Mail;

namespace Ai_Fitness_Coach.Services
{
    public class EmailService : IEmailService
    {
        private readonly IConfiguration _config;

        public EmailService(IConfiguration config)
        {
            _config = config;
        }

        public async Task SendOtpEmailAsync(string toEmail, string otp)
        {
            var fromEmail = _config["Email:Username"];
            var password = _config["Email:Password"];

            var smtpClient = new SmtpClient("smtp.gmail.com")
            {
                Port = 587,
                Credentials = new NetworkCredential(fromEmail, password),
                EnableSsl = true
            };

            string htmlBody = $@"
<!DOCTYPE html>
<html>
<head>
    <meta charset='UTF-8'>
</head>

<body style='margin:0; padding:0; background-color:#0b0b0b; font-family:Arial,sans-serif;'>

    <table width='100%' cellpadding='0' cellspacing='0'
           style='background:#0b0b0b; padding:40px 0;'>

        <tr>
            <td align='center'>

                <table width='600' cellpadding='0' cellspacing='0'
                       style='background:#ffffff;
                              border-radius:18px;
                              overflow:hidden;'>

                    <!-- HEADER -->
                    <tr>
                        <td style='background:#000000;
                                   padding:35px;
                                   text-align:center;'>

                            <h1 style='color:#ffffff;
                                       margin:0;
                                       font-size:36px;'>
                                AI Fitness Coach
                            </h1>

                            <p style='color:#ff0000;
                                      margin-top:10px;
                                      font-size:18px;
                                      letter-spacing:2px;'>
                                STRONGER EVERY DAY
                            </p>

                        </td>
                    </tr>

                    <!-- BODY -->
                    <tr>
                        <td style='padding:50px 40px;
                                   text-align:center;'>

                            <h2 style='font-size:34px;
                                       margin-top:0;
                                       color:#111111;'>
                                Verify Your Email
                            </h2>

                            <p style='font-size:18px;
                                      color:#555555;
                                      line-height:30px;'>

                                Welcome to AI Fitness Coach.
                                <br>
                                Use the verification code below
                                to continue.

                            </p>

                            <!-- OTP BOX -->
                            <div style='margin:45px auto;
                                        background:#0d0d0d;
                                        border:2px solid #ff0000;
                                        border-radius:16px;
                                        padding:28px 20px;
                                        width:80%;'>

                                <span style='color:#ff0000;
                                             font-size:52px;
                                             font-weight:bold;
                                             letter-spacing:15px;'>

                                    {otp}

                                </span>

                            </div>

                            <!-- EXPIRE -->
                            <p style='font-size:16px;
                                      color:#777777;'>

                                This code expires in
                                <strong style='color:#ff0000;'>
                                    5 minutes
                                </strong>

                            </p>

                            <!-- SECURITY -->
                            <div style='margin-top:40px;
                                        background:#f5f5f5;
                                        border-radius:12px;
                                        padding:25px;
                                        text-align:left;'>

                                <h3 style='margin-top:0;
                                           color:#111111;'>
                                    Security Notice
                                </h3>

                                <p style='margin-bottom:0;
                                          color:#666666;
                                          line-height:26px;'>

                                    If you did not request this code,
                                    you can safely ignore this email.

                                </p>

                            </div>

                        </td>
                    </tr>

                    <!-- FOOTER -->
                    <tr>
                        <td style='background:#000000;
                                   padding:30px;
                                   text-align:center;'>

                            <p style='color:#888888;
                                      margin:0;
                                      font-size:14px;'>

                                © 2026 AI Fitness Coach

                            </p>

                            <p style='color:#ff0000;
                                      margin-top:10px;
                                      font-size:16px;
                                      font-weight:bold;'>

                                Smart Training. Better Results.

                            </p>

                        </td>
                    </tr>

                </table>

            </td>
        </tr>

    </table>

</body>
</html>";
            var mail = new MailMessage
            {
                From = new MailAddress(fromEmail, "AI Fitness Coach"),
                Subject = "Your AI Fitness Coach Verification Code",
                Body = htmlBody,
                IsBodyHtml = true
            };

            mail.To.Add(toEmail);

            await smtpClient.SendMailAsync(mail);
        }
    }
}