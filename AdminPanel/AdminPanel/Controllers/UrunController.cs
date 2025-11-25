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
        // 1. DÜZELTME: Port numarasını 5126 ve http yaptık (Senin son durumuna göre)
        private readonly string _apiUrl = "http://127.0.0.1:7244/api/Urun";
        private readonly string _apiKategoriUrl = "http://127.0.0.1:7244/api/Kategori";

        // LİSTELEME
        public async Task<IActionResult> Index()
        {
            // 2. DÜZELTME: Sayfa açılırken kategorileri de çekiyoruz ki dropdown hata vermesin
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

        // EKLEME SAYFASI (GET)
        [HttpGet]
        public async Task<IActionResult> UrunEkle()
        {
            await KategorileriDropdownDoldur();
            return View();
        }

        // EKLEME İŞLEMİ (POST)
        [HttpPost]
        public async Task<IActionResult> UrunEkle(UrunViewModel p)
        {
            using (var client = new HttpClient())
            {
                var jsonVeri = JsonConvert.SerializeObject(p);
                var content = new StringContent(jsonVeri, Encoding.UTF8, "application/json");

                var response = await client.PostAsync(_apiUrl, content);

                if (response.IsSuccessStatusCode)
                {
                    return RedirectToAction("Index");
                }
            }

            await KategorileriDropdownDoldur();
            return View(p);
        }

        // SİLME İŞLEMİ
        public async Task<IActionResult> UrunSil(int id)
        {
            using (var client = new HttpClient())
            {
                await client.DeleteAsync(_apiUrl + "/" + id);
            }
            return RedirectToAction("Index");
        }

        // GÜNCELLEME SAYFASI (GET)
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

        // GÜNCELLEME İŞLEMİ (POST)
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
                var response = await client.GetAsync(_apiKategoriUrl);
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

            // 3. DÜZELTME: View tarafı "ViewBag.Kategoriler" bekliyor.
            // Eskiden "ViewBag.dgr1" idi, bunu değiştirdik.
            ViewBag.Kategoriler = degerler;
        }
    }
}