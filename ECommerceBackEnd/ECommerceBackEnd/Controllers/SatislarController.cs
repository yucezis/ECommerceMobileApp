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

        [HttpGet]
        public IActionResult Get()
        {
            var satislar = _context.satislars
                .Include(x => x.Urun)
                .Include(x => x.Musteri)
                .OrderByDescending(x => x.Tarih) 
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

                
                SiparisNo = x.SiparisNo,      
                SiparisDurumu = x.SiparisDurumu,
               

                Urun = x.Urun == null ? null : new Urun
                {
                    UrunAdi = x.Urun.UrunAdi,
                    UrunMarka = x.Urun.UrunMarka,
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

        [HttpPost("SiparisVer")]
        public IActionResult SiparisVer([FromBody] SiparisIstegiDto istek)
        {
            // 1. BASİT ÖDEME DOĞRULAMASI (MOCK)
            if (string.IsNullOrEmpty(istek.KartNumarasi) || istek.KartNumarasi.Length < 16)
            {
                return BadRequest("Kart numarası geçersiz.");
            }

            
            string yeniSiparisNo = "SP-" + Guid.NewGuid().ToString().Substring(0, 8).ToUpper();
            DateTime islemTarihi = DateTime.Now;

            try
            {
                foreach (var item in istek.SepetUrunleri)
                {
                    var yeniSatis = new Satislar
                    {
                        UrunId = item.UrunId,
                        MusteriId = item.MusteriId,
                        Adet = item.Adet,
                        Fiyat = item.Fiyat,
                        ToplamTutar = item.Adet * item.Fiyat,
                        SiparisNo = yeniSiparisNo,
                        Tarih = islemTarihi,
                        SiparisDurumu = 0
                        // Önemli: CVV veya Kart No buraya kaydedilmez!
                    };
                    _context.satislars.Add(yeniSatis);
                }

                _context.SaveChanges();
                return Ok(new { mesaj = "Ödeme alındı ve sipariş oluşturuldu.", siparisNo = yeniSiparisNo });
            }
            catch (Exception ex)
            {
                return StatusCode(500, "Hata: " + ex.Message);
            }
        }

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