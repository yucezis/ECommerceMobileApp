using ECommerceBackEnd.Models;
using Microsoft.AspNetCore.Mvc;

namespace ECommerceBackEnd.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class MesajlarController : ControllerBase
    {
        private readonly Context _context;

        public MesajlarController(Context context)
        {
            _context = context;
        }

        [HttpGet("Getir/{musteriId}")]
        public IActionResult Getir(int musteriId)
        {
            var mesajlar = _context.Mesajlar
                .Where(x => x.MusteriId == musteriId)
                .OrderBy(x => x.Tarih)
                .ToList();

            return Ok(mesajlar);
        }

        [HttpPost("Gonder")]
        public IActionResult Gonder([FromBody] Mesaj mesaj)
        {
            if (string.IsNullOrEmpty(mesaj.Icerik)) return BadRequest("Mesaj boş olamaz.");

            mesaj.Tarih = DateTime.Now;
            _context.Mesajlar.Add(mesaj);
            _context.SaveChanges();

            return Ok(new { Durum = "İletildi", MesajId = mesaj.MesajId });
        }

        [HttpGet("Mesajlasanlar")]
        public IActionResult GetMesajlasanlar()
        {
            var musteriIdleri = _context.Mesajlar.Select(x => x.MusteriId).Distinct().ToList();
            var musteriler = _context.musteris
                .Where(x => musteriIdleri.Contains(x.MusteriId))
                .ToList();

            return Ok(musteriler);
        }
    }
}
