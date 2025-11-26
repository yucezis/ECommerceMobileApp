using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ECommerceBackEnd.Models; 

[Route("api/[controller]")]
[ApiController]
public class MusterisController : ControllerBase
{
    private readonly Context _context;

    public MusterisController(Context context)
    {
        _context = context;
    }

    [HttpGet]
    public IActionResult GetMusteriler()
    {
        var musteriler = _context.musteris.ToList();
        return Ok(musteriler);
    }

    [HttpGet("{id}")]
    public IActionResult GetMusteri(int id)
    {
        var musteri = _context.musteris.Find(id);
        if (musteri == null) return NotFound();
        return Ok(musteri);
    }

    [HttpGet("SatisGecmisi/{id}")]
    public IActionResult GetSatisGecmisi(int id)
    {
        var satislar = _context.satislars
            .Include(s => s.Urun)
            .Where(s => s.MusteriId == id)
            .ToList();

        return Ok(satislar);
    }

    [HttpPost("Login")]
    public IActionResult Login([FromBody] LoginModel model)
    {
        var musteri = _context.musteris
            .FirstOrDefault(x => x.MusteriMail == model.Mail && x.MusteriSifre == model.Sifre);

        if (musteri != null)
        {
            return Ok(musteri);
        }

        return NotFound("Kullanıcı adı veya şifre hatalı.");
    }

    public class LoginModel
    {
        public string Mail { get; set; }
        public string Sifre { get; set; }
    }
}