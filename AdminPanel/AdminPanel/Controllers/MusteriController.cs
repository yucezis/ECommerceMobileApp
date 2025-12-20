using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json; 
using AdminPanel.Models;


    public class MusteriController : Controller
    {
        private readonly string _apiUrl = "http://localhost:5126/api/Musteris";

        public async Task<IActionResult> Index()
        {
            List<MusteriViewModel> musteriler = new List<MusteriViewModel>();

            using (var client = new HttpClient())
            {
                var response = await client.GetAsync(_apiUrl);

                if (response.IsSuccessStatusCode)
                {
                    var jsonString = await response.Content.ReadAsStringAsync();
                    musteriler = JsonConvert.DeserializeObject<List<MusteriViewModel>>(jsonString);
                }
            }
            return View(musteriler);
        }

    public async Task<IActionResult> SatisGecmisi(int id)
    {
        List<SatislarViewModel> satislar = new List<SatislarViewModel>();

        using (var client = new HttpClient())
        {
            var response = await client.GetAsync($"{_apiUrl}/SatisGecmisi/{id}");

            if (response.IsSuccessStatusCode)
            {
                var jsonString = await response.Content.ReadAsStringAsync();

                satislar = JsonConvert.DeserializeObject<List<SatislarViewModel>>(jsonString);
            }
        }

        return View(satislar);
    }
}
