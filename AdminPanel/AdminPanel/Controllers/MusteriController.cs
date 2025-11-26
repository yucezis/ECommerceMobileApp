using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json; 
using AdminPanel.Models; 


    public class MusteriController : Controller
    {
        // PORT NUMARASI !!!
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
            using (var client = new HttpClient())
            {
                var responseMusteri = await client.GetAsync($"{_apiUrl}/{id}");
                
                var responseSatis = await client.GetAsync($"{_apiUrl}/SatisGecmisi/{id}");
                
            }
           
            return View(); 
        }
    }
