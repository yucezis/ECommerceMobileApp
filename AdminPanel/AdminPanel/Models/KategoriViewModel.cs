using AdminPanel.Models;
using System.ComponentModel.DataAnnotations;

namespace AdminPanel.Models
{
    public class KategoriViewModel
    {
        public int KategoriID { get; set; }

        [StringLength(30)]
        public string KategoriAdi { get; set; }
    }
}