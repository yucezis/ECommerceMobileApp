using ECommerceBackEnd.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;

namespace ECommerceBackEnd.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class SatislarController : ControllerBase
    {
        private readonly Context _context;

        public SatislarController(Context context)
        {
            _context = context;
        }

        // GET: api/Satislar
        [HttpGet]
        public IActionResult Get()
        {
            var satislar = _context.satislars
                .Include(x => x.Urun)
                .Include(x => x.Musteri)
                .OrderByDescending(x => x.Tarih) // En yeniler üstte
                .ToList();

            var modelListesi = satislar.Select(x => new Satislar
            {
                SatislarId = x.SatislarId,
                Tarih = x.Tarih,
                Adet = x.Adet,
                Fiyat = x.Fiyat,
                ToplamTutar = x.ToplamTutar,
                UrunId = x.UrunId,
                MusteriId = x.MusteriId,

                // --- BURASI EKSİKTİ, EKLENDİ ---
                SiparisNo = x.SiparisNo,      // Artık API bunu gönderecek!
                SiparisDurumu = x.SiparisDurumu,
                // -------------------------------

                Urun = x.Urun == null ? null : new Urun
                {
                    UrunAdi = x.Urun.UrunAdi,
                    UrunMarka = x.Urun.UrunMarka, // Varsa marka da görünsün
                    UrunGorsel = x.Urun.UrunGorsel
                },

                Musteri = x.Musteri == null ? null : new Musteri
                {
                    MusteriAdi = x.Musteri.MusteriAdi,
                    MusteriSoyadi = x.Musteri.MusteriSoyadi
                }
            }).ToList();

            return Ok(modelListesi);
        }

        // POST: api/Satislar/SiparisVer
        // KALICI ÇÖZÜM BU METODDUR
        [HttpPost("SiparisVer")]
        public IActionResult SiparisVer([FromBody] List<Satislar> sepetUrunleri)
        {
            if (sepetUrunleri == null || sepetUrunleri.Count == 0)
            {
                return BadRequest("Sepet boş, sipariş oluşturulamadı.");
            }

            // 1. ADIM: Benzersiz bir Sipariş Numarası üret (Örn: SP-A1B2C3D4)
            string yeniSiparisNo = "SP-" + Guid.NewGuid().ToString().Substring(0, 8).ToUpper();

            DateTime islemTarihi = DateTime.Now;

            try
            {
                // 2. ADIM: Gelen listedeki her ürüne AYNI sipariş numarasını ver
                foreach (var item in sepetUrunleri)
                {
                    // Yeni bir satış nesnesi oluşturuyoruz ki ID çakışması olmasın
                    var yeniSatis = new Satislar
                    {
                        UrunId = item.UrunId,
                        MusteriId = item.MusteriId,
                        Adet = item.Adet,
                        Fiyat = item.Fiyat,
                        ToplamTutar = item.Adet * item.Fiyat,

                        // En Önemli Kısım:
                        SiparisNo = yeniSiparisNo,
                        Tarih = islemTarihi,
                        SiparisDurumu = 0 // 0: Sipariş Alındı (Enum kullanıyorsan onu yaz)
                    };

                    _context.satislars.Add(yeniSatis);
                }

                _context.SaveChanges();

                return Ok(new { mesaj = "Sipariş başarıyla oluşturuldu.", siparisNo = yeniSiparisNo });
            }
            catch (Exception ex)
            {
                return StatusCode(500, "Sipariş oluşturulurken hata: " + ex.Message);
            }
        }

        // Sipariş Durumu Güncelleme Metodu (Admin Paneli İçin Lazım)
        [HttpPut("DurumGuncelle")]
        public IActionResult DurumGuncelle(string siparisNo, int yeniDurumId)
        {
            var siparisUrunleri = _context.satislars.Where(x => x.SiparisNo == siparisNo).ToList();

            if (siparisUrunleri.Count == 0) return NotFound("Sipariş bulunamadı");

            foreach (var urun in siparisUrunleri)
            {
                urun.SiparisDurumu = (SiparisDurum)yeniDurumId; 
            }

            _context.SaveChanges();
            return Ok();
        }
    }
}