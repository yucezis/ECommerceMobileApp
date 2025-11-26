using ECommerceBackEnd.Models;
using Microsoft.AspNetCore.Mvc;

namespace ECommerceBackEnd.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class IstatistikController : ControllerBase
    {
        private readonly Context _context;

        public IstatistikController(Context context)
        {
            _context = context;
        }

        [HttpGet("get-dashboard-data")]
        public IActionResult GetDashboardData()
        {
            var model = new Dashboard();

            // 1. Ürün Sayısı
            model.UrunSayisi = _context.uruns.Count();

            // 2. Toplam Satış
            model.ToplamSatis = _context.satislars.Sum(s => (decimal?)s.ToplamTutar) ?? 0;

            // 3. Kullanıcı Sayısı
            model.KullaniciSayisi = _context.musteris.Count();

            // 4. Düşük Stok
            model.DusukStokAdedi = _context.uruns.Count(u => u.UrunStok < 10);

            // 5. Toplam Stok
            model.ToplamStok = _context.uruns.Sum(u => (int?)u.UrunStok) ?? 0;

            // 6. Bugünkü Satış
            model.BugunkuSatis = _context.satislars
                .Where(s => s.Tarih.Date == DateTime.Today)
                .Sum(s => (decimal?)s.ToplamTutar) ?? 0;

            // 7. Çok Satanlar (Burada Anonymous Type yerine sınıf kullanıyoruz)
            model.CokSatanlar = _context.satislars
                .GroupBy(d => d.UrunId)
                .Select(g => new CokSatanUrun
                {
                    UrunAdi = g.First().Urun.UrunAdi,
                    Adet = g.Sum(x => x.Adet)
                })
                .OrderByDescending(x => x.Adet)
                .Take(5)
                .ToList();

            return Ok(model); // Tüm veriyi tek pakette döndür
        }
    }
}
