using AdminPanelEticaret.Models.Siniflar;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;


namespace AdminPanelEticaret.Controllers
{
    public class UrunController : Controller
    {
        private Context _c;

        public UrunController(Context context)
        {
            _c = context;
        }

        public IActionResult Index()
        {
            ViewBag.Kategoriler = _c.kategoris.Select(k => new SelectListItem
            {
                Text = k.KategoriAdi,
                Value = k.KategoriID.ToString()
            }).ToList();

            var urunler = _c.uruns.Where(u => u.Durum == true || u.Durum == false)
                                  .Include(u => u.Kategori)
                                  .ToList();

            return View(urunler);

        }


        [HttpGet]
        public IActionResult UrunEkle()
        {
            ViewBag.Kategoriler = _c.kategoris.Select(k => new SelectListItem
            {
                Text = k.KategoriAdi,
                Value = k.KategoriID.ToString()
            }).ToList();

            var urunler = _c.uruns.Include(u => u.Kategori).ToList();
            return View(urunler);
        }

        [HttpPost]
        public IActionResult UrunEkle(Urun urun)
        {
            if (ModelState.IsValid)
            {
                _c.uruns.Add(urun);
                _c.SaveChanges();
                return RedirectToAction("Index");

            }

            ViewBag.Kategoriler = _c.kategoris.Select(k => new SelectListItem
            {
                Text = k.KategoriAdi,
                Value = k.KategoriID.ToString()
            }).ToList();

            var urunler = _c.uruns.Include(u => u.Kategori).ToList();
            return View("Index", urunler);
        }

        public ActionResult UrunSil(int id)
        {
            var u = _c.uruns.Find(id);
            u.Durum = false;
            _c.SaveChanges();
            return RedirectToAction("Index");

        }

        public ActionResult UrunGetir(int id)
        {

            List<SelectListItem> dgr1 = (from x in _c.kategoris.ToList()
                                         select new SelectListItem
                                         {
                                             Text = x.KategoriAdi,
                                             Value = x.KategoriID.ToString(),
                                         }).ToList();

            ViewBag.dgr1 = dgr1;

            var urun = _c.uruns.Find(id);
            return View("UrunGetir", urun);
        }

        public ActionResult UrunGuncelle(Urun u)
        {
            var urun = _c.uruns.Find(u.UrunId);
            urun.UrunAdi = u.UrunAdi;
            urun.UrunStok = u.UrunStok;
            urun.UrunSatisFiyati = u.UrunSatisFiyati;
            urun.UrunStokDurum = u.UrunStokDurum;
            urun.IndirimliFiyat = u.IndirimliFiyat;
            urun.Durum = u.Durum;
            urun.UrunYazar = u.UrunYazar;
            urun.UrunMarka = u.UrunMarka;
            urun.UrunGorsel = u.UrunGorsel;
            urun.KategoriID = u.KategoriID;
           
            _c.SaveChanges();
            return RedirectToAction("Index");
        }
    }
}
