using Microsoft.AspNetCore.Mvc;
using ECommerceBackEnd.Models; 

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

            if (musteri == null)
            {
                return NotFound("Böyle bir müşteri bulunamadı.");
            }

            return Ok(musteri);
        }
    }
}