using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace AdminPanelEticaret.Models.Siniflar
{
    public class Admin
    {
        [Key]

        public int AdminId { get; set; }

        [Column(TypeName = "VARCHAR")]
        [StringLength(10)]
        public string KullaniciAdi { get; set; }

        [Column(TypeName = "VARCHAR")]
        [StringLength(10)]
        public string Sifre { get; set; }
    }
}
