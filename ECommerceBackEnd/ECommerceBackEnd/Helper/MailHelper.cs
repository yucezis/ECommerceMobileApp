using System.Net;
using System.Net.Mail;

namespace ECommerceBackEnd.Helpers
{
    public class MailHelper
    {
        public static void MailGonder(string aliciMail, string kod)
        {
            try
            {
                SmtpClient client = new SmtpClient("smtp.gmail.com", 587);
                client.EnableSsl = true;
                client.DeliveryMethod = SmtpDeliveryMethod.Network;
                client.UseDefaultCredentials = false;

                client.Credentials = new NetworkCredential("yucezisan@gmail.com", "zzxcgoswwqlbpfcg");

                MailMessage mailMessage = new MailMessage();
                mailMessage.From = new MailAddress("yucezisan@gmail.com", "Books Güvenlik");
                mailMessage.To.Add(aliciMail);
                mailMessage.Subject = "Books Email Doğrulama";
                mailMessage.Body = $"Merhaba,\n\nBooks'a hoş geldiniz! Kaydınızı tamamlamak için doğrulama kodunuz:\n\n{kod}\n\nİyi alışverişler dileriz.";

                client.Send(mailMessage);
            }
            catch (Exception ex)
            {
                Console.WriteLine("Mail hatası: " + ex.Message);
            }
        }

        public static void MailGonderGuncelleme(string aliciMail, string kod, string isim)
        {
            try
            {
                SmtpClient client = new SmtpClient("smtp.gmail.com", 587);
                client.EnableSsl = true;
                client.DeliveryMethod = SmtpDeliveryMethod.Network;
                client.UseDefaultCredentials = false;

                client.Credentials = new NetworkCredential("yucezisan@gmail.com", "zzxcgoswwqlbpfcg");

                MailMessage mailMessage = new MailMessage();
                mailMessage.From = new MailAddress("yucezisan@gmail.com", "Books Güvenlik");
                mailMessage.To.Add(aliciMail);
                mailMessage.Subject = "Profil Güncelleme Onayı";

                mailMessage.Body = $"Merhaba {isim},\n\nProfil bilgilerinizi güncellemek için bir talep aldık.\n" +
                                   $"Değişikliği onaylamak için aşağıdaki kodu kullanınız:\n\n" +
                                   $"{kod}\n\n" +
                                   $"Eğer bu işlemi siz yapmadıysanız lütfen şifrenizi değiştiriniz.\n\nİyi günler.";

                client.Send(mailMessage);
            }
            catch (Exception ex)
            {
                Console.WriteLine("Mail hatası: " + ex.Message);
            }
        }
    }
}