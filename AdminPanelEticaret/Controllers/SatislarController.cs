using AdminPanelEticaret.Models.Siniflar;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;

namespace AdminPanelEticaret.Controllers
{
    public class SatislarController : Controller
    {
        private readonly Context _c;

        public SatislarController(Context context)
        {
            _c = context;
        }

        public IActionResult Index()
        {
            var degerler = _c.satislars.Include(s => s.Urun)
                                       .Include(s => s.Musteri)
                                       .ToList();

            return View(degerler);
        }

    }
}
