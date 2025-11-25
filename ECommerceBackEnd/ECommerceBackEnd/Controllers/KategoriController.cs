using ECommerceBackEnd.Models;
using Microsoft.AspNetCore.Mvc;

namespace ECommerceBackEnd.Controllers
{
    // API PROJESİ - Controllers/KategoriController.cs
    [Route("api/[controller]")]
    [ApiController]
    public class KategoriController : ControllerBase
    {
        private readonly Context _context;

        public KategoriController(Context context)
        {
            _context = context;
        }

        // LİSTELEME
        [HttpGet]
        public IActionResult Get()
        {
            var values = _context.kategoris.ToList();
            return Ok(values);
        }

        // ID'YE GÖRE GETİR (Güncelleme ekranı için gerekecek)
        [HttpGet("{id}")]
        public IActionResult Get(int id)
        {
            var value = _context.kategoris.Find(id);
            if (value == null) return NotFound();
            return Ok(value);
        }

        // EKLEME
        [HttpPost]
        public IActionResult Post(Kategori k)
        {
            _context.kategoris.Add(k);
            _context.SaveChanges();
            return Ok();
        }

        // SİLME
        [HttpDelete("{id}")]
        public IActionResult Delete(int id)
        {
            var k = _context.kategoris.Find(id);
            if (k == null) return NotFound();

            _context.kategoris.Remove(k);
            _context.SaveChanges();
            return Ok();
        }

        // GÜNCELLEME
        [HttpPut]
        public IActionResult Put(Kategori k)
        {
            var value = _context.kategoris.Find(k.KategoriID);
            if (value == null) return NotFound();

            value.KategoriAdi = k.KategoriAdi;
            _context.SaveChanges();
            return Ok();
        }
    }
}
