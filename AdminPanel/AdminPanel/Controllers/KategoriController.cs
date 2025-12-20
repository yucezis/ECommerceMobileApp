// MVC PROJESİ - Controllers/KategoriController.cs
using AdminPanel.Models;
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
        Uri baseAddress = new Uri("http://localhost:5126/api/Kategori");
        private readonly HttpClient _client;

        public KategoriController()
        {
            _client = new HttpClient();
            _client.BaseAddress = baseAddress;
        }

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

        [HttpGet]
        public IActionResult KategoriEkle()
        {
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> KategoriEkle(KategoriViewModel k)
        {
            k.KategoriID = 0;

            string data = JsonConvert.SerializeObject(k);
            StringContent content = new StringContent(data, Encoding.UTF8, "application/json");

            HttpResponseMessage response = await _client.PostAsync("", content);

            if (response.IsSuccessStatusCode)
            {
                TempData["Mesaj"] = "Kategori başarıyla eklendi.";
            }
            else
            {
                var errorContent = await response.Content.ReadAsStringAsync();
                TempData["Hata"] = $"Hata Oluştu! Kod: {response.StatusCode} | Detay: {errorContent}";
            }

            return RedirectToAction("Index");
        }

        public async Task<IActionResult> KategoriSil(int id)
        {
           
            HttpResponseMessage response = await _client.DeleteAsync(_client.BaseAddress + "/" + id);

            return RedirectToAction("Index");
        }

        [HttpPost]
        public async Task<IActionResult> KategoriGuncelle(KategoriViewModel k)
        {
            var gonderilecekVeri = new
            {
                KategoriID = k.KategoriID,    
                KategoriAdi = k.KategoriAdi  
            };

            string data = JsonConvert.SerializeObject(gonderilecekVeri);
            StringContent content = new StringContent(data, Encoding.UTF8, "application/json");

            HttpResponseMessage response = await _client.PutAsync(_client.BaseAddress, content);

            if (response.IsSuccessStatusCode)
            {
                TempData["Basarili"] = "Kategori başarıyla güncellendi.";
                return RedirectToAction("Index");
            }

            TempData["Hata"] = $"Güncelleme başarısız! Kod: {response.StatusCode}";
            return RedirectToAction("Index");
        }
    }
}