using AdminPanel.Models;
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using System.Text;

namespace AdminPanel.Controllers
{
    public class DestekController : Controller
    {
        private readonly string _apiUrl = "http://localhost:5126/api";

        public async Task<IActionResult> Index()
        {
            List<MusteriViewModel> musteriler = new List<MusteriViewModel>();

            using (var client = new HttpClient())
            {
                var response = await client.GetAsync($"{_apiUrl}/Mesajlar/Mesajlasanlar");

                if (response.IsSuccessStatusCode)
                {
                    var jsonString = await response.Content.ReadAsStringAsync();
                    musteriler = JsonConvert.DeserializeObject<List<MusteriViewModel>>(jsonString);
                }
            }

            return View(musteriler);
        }

        public async Task<IActionResult> Sohbet(int musteriId)
        {
            var model = new AdminChatViewModel();

            using (var client = new HttpClient())
            {
                var musResponse = await client.GetAsync($"{_apiUrl}/Musteris/{musteriId}");
                if (musResponse.IsSuccessStatusCode)
                {
                    var musJson = await musResponse.Content.ReadAsStringAsync();
                    model.Musteri = JsonConvert.DeserializeObject<MusteriViewModel>(musJson);
                }

                var msgResponse = await client.GetAsync($"{_apiUrl}/Mesajlar/Getir/{musteriId}");
                if (msgResponse.IsSuccessStatusCode)
                {
                    var msgJson = await msgResponse.Content.ReadAsStringAsync();
                    model.Mesajlar = JsonConvert.DeserializeObject<List<MesajViewModel>>(msgJson);
                }
            }

            return View(model);
        }

        [HttpPost]
        public async Task<IActionResult> Gonder(int musteriId, string mesajIcerik)
        {
            if (string.IsNullOrEmpty(mesajIcerik)) return BadRequest();

            var yeniMesaj = new
            {
                MusteriId = musteriId,
                Icerik = mesajIcerik,
                GonderenAdminMi = true
            };

            using (var client = new HttpClient())
            {
                var content = new StringContent(JsonConvert.SerializeObject(yeniMesaj), Encoding.UTF8, "application/json");
                await client.PostAsync($"{_apiUrl}/Mesajlar/Gonder", content);
            }
            
            return Ok();
        }

        public async Task<IActionResult> MesajlariGetir(int musteriId)
        {
            List<MesajViewModel> mesajlar = new List<MesajViewModel>();

            using (var client = new HttpClient())
            {
                var response = await client.GetAsync($"{_apiUrl}/Mesajlar/Getir/{musteriId}");
                if (response.IsSuccessStatusCode)
                {
                    var jsonString = await response.Content.ReadAsStringAsync();
                    mesajlar = JsonConvert.DeserializeObject<List<MesajViewModel>>(jsonString);
                }
            }

            return PartialView("_MesajlarPartial", mesajlar);
        }

    }
}