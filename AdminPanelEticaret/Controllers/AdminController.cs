using AdminPanelEticaret.Models.Siniflar;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;
using System.Linq;

namespace AdminPanelEticaret.Controllers
{
    public class AdminController : Controller
    {
        private readonly Context _c;

        public AdminController(Context context)
        {
            _c = context;
        }

        [HttpGet]
        public IActionResult Index()
        {
            return View();
        }

        [HttpPost]
        public IActionResult Index(Admin admin)
        {
            
            var bilgiler = _c.admins
                .FirstOrDefault(x => x.KullaniciAdi == admin.KullaniciAdi && x.Sifre == admin.Sifre);

            if (bilgiler != null)
            {
                
                HttpContext.Session.SetString("KullaniciAdi", bilgiler.KullaniciAdi);
                HttpContext.Session.SetString("AdminId", bilgiler.AdminId.ToString());

                
                return RedirectToAction("Index", "Istatistik");
            }

            
            ViewBag.Hata = "Kullanıcı adı veya şifre yanlış!";
            return View();
        }

        public IActionResult Logout()
        {
            
            HttpContext.Session.Clear();

            return RedirectToAction("Index", "Admin");
        }

    }
}
