using ECommerceBackEnd.Models;
using Microsoft.AspNetCore.Mvc;

namespace ECommerceBackEnd.Controllers
{
    public class KartController
    {
        [Route("api/[controller]")]
        [ApiController]
        public class KartlarController : ControllerBase
        {
            private readonly Context _context;

            public KartlarController(Context context)
            {
                _context = context;
            }

            [HttpGet("Listele/{musteriId}")]
            public IActionResult Listele(int musteriId)
            {
                var kartlar = _context.KayitliKartlar
                    .Where(x => x.MusteriId == musteriId)
                    .ToList();

                return Ok(kartlar);
            }

            [HttpPost("Ekle")]
            public IActionResult Ekle([FromBody] KayitliKart yeniKart)
            {
                if (yeniKart == null) return BadRequest("Veri yok");

                var varMi = _context.KayitliKartlar
                    .Any(x => x.KartNumarasi == yeniKart.KartNumarasi && x.MusteriId == yeniKart.MusteriId);

                if (varMi) return BadRequest("Bu kart zaten kayıtlı.");

                _context.KayitliKartlar.Add(yeniKart);
                _context.SaveChanges();

                return Ok(new { mesaj = "Kart kaydedildi.", kartId = yeniKart.KartId });
            }

            [HttpDelete("Sil/{kartId}")]
            public IActionResult Sil(int kartId)
            {
                var kart = _context.KayitliKartlar.Find(kartId);
                if (kart == null) return NotFound("Kart bulunamadı");

                _context.KayitliKartlar.Remove(kart);
                _context.SaveChanges();

                return Ok(new { mesaj = "Kart silindi." });
            }
        }
    }
}
