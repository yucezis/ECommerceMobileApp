using ECommerceBackEnd.Models;
using Microsoft.AspNetCore.Mvc;
using System.Linq;

namespace ECommerceBackEnd.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class KategoriController : ControllerBase
    {
        private readonly Context _context;

        public KategoriController(Context context)
        {
            _context = context;
        }

        [HttpGet]
        public IActionResult Get()
        {
            var values = _context.kategoris.ToList();
            return Ok(values);
        }

        [HttpGet("{id}")]
        public IActionResult Get(int id)
        {
            var value = _context.kategoris.Find(id);
            if (value == null) return NotFound();
            return Ok(value);
        }

        [HttpPost]
        public IActionResult Post([FromBody] Kategori k)
        {
            if (k == null) return BadRequest();

            k.KategoriID = 0;

            _context.kategoris.Add(k);
            _context.SaveChanges();

            return Ok();
        }

        [HttpDelete("{id}")]
        public IActionResult Delete(int id)
        {
            var k = _context.kategoris.Find(id);
            if (k == null) return NotFound();

            _context.kategoris.Remove(k);
            _context.SaveChanges();
            return Ok();
        }

        [HttpPut]
        public IActionResult Put([FromBody] Kategori k)
        {
            Console.WriteLine($"GELEN İSTEK -> ID: {k?.KategoriID} | AD: {k?.KategoriAdi}");

            if (k == null || k.KategoriID == 0)
            {
                Console.WriteLine("HATA: Veri boş veya ID 0 geldi.");
                return BadRequest("Veri alınamadı.");
            }

            var value = _context.kategoris.Find(k.KategoriID);

            if (value == null)
            {
                Console.WriteLine("HATA: Bu ID veritabanında yok.");
                return NotFound();
            }

            value.KategoriAdi = k.KategoriAdi;
            _context.SaveChanges();

            Console.WriteLine("BAŞARILI: Veritabanı güncellendi.");
            return Ok();
        }
    }
}