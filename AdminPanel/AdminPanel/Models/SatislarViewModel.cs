using AdminPanel.Models;

namespace AdminPanel.Models
{
    public class SatislarViewModel
    {
        public int SatislarId { get; set; }

        public string SiparisNo { get; set; }

        public SiparisDurum SiparisDurumu { get; set; } = SiparisDurum.SiparisAlindi;

        public DateTime Tarih { get; set; }
        public int Adet { get; set; }
        public decimal Fiyat { get; set; }
        public decimal ToplamTutar { get; set; }

        public int UrunId { get; set; }
        public UrunViewModel? Urun { get; set; } 
        public int MusteriId { get; set; }
        public MusteriViewModel? Musteri { get; set; } 
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