using ECommerceBackEnd.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

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

                Urun = new Urun
                {
                    UrunAdi = x.Urun.UrunAdi,
                                             
                },

                Musteri = new Musteri
                {
                    MusteriAdi = x.Musteri.MusteriAdi,
                    MusteriSoyadi = x.Musteri.MusteriSoyadi
                }
            }).ToList();

            return Ok(modelListesi);
        }
    }
}
