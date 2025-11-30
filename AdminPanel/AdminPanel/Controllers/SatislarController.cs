using AdminPanel.Models;
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using System.Text;

namespace AdminPanel.Controllers
{
    public class SatislarController : Controller
    {
        private readonly string _apiUrl = "http://localhost:5126/api";

        public async Task<IActionResult> Index()
        {
            List<SatislarViewModel> hamListe = new List<SatislarViewModel>();

            using (var client = new HttpClient())
            {
                var response = await client.GetAsync($"{_apiUrl}/Satislar");

                if (response.IsSuccessStatusCode)
                {
                    var jsonString = await response.Content.ReadAsStringAsync();
                    // Null gelirse boş liste oluştur
                    hamListe = JsonConvert.DeserializeObject<List<SatislarViewModel>>(jsonString) ?? new List<SatislarViewModel>();
                }
            }

            // --- KRİTİK DÜZELTME BURADA ---
            var islenmisListe = hamListe.Select(x => {
                // Eğer veritabanından SiparisNo NULL geliyorsa,
                // Satırın kendi ID'sini kullanarak geçici bir sipariş no uyduruyoruz.
                // Böylece ekranda "TEMP-123" gibi görünüp kaybolmuyorlar.
                if (string.IsNullOrEmpty(x.SiparisNo))
                {
                    x.SiparisNo = $"NO-YOK-{x.SatislarId}";
                }
                return x;
            }).ToList();

            var gruplanmisListe = islenmisListe
                .GroupBy(x => x.SiparisNo)
                .Select(g => new SiparisGrupViewModel
                {
                    SiparisNo = g.Key,

                    Tarih = g.First().Tarih,
                    Durum = g.First().SiparisDurumu,

                    // Müşteri null kontrolü
                    MusteriAdSoyad = g.First().Musteri != null
                        ? $"{g.First().Musteri.MusteriAdi} {g.First().Musteri.MusteriSoyadi}"
                        : "Misafir Müşteri",

                    ToplamTutar = g.Sum(x => x.Fiyat * x.Adet),

                    Urunler = g.ToList()
                })
                .OrderByDescending(x => x.Tarih)
                .ToList();

            return View(gruplanmisListe);
        }

        public async Task<IActionResult> DurumDegistir(string siparisNo, int durumId)
        {
            using (var client = new HttpClient())
            {
                string url = $"{_apiUrl}/Musteris/SiparisDurumGuncelle?siparisNo={siparisNo}&yeniDurumId={durumId}";
                var content = new StringContent("", Encoding.UTF8, "application/json");
                var response = await client.PutAsync(url, content);

                if (response.IsSuccessStatusCode)
                {
                    TempData["Basarili"] = $"#{siparisNo} güncellendi.";
                }
                else
                {
                    TempData["Hata"] = "Hata oluştu.";
                }
            }
            return RedirectToAction("Index");
        }
    }
}