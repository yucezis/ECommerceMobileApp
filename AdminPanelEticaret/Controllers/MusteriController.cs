using AdminPanelEticaret.Models.Siniflar;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AdminPanelEticaret.Controllers
{
    public class MusteriController : Controller
    {
        private readonly Context _c;

        public MusteriController(Context context)
        {
            _c = context;
        }
        public IActionResult Index()
        {
            var m = _c.musteris.ToList();
            return View(m);
        }

        public IActionResult SatisGecmisi(int id)
        {
            // Müşteriyi bul
            var musteri = _c.musteris
                                  .FirstOrDefault(m => m.MusteriId == id);

            if (musteri == null)
                return NotFound();

            // Müşteriye ait satışları bul
            var satislar = _c.satislars
                                   .Include(s => s.Urun) // Ürün bilgilerini de çekelim
                                   .Where(s => s.MusteriId == id)
                                   .ToList();

            // Verileri ViewBag ile gönderelim
            ViewBag.MusteriAdSoyad = musteri.MusteriAdi + " " + musteri.MusteriSoyadi;
            ViewBag.MusteriMail = musteri.MusteriMail;

            return View(satislar);
        }
    }
}
