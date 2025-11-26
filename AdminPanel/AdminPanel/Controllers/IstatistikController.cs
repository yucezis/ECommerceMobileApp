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
        //  (Port numarasına dikkat et)
        private readonly string _apiBaseUrl = "http://localhost:5126/api/Istatistik/get-dashboard-data";

        public async Task<IActionResult> Index()
        {
            using (var httpClient = new HttpClient())
            {
                var response = await httpClient.GetAsync(_apiBaseUrl);

                if (response.IsSuccessStatusCode)
                {
                    var jsonString = await response.Content.ReadAsStringAsync();

                    var data = JsonConvert.DeserializeObject<DashboardViewModel>(jsonString);

                    if (data != null)
                    {
                        ViewBag.UrunSayisi = data.UrunSayisi;
                        ViewBag.ToplamSatis = data.ToplamSatis;
                        ViewBag.KullaniciSayisi = data.KullaniciSayisi;
                        ViewBag.DusukStokAdedi = data.DusukStokAdedi;
                        ViewBag.CokSatanlar = data.CokSatanlar; 
                        ViewBag.ToplamStok = data.ToplamStok;
                        ViewBag.BugunkuSatis = data.BugunkuSatis;
                    }
                }
                else
                {
                    ViewBag.UrunSayisi = 0;
                   
                }
            }

            return View();
        }
    }
}