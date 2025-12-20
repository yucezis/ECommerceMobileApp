using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace ECommerceBackEnd.Models
{
    public class Kategori
    {
        [Key]
        public int KategoriID { get; set; }

        [Column(TypeName = "VARCHAR")]
        [StringLength(30)]
        public string KategoriAdi { get; set; }

        [JsonIgnore]
        public ICollection<Urun>? uruns { get; set; }
    }
}
