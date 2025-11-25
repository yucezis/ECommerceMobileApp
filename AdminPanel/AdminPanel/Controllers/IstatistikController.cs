using AdminPanel.Models;
using AdminPanelEticaret.Models; // DashboardViewModel burada olmalı
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using System.Net.Http;
using System.Threading.Tasks;

namespace AdminPanelEticaret.Controllers
{
    public class IstatistikController : Controller
    {
        // API Adresini buraya yaz (Port numarasına dikkat et)
        private readonly string _apiBaseUrl = "https://localhost:7244/api/Istatistik/get-dashboard-data";

        public async Task<IActionResult> Index()
        {
            using (var httpClient = new HttpClient())
            {
                var response = await httpClient.GetAsync(_apiBaseUrl);

                if (response.IsSuccessStatusCode)
                {
                    var jsonString = await response.Content.ReadAsStringAsync();

                    // API'den gelen paketi açıyoruz
                    var data = JsonConvert.DeserializeObject<DashboardViewModel>(jsonString);

                    if (data != null)
                    {
                        // View'in bozulmaması için verileri ViewBag'e geri yüklüyoruz
                        ViewBag.UrunSayisi = data.UrunSayisi;
                        ViewBag.ToplamSatis = data.ToplamSatis;
                        ViewBag.KullaniciSayisi = data.KullaniciSayisi;
                        ViewBag.DusukStokAdedi = data.DusukStokAdedi;
                        ViewBag.CokSatanlar = data.CokSatanlar; // Liste olarak gider
                        ViewBag.ToplamStok = data.ToplamStok;
                        ViewBag.BugunkuSatis = data.BugunkuSatis;
                    }
                }
                else
                {
                    // Hata durumunda varsayılan değerler atayabilirsin
                    ViewBag.UrunSayisi = 0;
                    // ...
                }
            }

            return View();
        }
    }
}