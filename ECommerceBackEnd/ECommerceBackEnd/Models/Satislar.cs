using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

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
        public Urun? Urun { get; set; }

        public int MusteriId { get; set; }
        public Musteri? Musteri { get; set; }

        public string? SiparisNo { get; set; }

        public int? TeslimatAdresiId { get; set; }
        public Adres? TeslimatAdresi { get; set; }

        public SiparisDurum SiparisDurumu { get; set; } = SiparisDurum.SiparisAlindi;

        [NotMapped]
        public bool DegerlendirmeYapildiMi { get; set; }

        [NotMapped]
        public int? DegerlendirmeId { get; set; }
    }

    public enum SiparisDurum
    {
        SiparisAlindi = 0,
        Hazirlaniyor = 1,
        KargoyaVerildi = 2,
        TeslimEdildi = 3,
        IptalEdildi = 4
    }
}