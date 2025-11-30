using System.ComponentModel.DataAnnotations;

namespace ECommerceBackEnd.Models
{
    public class Adres
    {
        [Key]
        public int AdresId { get; set; }

        public string Baslik { get; set; } 
        public string Sehir { get; set; }
        public string Ilce { get; set; }
        public string AcikAdres { get; set; }

        public int MusteriId { get; set; }
        public Musteri? Musteri { get; set; }
    }
}
