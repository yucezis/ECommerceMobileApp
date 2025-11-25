using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;
using Newtonsoft.Json;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using AdminPanelEticaret.Models;

namespace AdminPanelEticaret.Controllers
{
    public class AdminController : Controller
    {
        // API adresinin ve PORT numarasının doğru olduğundan emin ol (7244)
        private readonly string _apiAdresi = "https://localhost:7244/api/Auth/login";

        [HttpGet]
        public IActionResult Index()
        {
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> Index(AdminViewModel admin)
        {
            // 1. API'ye gidecek veriyi hazırla
            var jsonVeri = JsonConvert.SerializeObject(admin);
            var content = new StringContent(jsonVeri, Encoding.UTF8, "application/json");

            // 2. SSL Ayarı
            var handler = new HttpClientHandler();
            handler.ClientCertificateOptions = ClientCertificateOption.Manual;
            handler.ServerCertificateCustomValidationCallback =
                (httpRequestMessage, cert, cetChain, policyErrors) =>
                {
                    return true;
                };

            // 3. API'ye bağlanıyoruz
            using (var client = new HttpClient(handler))
            {
                var response = await client.PostAsync(_apiAdresi, content);

                // Eğer Başarılıysa (200 OK)
                if (response.IsSuccessStatusCode)
                {
                    var gelenCevap = await response.Content.ReadAsStringAsync();
                    var gelenAdmin = JsonConvert.DeserializeObject<AdminViewModel>(gelenCevap);

                    if (gelenAdmin != null)
                    {
                        HttpContext.Session.SetString("KullaniciAdi", gelenAdmin.KullaniciAdi);

                        if (gelenAdmin.AdminId != 0)
                        {
                            HttpContext.Session.SetString("AdminId", gelenAdmin.AdminId.ToString());
                        }

                        return RedirectToAction("Index", "Istatistik");
                    }
                }
                // --- YENİ EKLENEN KISIM: BAŞARISIZSA (ELSE) ---
                else
                {
                    // API'den gelen gerçek hata mesajını okuyoruz
                    var hataMesaji = await response.Content.ReadAsStringAsync();

                    // Ekrana basıyoruz
                    ViewBag.Hata = $"HATA KODU: {response.StatusCode} - DETAY: {hataMesaji}";
                    return View();
                }
                // ---------------------------------------------
            }

            // Eğer yukarıdaki bloklara hiç girmezse (Bağlantı hatası vs.)
            if (ViewBag.Hata == null) ViewBag.Hata = "Beklenmedik bir hata oluştu.";
            return View();
        }

        public IActionResult Logout()
        {
            HttpContext.Session.Clear();
            return RedirectToAction("Index", "Admin");
        }
    }
}