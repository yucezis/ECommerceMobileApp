using AdminPanelEticaret.Models.Siniflar;
using Microsoft.AspNetCore.Mvc;

namespace AdminPanelEticaret.Controllers
{
    public class KategoriController : Controller
    {
        private readonly Context _c;

        public KategoriController(Context context)
        {
            _c = context;
        }
        public IActionResult Index()
        {
            var degerler = _c.kategoris.ToList();
            return View(degerler);
        }

        [HttpGet]
        public ActionResult KategoriEkle()
        {
            return View();
        }
        [HttpPost]
        public ActionResult KategoriEkle(Kategori k)
        {
            _c.kategoris.Add(k);
            _c.SaveChanges();
            return RedirectToAction("Index");
        }

        public ActionResult KategoriSil(int id)
        {
            var k = _c.kategoris.Find(id);
            _c.kategoris.Remove(k);
            _c.SaveChanges();
            return RedirectToAction("Index", "Kategori");
        }

        
        public ActionResult KategoriGuncelle(Kategori k)
        {
            var kategori = _c.kategoris.Find(k.KategoriID);
            
            kategori.KategoriAdi = k.KategoriAdi;
            _c.SaveChanges();

            return RedirectToAction("Index");
        }

        
    }
}
