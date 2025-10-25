﻿using AdminPanelEticaret.Models.Siniflar;
using Microsoft.AspNetCore.Mvc;

namespace AdminPanelEticaret.Controllers
{
    public class IstatistikController : Controller
    {
        private readonly Context _c;

        public IstatistikController(Context context)
        {
            _c = context;
        }

        public IActionResult Index()
        {

            ViewBag.UrunSayisi = _c.uruns.Count();


            ViewBag.ToplamSatis = _c.satislars
                .Sum(s => (decimal?)s.ToplamTutar) ?? 0;


            ViewBag.KullaniciSayisi = _c.musteris.Count();


            //ViewBag.FavoriSayisi = _c.favoris.Count();


            ViewBag.DusukStokAdedi = _c.uruns.Count(u => u.UrunStok < 10);


            var cokSatanlar = _c.satislars
                .GroupBy(d => d.UrunId)
                .Select(g => new
                {
                    UrunAdi = g.First().Urun.UrunAdi,
                    Adet = g.Sum(x => x.Adet)
                })
                .OrderByDescending(x => x.Adet)
                .Take(5)
                .ToList();

            ViewBag.CokSatanlar = cokSatanlar;

            ViewBag.ToplamStok = _c.uruns.Sum(u => (int?)u.UrunStok) ?? 0;

            ViewBag.BugunkuSatis = _c.satislars
            .Where(s => s.Tarih.Date == DateTime.Today)
            .Sum(s => (decimal?)s.ToplamTutar) ?? 0;



            return View();

        }
    }
}
