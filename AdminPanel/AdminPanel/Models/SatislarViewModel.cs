using AdminPanel.Models;

namespace AdminPanel.Models
{
    public class SatislarViewModel
    {
        public int SatislarId { get; set; }
        public DateTime Tarih { get; set; }
        public int Adet { get; set; }
        public decimal Fiyat { get; set; }
        public decimal ToplamTutar { get; set; }

        public int UrunId { get; set; }
        public UrunViewModel? Urun { get; set; } // Flattened

        public int MusteriId { get; set; }
        public MusteriViewModel? Musteri { get; set; } // Flattened
    }
}