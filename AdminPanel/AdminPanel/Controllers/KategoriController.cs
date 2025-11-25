// MVC PROJESİ - Controllers/KategoriController.cs
using AdminPanel.Models;
using AdminPanelEticaret.Models; // Modellerin olduğu yer
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;

namespace AdminPanelEticaret.Controllers
{
    public class KategoriController : Controller
    {
        // API Adresin (Port numarasına dikkat et!)
        Uri baseAddress = new Uri("https://localhost:7244/api/Kategori");
        private readonly HttpClient _client;

        public KategoriController()
        {
            _client = new HttpClient();
            _client.BaseAddress = baseAddress;
        }

        // LİSTELEME (INDEX)
        public async Task<IActionResult> Index()
        {
            List<KategoriViewModel> list = new List<KategoriViewModel>();
            HttpResponseMessage response = await _client.GetAsync(_client.BaseAddress);

            if (response.IsSuccessStatusCode)
            {
                string data = await response.Content.ReadAsStringAsync();
                list = JsonConvert.DeserializeObject<List<KategoriViewModel>>(data);
            }
            return View(list);
        }

        // EKLEME SAYFASI (GET)
        [HttpGet]
        public IActionResult KategoriEkle()
        {
            return View();
        }

        // EKLEME İŞLEMİ (POST)
        [HttpPost]
        public async Task<IActionResult> KategoriEkle(KategoriViewModel k)
        {
            string data = JsonConvert.SerializeObject(k);
            StringContent content = new StringContent(data, Encoding.UTF8, "application/json");

            HttpResponseMessage response = await _client.PostAsync(_client.BaseAddress, content);

            if (response.IsSuccessStatusCode)
            {
                return RedirectToAction("Index");
            }
            return View(k);
        }

        // SİLME İŞLEMİ
        public async Task<IActionResult> KategoriSil(int id)
        {
            // API'deki Delete metoduna ID gönderiyoruz (api/Kategori/5 gibi)
            HttpResponseMessage response = await _client.DeleteAsync(_client.BaseAddress + "/" + id);

            return RedirectToAction("Index");
        }

        // GÜNCELLEME SAYFASI GETİR (Eski kodunda bu yoktu ama gereklidir)
        // Güncelleme sayfasına tıklayınca mevcut verinin dolu gelmesi için:
        [HttpGet]
        public async Task<IActionResult> KategoriGuncelleSayfasi(int id)
        {
            HttpResponseMessage response = await _client.GetAsync(_client.BaseAddress + "/" + id);

            if (response.IsSuccessStatusCode)
            {
                string data = await response.Content.ReadAsStringAsync();
                var kategori = JsonConvert.DeserializeObject<KategoriViewModel>(data);
                return View("KategoriGuncelle", kategori); // KategoriGuncelle View'ını döndür
            }
            return RedirectToAction("Index");
        }

        // GÜNCELLEME İŞLEMİ (POST)
        [HttpPost]
        public async Task<IActionResult> KategoriGuncelle(KategoriViewModel k)
        {
            string data = JsonConvert.SerializeObject(k);
            StringContent content = new StringContent(data, Encoding.UTF8, "application/json");

            // API'deki PUT metodunu çağırıyoruz
            HttpResponseMessage response = await _client.PutAsync(_client.BaseAddress, content);

            if (response.IsSuccessStatusCode)
            {
                return RedirectToAction("Index");
            }
            return View(k);
        }
    }
}