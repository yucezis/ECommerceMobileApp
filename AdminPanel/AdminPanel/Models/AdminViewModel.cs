using System.ComponentModel.DataAnnotations;

namespace AdminPanelEticaret.Models
{
    public class AdminViewModel
    {
        public int AdminId { get; set; }

        [StringLength(10)]
        public string KullaniciAdi { get; set; }


        [StringLength(50)]
        [Required(ErrorMessage = "Şifre alanı boş bırakılamaz!")]
        public string Sifre { get; set; }

    }
}