using AdminPanelEticaret.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Newtonsoft.Json;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using System.Linq;
using AdminPanel.Models;
using System;

namespace AdminPanelEticaret.Controllers
{
    public class UrunController : Controller
    {

        private readonly string _apiUrl = "http://localhost:5126/api/Urun";
        private readonly string _apiKategoriUrl = "http://localhost:5126/api/Kategori";

       
        public async Task<IActionResult> Index()
        {
            
            await KategorileriDropdownDoldur();

            List<UrunViewModel> urunler = new List<UrunViewModel>();

            using (var client = new HttpClient())
            {
                var response = await client.GetAsync(_apiUrl);
                if (response.IsSuccessStatusCode)
                {
                    var jsonString = await response.Content.ReadAsStringAsync();
                    urunler = JsonConvert.DeserializeObject<List<UrunViewModel>>(jsonString);
                }
            }

            return View(urunler);
        }


        [HttpPost]
        public async Task<IActionResult> UrunEkle(UrunViewModel p)
        {
            var jsonVeri = JsonConvert.SerializeObject(p);
            var content = new StringContent(jsonVeri, Encoding.UTF8, "application/json");

            using (var client = new HttpClient())
            {
              
                var response = await client.PostAsync(_apiUrl, content);

                if (response.IsSuccessStatusCode)
                {
                    TempData["Basarili"] = "Ürün başarıyla eklendi!";
                    return RedirectToAction("Index");
                }
                else
                {
                    TempData["Hata"] = $"Hata oluştu. API Kodu: {response.StatusCode}";
                    return RedirectToAction("Index");
                }
            }
        }

        public async Task<IActionResult> UrunSil(int id)
        {
            using (var client = new HttpClient())
            {
                await client.DeleteAsync(_apiUrl + "/" + id);
            }
            return RedirectToAction("Index");
        }

        [HttpGet]
        public async Task<IActionResult> UrunGetir(int id)
        {
            await KategorileriDropdownDoldur();

            UrunViewModel urun = null;
            using (var client = new HttpClient())
            {
                var response = await client.GetAsync(_apiUrl + "/" + id);
                if (response.IsSuccessStatusCode)
                {
                    var jsonString = await response.Content.ReadAsStringAsync();
                    urun = JsonConvert.DeserializeObject<UrunViewModel>(jsonString);
                }
            }

            return View("UrunGetir", urun);
        }

        [HttpPost]
        public async Task<IActionResult> UrunGuncelle(UrunViewModel p)
        {
            using (var client = new HttpClient())
            {
                var jsonVeri = JsonConvert.SerializeObject(p);
                var content = new StringContent(jsonVeri, Encoding.UTF8, "application/json");

                var response = await client.PutAsync(_apiUrl, content);

                if (response.IsSuccessStatusCode)
                {
                    return RedirectToAction("Index");
                }
            }
            return RedirectToAction("Index");
        }
        private async Task KategorileriDropdownDoldur()
        {
            List<KategoriViewModel> kategoriler = new List<KategoriViewModel>();

            
            using (var client = new HttpClient())
            {
                string url = "http://localhost:5126/api/Kategori";

                var response = await client.GetAsync(url);

                if (response.IsSuccessStatusCode)
                {
                    var jsonString = await response.Content.ReadAsStringAsync();
                    kategoriler = JsonConvert.DeserializeObject<List<KategoriViewModel>>(jsonString);
                }
            }

            List<SelectListItem> degerler = (from x in kategoriler
                                             select new SelectListItem
                                             {
                                                 Text = x.KategoriAdi,
                                                 Value = x.KategoriID.ToString()
                                             }).ToList();

            ViewBag.Kategoriler = degerler;
        }
    }
}