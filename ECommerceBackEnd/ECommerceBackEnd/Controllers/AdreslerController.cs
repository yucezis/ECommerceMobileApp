using ECommerceBackEnd.Models;
using Microsoft.AspNetCore.Mvc;

namespace ECommerceBackEnd.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AdreslerController : ControllerBase
    {
        private readonly Context _context;

        public AdreslerController(Context context)
        {
            _context = context;
        }

        [HttpGet("Listele/{musteriId}")]
        public IActionResult Listele(int musteriId)
        {
            var adresler = _context.Adresler
                .Where(x => x.MusteriId == musteriId)
                .ToList();

            return Ok(adresler);
        }

        [HttpPost("Ekle")]
        public IActionResult Ekle([FromBody] Adres yeniAdres)
        {
            if (yeniAdres == null) return BadRequest("Geçersiz veri");

            _context.Adresler.Add(yeniAdres);
            _context.SaveChanges();

            return Ok(new { mesaj = "Adres başarıyla eklendi.", adresId = yeniAdres.AdresId });
        }

        [HttpDelete("Sil/{adresId}")]
        public IActionResult Sil(int adresId)
        {
            var adres = _context.Adresler.Find(adresId);
            if (adres == null) return NotFound("Adres bulunamadı");

            _context.Adresler.Remove(adres);
            _context.SaveChanges();

            return Ok(new { mesaj = "Adres silindi." });
        }
    }
}
