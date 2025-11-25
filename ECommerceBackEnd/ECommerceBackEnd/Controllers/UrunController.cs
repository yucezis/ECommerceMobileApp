using ECommerceBackEnd.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace ECommerceBackEnd.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UrunController : ControllerBase
    {
        private readonly Context _context;

        public UrunController(Context context)
        {
            _context = context;
        }

        // LİSTELEME
        [HttpGet]
        public IActionResult Get()
        {
            // Döngüye girmemesi için veriyi seçerek (Select) alıyoruz
            var urunler = _context.uruns
                .Include(x => x.Kategori) // Kategoriyi dahil et
                .Select(x => new Urun
                {
                    UrunId = x.UrunId,
                    UrunAdi = x.UrunAdi,
                    UrunMarka = x.UrunMarka,
                    UrunStok = x.UrunStok,
                    UrunSatisFiyati = x.UrunSatisFiyati,
                    Durum = x.Durum,
                    UrunGorsel = x.UrunGorsel,
                    KategoriID = x.KategoriID,
                    KategoriAdi = x.Kategori.KategoriAdi // Kategori adını buradan alıyoruz
                })
                .ToList();

            return Ok(urunler);
        }

        // TEK ÜRÜN GETİR (ID ile)
        [HttpGet("{id}")]
        public IActionResult Get(int id)
        {
            var urun = _context.uruns.Find(id);
            if (urun == null) return NotFound();
            return Ok(urun);
        }

        // EKLEME
        [HttpPost]
        public IActionResult Post(Urun p)
        {
            p.Durum = true; // Yeni ürün varsayılan olarak aktif olsun
            _context.uruns.Add(p);
            _context.SaveChanges();
            return Ok();
        }

        // SİLME (Senin kodundaki gibi Pasife Çekme işlemi)
        [HttpDelete("{id}")]
        public IActionResult Delete(int id)
        {
            var urun = _context.uruns.Find(id);
            if (urun == null) return NotFound();

            urun.Durum = false; // Veritabanından silmiyoruz, durumunu false yapıyoruz
            _context.SaveChanges();
            return Ok();
        }

        // GÜNCELLEME
        [HttpPut]
        public IActionResult Put(Urun p)
        {
            var urun = _context.uruns.Find(p.UrunId);
            if (urun == null) return NotFound();

            urun.UrunAdi = p.UrunAdi;
            urun.UrunStok = p.UrunStok;
            urun.UrunSatisFiyati = p.UrunSatisFiyati;
            urun.UrunGorsel = p.UrunGorsel;
            urun.KategoriID = p.KategoriID;
            urun.UrunMarka = p.UrunMarka;
            
            _context.SaveChanges();
            return Ok();
        }

        [HttpGet("CokSatanlar")]
        public IActionResult GetCokSatanlar()
        {
            
            var cokSatanlar = _context.uruns
                .Include(u => u.Kategori)
                .OrderByDescending(u => u.satislars.Sum(s => s.Adet))
                .Take(3)
                .ToList();

            
            foreach (var urun in cokSatanlar)
            {
                if (urun.Kategori != null)
                {
                    urun.KategoriAdi = urun.Kategori.KategoriAdi;
                }
            }

            return Ok(cokSatanlar);
        }
    }
}





