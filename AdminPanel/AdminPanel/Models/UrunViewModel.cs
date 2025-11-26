using AdminPanel.Models;
using System.ComponentModel.DataAnnotations;

namespace AdminPanel.Models
{
    public class UrunViewModel
    {
        public int UrunId { get; set; }

        [StringLength(30)]
        public string? UrunAdi { get; set; }

        [StringLength(30)]
        public string? UrunMarka { get; set; }

        [StringLength(250)]
        public string? UrunYazar { get; set; }

        public short UrunStok { get; set; }

        public decimal UrunSatisFiyati { get; set; }
        public bool UrunStokDurum { get; set; }

        [StringLength(250)]
        public string? UrunGorsel { get; set; }

        public int KategoriID { get; set; }

        public KategoriViewModel? Kategori { get; set; }

        public bool Durum { get; set; }
        public decimal? IndirimliFiyat { get; set; }
        public string? Aciklama { get; set; }
    }
}