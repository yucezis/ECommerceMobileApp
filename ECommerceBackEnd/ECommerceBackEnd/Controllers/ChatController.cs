using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore; 
using Newtonsoft.Json;
using System.Text;
using ECommerceBackEnd.Models; 

namespace ECommerceBackEnd.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ChatController : ControllerBase
    {
        private readonly string _apiKey = "ai api key buraya";
        private readonly string _baseUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent";

        private readonly Context _context;

        public ChatController(Context context)
        {
            _context = context;
        }

        [HttpPost("Sor")]
        public async Task<IActionResult> Sor([FromBody] ChatModel model)
        {
            if (string.IsNullOrEmpty(model.Mesaj)) return BadRequest("Mesaj boş olamaz.");

            string kullaniciBilgisi = "Misafir Kullanıcı";
            string siparisBilgisi = "Henüz siparişi yok.";

            if (model.MusteriId > 0)
            {
                var musteri = _context.musteris.Find(model.MusteriId);
                if (musteri != null)
                {
                    kullaniciBilgisi = $"{musteri.MusteriAdi} {musteri.MusteriSoyadi}";

                    var sonSiparisNo = _context.satislars
                        .Where(x => x.MusteriId == model.MusteriId && x.SiparisNo != null)
                        .OrderByDescending(x => x.Tarih)
                        .Select(x => x.SiparisNo)
                        .FirstOrDefault();

                    if (sonSiparisNo != null)
                    {
                        var siparisUrunleri = _context.satislars
                            .Where(x => x.SiparisNo == sonSiparisNo)
                            .Include(x => x.Urun) 
                            .ToList();

                        if (siparisUrunleri.Any())
                        {
                            decimal gercekToplam = siparisUrunleri.Sum(x => x.Fiyat * x.Adet);
                            var durum = siparisUrunleri.First().SiparisDurumu;
                            var kitapIsimleri = string.Join(", ", siparisUrunleri.Select(x => x.Urun?.UrunAdi ?? "Kitap"));

                            siparisBilgisi = $"Son Sipariş No: {sonSiparisNo}. " +
                                             $"Durumu: {durum}. " +
                                             $"İçindeki Kitaplar: {kitapIsimleri}. " +
                                             $"Toplam Tutar: {gercekToplam} TL.";
                        }
                    }
                }
            }

            string sistemTalimati = $"Sen 'BookBot' adında bir kitap asistanısın. " +
                                    $"Şu an konuştuğun müşterinin adı: {kullaniciBilgisi}. " +
                                    $"Bu müşterinin veritabanındaki son sipariş bilgisi şöyle: {siparisBilgisi}. " +
                                    $"Eğer kullanıcı 'Siparişim nerede?', 'Kargom ne oldu?' gibi şeyler sorarsa yukarıdaki bilgiyi kullanarak cevap ver. " +
                                    $"Onun dışında kitap önerileri yapabilirsin. Kitaplar, edebiyat ve uygulama içi konular harici sorularda bu konular hakkında konuşamadığını söyle. Samimi ve yardımsever ol."; 

            using (var client = new HttpClient())
            {
                string url = $"{_baseUrl}?key={_apiKey}";

                var requestBody = new
                {
                    contents = new[]
                    {
                        new
                        {
                            parts = new[]
                            {
                                new { text = sistemTalimati + "\n\nKullanıcı Sorusu: " + model.Mesaj }
                            }
                        }
                    }
                };

                var jsonContent = new StringContent(JsonConvert.SerializeObject(requestBody), Encoding.UTF8, "application/json");

                try
                {
                    var response = await client.PostAsync(url, jsonContent);
                    var responseString = await response.Content.ReadAsStringAsync();

                    if (response.IsSuccessStatusCode)
                    {
                        dynamic result = JsonConvert.DeserializeObject(responseString);
                        string cevap = result?.candidates?[0]?.content?.parts?[0]?.text;
                        return Ok(new { Cevap = cevap });
                    }
                    else
                    {
                        return BadRequest($"Google Hatası: {responseString}");
                    }
                }
                catch (Exception ex)
                {
                    return StatusCode(500, $"Sunucu Hatası: {ex.Message}");
                }
            }
        }

        public class ChatModel
        {
            public string Mesaj { get; set; }
            public int MusteriId { get; set; } 
        }
    }
}