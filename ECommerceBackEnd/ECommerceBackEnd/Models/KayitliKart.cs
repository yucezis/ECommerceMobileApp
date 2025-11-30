using System.ComponentModel.DataAnnotations;

namespace ECommerceBackEnd.Models
{
    public class KayitliKart
    {
        [Key]
        public int KartId { get; set; }

        public string KartIsmi { get; set; }
        public string KartSahibi { get; set; }
        public string KartNumarasi { get; set; }
        public string SonKullanmaAy { get; set; }
        public string SonKullanmaYil { get; set; }

        public int MusteriId { get; set; }
        public Musteri? Musteri { get; set; }
    }
}
