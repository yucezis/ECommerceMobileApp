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

        [HttpGet]
        public IActionResult Get()
        {
            var urunler = _context.uruns
                .Include(x => x.Kategori)
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
                    KategoriAdi = x.Kategori.KategoriAdi,
                    UrunYazar = x.UrunYazar,
                    IndirimliFiyat = x.IndirimliFiyat,
                    Aciklama = x.Aciklama,
                    UrunStokDurum = x.UrunStokDurum,
                    UrunSayfa = x.UrunSayfa,
                    UrunDil = x.UrunDil
                })
                .ToList();

            return Ok(urunler);
        }

        [HttpGet("{id}")]
        public IActionResult Get(int id)
        {
            var urun = _context.uruns.Find(id);
            if (urun == null) return NotFound();
            return Ok(urun);
        }

        [HttpPost]
        public IActionResult Post(Urun p)
        {
            if (p.Kategori != null) p.Kategori = null;

            if (p.Durum == false) p.Durum = true;

            _context.uruns.Add(p);
            _context.SaveChanges();
            return Ok("Ürün başarıyla eklendi.");
        }

        [HttpDelete("{id}")]
        public IActionResult Delete(int id)
        {
            var urun = _context.uruns.Find(id);
            if (urun == null) return NotFound();
;
            urun.Durum = false;

            _context.SaveChanges();
            return Ok("Ürün silindi (Pasife alındı).");
        }

        [HttpPut]
        public IActionResult Put(Urun p)
        {
            var urun = _context.uruns.Find(p.UrunId);
            if (urun == null) return NotFound();

            urun.UrunAdi = p.UrunAdi;
            urun.UrunMarka = p.UrunMarka;
            urun.UrunYazar = p.UrunYazar;
            urun.UrunStok = p.UrunStok;
            urun.UrunSatisFiyati = p.UrunSatisFiyati;
            urun.IndirimliFiyat = p.IndirimliFiyat;
            urun.UrunGorsel = p.UrunGorsel;
            urun.Aciklama = p.Aciklama;
            urun.Durum = p.Durum;
            urun.UrunStokDurum = p.UrunStokDurum;
            urun.KategoriID = p.KategoriID;

            _context.SaveChanges();
            return Ok("Ürün güncellendi.");
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