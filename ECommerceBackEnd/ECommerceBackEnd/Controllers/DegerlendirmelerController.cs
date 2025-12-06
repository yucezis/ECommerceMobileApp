using ECommerceBackEnd.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Hosting;
using System;
using System.IO;
using System.Threading.Tasks;

namespace ECommerceBackEnd.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class DegerlendirmelerController : ControllerBase
    {
        private readonly Context _context;
        private readonly IWebHostEnvironment _environment;

        public DegerlendirmelerController(Context context, IWebHostEnvironment environment)
        {
            _context = context;
            _environment = environment;
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
                    x.ResimUrl,
                    MusteriAdi = x.Musteri != null
                        ? x.Musteri.MusteriAdi.Substring(0, 1) + "***"
                        : "Anonim"
                })
                .ToList();

            return Ok(yorumlar);
        }

        [HttpPost("Ekle")]
        public async Task<IActionResult> Ekle([FromBody] Degerlendirme yeniYorum)
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

            bool dahaOnceYorumlamis = _context.degerlendirmes
                .Any(x => x.MusteriId == yeniYorum.MusteriId && x.UrunId == yeniYorum.UrunId);

            if (dahaOnceYorumlamis)
            {
                return BadRequest("Bu ürüne zaten yorum yaptınız.");
            }

            if (!string.IsNullOrEmpty(yeniYorum.ResimBase64))
            {
                try
                {
                    string dosyaAdi = Guid.NewGuid().ToString() + ".jpg";
                    string rootPath = _environment.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");

                    string uploadsFolder = Path.Combine(rootPath, "uploads", "yorumlar");

                    if (!Directory.Exists(uploadsFolder))
                        Directory.CreateDirectory(uploadsFolder);

                    string dosyaYolu = Path.Combine(uploadsFolder, dosyaAdi);
                    byte[] imageBytes = Convert.FromBase64String(yeniYorum.ResimBase64);

                    await System.IO.File.WriteAllBytesAsync(dosyaYolu, imageBytes);

                    yeniYorum.ResimUrl = "/uploads/yorumlar/" + dosyaAdi;
                }
                catch (Exception ex)
                {
                    Console.WriteLine("Resim hatası: " + ex.Message);
                }
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
            await _context.SaveChangesAsync();

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
                    x.ResimUrl,
                    UrunAdi = x.Urun != null ? x.Urun.UrunAdi : "Silinmiş Ürün",
                    MusteriAdi = x.Musteri != null
                        ? x.Musteri.MusteriAdi + " " + x.Musteri.MusteriSoyadi
                        : "Anonim"
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

        [HttpGet("GetirTek/{id}")]
        public IActionResult GetirTek(int id)
        {
            var yorum = _context.degerlendirmes
                .Where(x => x.DegerlendirmeId == id)
                .Select(x => new
                {
                    x.Puan,
                    x.Yorum,
                    x.Tarih,
                    x.Onaylandi,
                    x.ResimUrl
                })
                .FirstOrDefault();

            if (yorum == null) return NotFound("Değerlendirme bulunamadı.");

            return Ok(yorum);
        }
    }
}