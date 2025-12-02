using System.ComponentModel.DataAnnotations;

namespace ECommerceBackEnd.Models
{
    public class Mesaj
    {
        [Key]
        public int MesajId { get; set; }

        public int MusteriId { get; set; } 
        public string Icerik { get; set; }

        public bool GonderenAdminMi { get; set; } 

        public DateTime Tarih { get; set; } = DateTime.Now;
        public bool OkunduMu { get; set; } = false;
    }
}
