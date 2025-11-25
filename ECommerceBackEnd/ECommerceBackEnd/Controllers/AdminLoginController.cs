using ECommerceBackEnd.Models;
using Microsoft.AspNetCore.Mvc;
using System.Linq;

// Burası MUTFAK. Veritabanına bakar, admin var mı diye kontrol eder.
[Route("api/[controller]")]
[ApiController]
public class AdminLoginController : ControllerBase
{
    private readonly Context _context;

    public AdminLoginController(Context context)
    {
        _context = context;
    }

    [HttpPost]
    public IActionResult GirisKontrol([FromBody] AdminGirisBilgisi gelenBilgi)
    {
        var admin = _context.admins.FirstOrDefault(x => x.KullaniciAdi == gelenBilgi.KullaniciAdi && x.Sifre == gelenBilgi.Sifre);

        if (admin != null)
        {
            return Ok(admin); // Admin bulundu! Bilgilerini gönder.
        }
        return NotFound(); // Bulunamadı.
    }
}

// API'nin gelen veriyi anlaması için basit bir kutu (Class)
public class AdminGirisBilgisi
{
    public string KullaniciAdi { get; set; }
    public string Sifre { get; set; }
}