using AdminPanel.Models;
using AdminPanelEticaret.Models;
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using System.Collections.Generic;
using System.Net.Http;
using System.Threading.Tasks;

namespace AdminPanelEticaret.Controllers
{
    public class SatislarController : Controller
    {
        // Port numarasına dikkat!
        private readonly string _apiUrl = "http://localhost:5126/api/Satislar";

        public async Task<IActionResult> Index()
        {
            List<SatislarViewModel> satislar = new List<SatislarViewModel>();

            using (var client = new HttpClient())
            {
                var response = await client.GetAsync(_apiUrl);

                if (response.IsSuccessStatusCode)
                {
                    var jsonString = await response.Content.ReadAsStringAsync();
                    satislar = JsonConvert.DeserializeObject<List<SatislarViewModel>>(jsonString);
                }
            }

            return View(satislar);
        }
    }
}