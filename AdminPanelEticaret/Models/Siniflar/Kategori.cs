using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace AdminPanelEticaret.Models.Siniflar
{
    public class Kategori
    {
        [Key]
        public int KategoriID { get; set; }

        [Column(TypeName = "VARCHAR")]
        [StringLength(30)]
        public string KategoriAdi { get; set; }

        public ICollection<Urun> uruns { get; set; }
    }
}
