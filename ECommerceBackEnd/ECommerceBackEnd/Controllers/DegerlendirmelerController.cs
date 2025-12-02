using ECommerceBackEnd.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace ECommerceBackEnd.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class DegerlendirmelerController : ControllerBase
    {
        private readonly Context _context;

        public DegerlendirmelerController(Context context)
        {
            _context = context;
        }

        [HttpGet("Getir/{urunId}")]
        public IActionResult Getir(int urunId)
        {
            var yorumlar = _context.degerlendirmes
                .Include(x => x.Musteri)
                .Where(x => x.UrunId == urunId && x.Onaylandi == true) 
                .OrderByDescending(x => x.Tarih)
                .Select(x => new
                {
                    x.DegerlendirmeId,
                    x.Puan,
                    x.Yorum,
                    x.Tarih,
                    MusteriAdi = x.Musteri != null ? x.Musteri.MusteriAdi + " " + x.Musteri.MusteriSoyadi : "Anonim"
                })
                .ToList();

            return Ok(yorumlar);
        }

        [HttpPost("Ekle")]
        public IActionResult Ekle([FromBody] Degerlendirme yeniYorum)
        {
            if (yeniYorum == null) return BadRequest("Veri yok");

            var satisKaydi = _context.satislars
                .FirstOrDefault(x => x.MusteriId == yeniYorum.MusteriId
                                  && x.UrunId == yeniYorum.UrunId
                                  && x.SiparisDurumu == SiparisDurum.TeslimEdildi); 

            if (satisKaydi == null)
            {
                return BadRequest("Bu ürünü değerlendirmek için satın almalı ve teslim almalısınız.");
            }


            yeniYorum.Tarih = DateTime.Now;

            if (string.IsNullOrWhiteSpace(yeniYorum.Yorum))
            {
                yeniYorum.Onaylandi = true; 
            }
            else
            {
                yeniYorum.Onaylandi = false;
            }

            _context.degerlendirmes.Add(yeniYorum);
            _context.SaveChanges();

            if (yeniYorum.Onaylandi)
                return Ok("Değerlendirmeniz yayınlandı.");
            else
                return Ok("Yorumunuz admin onayından sonra yayınlanacaktır.");
        }

        [HttpGet("OnayBekleyenler")]
        public IActionResult GetOnayBekleyenler()
        {
            var yorumlar = _context.degerlendirmes
                .Include(x => x.Urun)
                .Include(x => x.Musteri)
                .Where(x => x.Onaylandi == false)
                .OrderByDescending(x => x.Tarih)
                .Select(x => new
                {
                    x.DegerlendirmeId,
                    x.Puan,
                    x.Yorum,
                    x.Tarih,
                    x.Onaylandi,

                    UrunAdi = x.Urun != null ? x.Urun.UrunAdi : "Silinmiş Ürün",
                    MusteriAdi = x.Musteri != null
                ? x.Musteri.MusteriAdi.Substring(0, 2) + "*** " + x.Musteri.MusteriSoyadi.Substring(0, 2) + "***"
                : "Anonim Kullanıcı"
                })
                .ToList();

            return Ok(yorumlar);
        }

        [HttpPost("Onayla/{id}")]
        public IActionResult Onayla(int id)
        {
            var yorum = _context.degerlendirmes.Find(id);
            if (yorum == null) return NotFound();

            yorum.Onaylandi = true;
            _context.SaveChanges();
            return Ok("Onaylandı");
        }

        [HttpDelete("Sil/{id}")]
        public IActionResult Sil(int id)
        {
            var yorum = _context.degerlendirmes.Find(id);
            if (yorum == null) return NotFound();

            _context.degerlendirmes.Remove(yorum);
            _context.SaveChanges();
            return Ok("Silindi");
        }
    }
}