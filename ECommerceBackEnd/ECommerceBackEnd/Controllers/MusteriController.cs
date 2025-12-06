using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ECommerceBackEnd.Models;
using ECommerceBackEnd.Helpers; 

namespace ECommerceBackEnd.Controllers
{
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
                .Select(x => new Satislar
                {
                    SatislarId = x.SatislarId,
                    Tarih = x.Tarih,
                    Adet = x.Adet,
                    Fiyat = x.Fiyat,
                    ToplamTutar = x.ToplamTutar,
                    SiparisNo = x.SiparisNo,
                    SiparisDurumu = x.SiparisDurumu,
                    UrunId = x.UrunId,
                    Urun = x.Urun,
                    MusteriId = x.MusteriId,
                    TeslimatAdresiId = x.TeslimatAdresiId,
                    TeslimatAdresi = x.TeslimatAdresi,
                    DegerlendirmeYapildiMi = _context.degerlendirmes
                    .Any(d => d.MusteriId == id && d.UrunId == x.UrunId),
                    DegerlendirmeId = _context.degerlendirmes
                    .Where(d => d.MusteriId == id && d.UrunId == x.UrunId)
                    .Select(d => (int?)d.DegerlendirmeId)
                    .FirstOrDefault()
                })
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
                if (musteri.EmailOnayli == false)
                {
                    return BadRequest("Lütfen önce e-posta adresinize gelen kodu onaylayın.");
                }
                return Ok(musteri);
            }

            return NotFound("Kullanıcı adı veya şifre hatalı.");
        }

        [HttpPost]
        public IActionResult Post(Musteri p)
        {
            var varMi = _context.musteris.Any(x => x.MusteriMail == p.MusteriMail);
            if (varMi) return BadRequest("Bu e-posta adresi zaten kullanılıyor.");

            Random rnd = new Random();
            string kod = rnd.Next(100000, 999999).ToString();

            p.Durum = true;
            p.EmailOnayli = false;
            p.OnayKodu = kod;

            _context.musteris.Add(p);
            _context.SaveChanges();

            try
            {
                ECommerceBackEnd.Helpers.MailHelper.MailGonder(p.MusteriMail, p.OnayKodu);
            }
            catch (Exception ex)
            {
                Console.WriteLine("MAIL HATASI: " + ex.ToString());
            }

            return Ok(new { mesaj = "Kayıt başarılı. Lütfen mailinizi doğrulayın.", musteriId = p.MusteriId });
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
                    Adet = item.Adet,
                    Fiyat = item.Fiyat,
                    ToplamTutar = item.Fiyat,
                    Tarih = DateTime.Now,
                    SiparisNo = siparisNo,
                    SiparisDurumu = SiparisDurum.SiparisAlindi,
                    TeslimatAdresiId = model.TeslimatAdresiId
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

        [HttpPut("GuncelleOnayli")]
        public IActionResult GuncelleOnayli([FromBody] GuncellemeModel model)
        {
            var musteri = _context.musteris.Find(model.MusteriVerisi.MusteriId);

            if (musteri == null) return NotFound("Kullanıcı bulunamadı.");

            if (musteri.OnayKodu != model.Kod)
            {
                return BadRequest("Hatalı doğrulama kodu! İşlem iptal edildi.");
            }

            musteri.MusteriAdi = model.MusteriVerisi.MusteriAdi;
            musteri.MusteriSoyadi = model.MusteriVerisi.MusteriSoyadi;
            musteri.MusteriTelNo = model.MusteriVerisi.MusteriTelNo;
            if (!string.IsNullOrEmpty(model.MusteriVerisi.MusteriSifre))
            {
                musteri.MusteriSifre = model.MusteriVerisi.MusteriSifre;
            }

            musteri.OnayKodu = null;

            _context.SaveChanges();

            return Ok(new { mesaj = "Bilgiler başarıyla güncellendi." });
        }

        [HttpPost("Dogrula")]
        public IActionResult Dogrula([FromBody] DogrulamaModel model)
        {
            var musteri = _context.musteris.Find(model.MusteriId);

            if (musteri == null) return NotFound("Kullanıcı bulunamadı.");

            if (musteri.OnayKodu == model.Kod)
            {
                musteri.EmailOnayli = true;
                musteri.OnayKodu = null;
                _context.SaveChanges();
                return Ok("Hesap başarıyla doğrulandı.");
            }
            else
            {
                return BadRequest("Hatalı doğrulama kodu.");
            }
        }

        [HttpPost("KodGonder/{id}")]
        public IActionResult KodGonder(int id)
        {
            var musteri = _context.musteris.Find(id);
            if (musteri == null) return NotFound("Kullanıcı bulunamadı.");

            Random rnd = new Random();
            string kod = rnd.Next(100000, 999999).ToString();

            musteri.OnayKodu = kod;
            _context.SaveChanges();

            try
            {
                ECommerceBackEnd.Helpers.MailHelper.MailGonderGuncelleme(musteri.MusteriMail, kod, musteri.MusteriAdi);
                return Ok("Doğrulama kodu mail adresinize gönderildi.");
            }
            catch (Exception ex)
            {
                return BadRequest("Mail gönderilemedi: " + ex.Message);
            }
        }

        [HttpPost("HesapSilKodGonder/{id}")]
        public IActionResult HesapSilKodGonder(int id)
        {
            var musteri = _context.musteris.Find(id);
            if (musteri == null) return NotFound("Kullanıcı bulunamadı.");

            // Kod üret
            Random rnd = new Random();
            string kod = rnd.Next(100000, 999999).ToString();
            musteri.OnayKodu = kod;
            _context.SaveChanges();

            try
            {
                ECommerceBackEnd.Helpers.MailHelper.MailGonderHesapSilme(musteri.MusteriMail, kod, musteri.MusteriAdi);
                return Ok("Silme onay kodu gönderildi.");
            }
            catch (Exception ex)
            {
                return BadRequest("Mail gönderilemedi: " + ex.Message);
            }
        }

        [HttpPost("HesapSilOnayli")]
        public IActionResult HesapSilOnayli([FromBody] DogrulamaModel model)
        {
            var musteri = _context.musteris.Find(model.MusteriId);
            if (musteri == null) return NotFound("Kullanıcı bulunamadı.");

            if (musteri.OnayKodu == model.Kod)
            {
                musteri.Durum = false; 
                musteri.OnayKodu = null;

                _context.SaveChanges();
                return Ok("Hesabınız başarıyla silindi.");
            }
            else
            {
                return BadRequest("Hatalı doğrulama kodu.");
            }
        }


        [HttpPost("SifremiUnuttum")]
        public IActionResult SifremiUnuttum([FromBody] SifreSifirlamaModel model)
        {
            var musteri = _context.musteris.FirstOrDefault(x => x.MusteriMail == model.Mail);

            if (musteri == null)
            {
                return NotFound("Bu e-posta adresiyle kayıtlı bir kullanıcı bulunamadı.");
            }

            Random rnd = new Random();
            string yeniSifre = rnd.Next(100000, 999999).ToString();

            musteri.MusteriSifre = yeniSifre;
            _context.SaveChanges();

            try
            {
                ECommerceBackEnd.Helpers.MailHelper.MailGonderYeniSifre(musteri.MusteriMail, yeniSifre, musteri.MusteriAdi);
                return Ok("Yeni şifreniz e-posta adresinize gönderildi.");
            }
            catch (Exception ex)
            {
                return BadRequest("Mail gönderilemedi: " + ex.Message);
            }
        }

        public class SifreSifirlamaModel
        {
            public string Mail { get; set; }
        }
        public class DogrulamaModel
        {
            public int MusteriId { get; set; }
            public string Kod { get; set; }
        }

        public class SepetItemDto
        {
            public int UrunId { get; set; }
            public decimal Fiyat { get; set; }

            public int Adet { get; set; }
        }

        public class SepetOnayModel
        {
            public int MusteriId { get; set; }
            public List<SepetItemDto> SepetUrunleri { get; set; }
            public int TeslimatAdresiId { get; set; }
        }
        public class GuncellemeModel
        {
            public Musteri MusteriVerisi { get; set; }
            public string Kod { get; set; }
        }
    }
}