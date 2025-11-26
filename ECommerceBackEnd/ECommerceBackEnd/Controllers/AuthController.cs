using Microsoft.AspNetCore.Mvc;
using ECommerceBackEnd.Models; // Senin Context ve Modellerinin olduğu yer
using System.Linq;

namespace ECommerceBackEnd.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly Context _context;

        public AuthController(Context context)
        {
            _context = context;
        }

        // --- 2. KISIM BURAYA GELECEK (Eski Login metodunu sil, bunu yapıştır) ---
        [HttpPost("login")]
        public IActionResult Login([FromBody] AdminLoginDto p)
        {
            // Gelen veriyi veritabanında arıyoruz
            var admin = _context.admins.FirstOrDefault(x => x.KullaniciAdi == p.KullaniciAdi && x.Sifre == p.Sifre);

            if (admin != null)
            {
                return Ok(admin); // Bulundu, giriş başarılı
            }
            return NotFound("Kullanıcı adı veya şifre hatalı"); // Bulunamadı
        }
    }

    // --- 1. KISIM (DTO SINIFI) BURAYA (Class'ın dışına, en alta) ---
    public class AdminLoginDto
    {
        public string KullaniciAdi { get; set; }
        public string Sifre { get; set; }
    }
}