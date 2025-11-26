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
        //PORT NUMARASINA DİKKAT
        private readonly string _apiAdresi = "http://localhost:5126/api/Auth/login";

        [HttpGet]
        public IActionResult Index()
        {
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> Index(AdminViewModel admin)
        {
            var jsonVeri = JsonConvert.SerializeObject(admin);
            var content = new StringContent(jsonVeri, Encoding.UTF8, "application/json");

            using (var client = new HttpClient())
            {
                var response = await client.PostAsync(_apiAdresi, content);

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
                else
                {
                    var hataMesaji = await response.Content.ReadAsStringAsync();
                    ViewBag.Hata = $"HATA KODU: {response.StatusCode} - DETAY: {hataMesaji}";
                    return View();
                }
            }

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