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
            .Include(x => x.TeslimatAdresi) 
            .OrderByDescending(x => x.Tarih)
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

    [HttpPost]
    public IActionResult Post(Musteri p)
    {
        p.Durum = true;
        _context.musteris.Add(p);
        _context.SaveChanges();
        return Ok("Kayıt başarılı.");
    }

    public class LoginModel
    {
        public string Mail { get; set; }
        public string Sifre { get; set; }
    }

    [HttpPost("SepetOnayla")]
    public IActionResult SepetOnayla([FromBody] SepetOnayModel model)
    {
        if (model.SepetUrunleri == null || model.SepetUrunleri.Count == 0)
        {
            return BadRequest("Sepet boş!");
        }

        string siparisNo = Guid.NewGuid().ToString().Substring(0, 8).ToUpper();

        foreach (var item in model.SepetUrunleri)
        {
            Satislar satis = new Satislar
            {
                MusteriId = model.MusteriId,
                UrunId = item.UrunId, 
                Adet = 1,
                Fiyat = item.Fiyat,  
                ToplamTutar = item.Fiyat,
                Tarih = DateTime.Now,
                SiparisNo = siparisNo,
                SiparisDurumu = SiparisDurum.SiparisAlindi
            };

            _context.satislars.Add(satis);
        }

        _context.SaveChanges();
        return Ok(new { message = "Sipariş alındı.", siparisNo = siparisNo });
    }

    [HttpPut("SiparisDurumGuncelle")]
    public IActionResult SiparisDurumGuncelle(string siparisNo, int yeniDurumId)
    {
        var satislar = _context.satislars.Where(x => x.SiparisNo == siparisNo).ToList();
        if (!satislar.Any()) return NotFound("Sipariş bulunamadı.");

        foreach (var satis in satislar)
        {
            satis.SiparisDurumu = (SiparisDurum)yeniDurumId;
        }
        _context.SaveChanges();
        return Ok("Durum güncellendi.");
    }

    public class SepetItemDto
    {
        public int UrunId { get; set; }
        public decimal Fiyat { get; set; }
    }

    public class SepetOnayModel
    {
        public int MusteriId { get; set; }
        public List<SepetItemDto> SepetUrunleri { get; set; }
    }
}