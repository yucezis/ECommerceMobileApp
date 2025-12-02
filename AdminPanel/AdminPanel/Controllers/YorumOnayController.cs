using AdminPanel.Models;
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using System.Text;

namespace AdminPanel.Controllers
{
    public class YorumOnayController : Controller
    {
        private readonly string _apiUrl = "http://localhost:5126/api"; 

        public async Task<IActionResult> Index()
        {
            List<DegerlendirmeViewModel> onaysizlar = new List<DegerlendirmeViewModel>();

            using (var client = new HttpClient())
            {
                var response = await client.GetAsync($"{_apiUrl}/Degerlendirmeler/OnayBekleyenler");

                if (response.IsSuccessStatusCode)
                {
                    var jsonString = await response.Content.ReadAsStringAsync();
                    onaysizlar = JsonConvert.DeserializeObject<List<DegerlendirmeViewModel>>(jsonString);
                }
            }

            return View(onaysizlar);
        }

        [HttpPost]
        public async Task<IActionResult> Onayla(int id)
        {
            using (var client = new HttpClient())
            {
                await client.PostAsync($"{_apiUrl}/Degerlendirmeler/Onayla/{id}", null);
            }
            return RedirectToAction("Index");
        }

        [HttpPost]
        public async Task<IActionResult> Sil(int id)
        {
            using (var client = new HttpClient())
            {
                await client.DeleteAsync($"{_apiUrl}/Degerlendirmeler/Sil/{id}");
            }
            return RedirectToAction("Index");
        }
    }
}