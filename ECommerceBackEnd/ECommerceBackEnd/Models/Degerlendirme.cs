using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace ECommerceBackEnd.Models
{
    public class Degerlendirme
    {
        [Key]
        public int DegerlendirmeId { get; set; }

        public int Puan { get; set; }
        public string Yorum { get; set; }
        public DateTime Tarih { get; set; } = DateTime.Now;

        public int UrunId { get; set; }

        [JsonIgnore] 
        public virtual Urun? Urun { get; set; } 

        public int MusteriId { get; set; }

        [JsonIgnore] 
        public virtual Musteri? Musteri { get; set; }
        public bool Onaylandi { get; set; } = false;

        public string? ResimUrl { get; set; }

        [NotMapped]
        public string? ResimBase64 { get; set; }
    }
}
