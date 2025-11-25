
using System.ComponentModel.DataAnnotations;

namespace AdminPanel.Models
{
    public class MusteriViewModel
    {
        public int MusteriId { get; set; }

        [StringLength(30)]
        [Required(ErrorMessage = "Bu alanı boş bırakamazsınız!")]
        public string MusteriAdi { get; set; }

        [StringLength(30)]
        [Required(ErrorMessage = "Bu alanı boş bırakamazsınız!")]
        public string MusteriSoyadi { get; set; }

        [StringLength(15)]
        [Required(ErrorMessage = "Bu alanı boş bırakamazsınız!")]
        public string MusteriSehir { get; set; }

        [StringLength(10)]
        [Required(ErrorMessage = "Bu alanı boş bırakamazsınız!")]
        public string MusteriTelNo { get; set; }

        [StringLength(50)]
        [Required(ErrorMessage = "Bu alanı boş bırakamazsınız!")]
        public string MusteriMail { get; set; }

        
        [StringLength(50)]
        [Required(ErrorMessage = "Şifre alanı boş bırakılamaz!")]
        public string MusteriSifre { get; set; }

        public bool Durum { get; set; }
    }
}