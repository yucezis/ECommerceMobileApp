using AdminPanel.Models;
using AdminPanelEticaret.Models; // ViewModel'in olduğu yer
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using System.Collections.Generic;
using System.Net.Http;
using System.Threading.Tasks;

namespace AdminPanelEticaret.Controllers
{
    public class SatislarController : Controller
    {
        // API Adresi (Port numarasına dikkat!)
        private readonly string _apiUrl = "https://localhost:7244/api/Satislar";

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