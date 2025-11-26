using System.ComponentModel.DataAnnotations;

namespace ECommerceBackEnd.Models
{
    public class Satislar
    {
        [Key]
        public int SatislarId { get; set; }
        public DateTime Tarih { get; set; }

        public int Adet { get; set; }
        public decimal Fiyat { get; set; }
        public decimal ToplamTutar { get; set; }


        public int UrunId { get; set; }
        public Urun Urun { get; set; }

        public int MusteriId { get; set; }
        public Musteri Musteri { get; set; }
    }
}
