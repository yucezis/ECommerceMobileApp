using AdminPanel.Models;
using System.ComponentModel.DataAnnotations;

namespace AdminPanel.Models
{
    public class MesajViewModel
    {
        public int MesajId { get; set; }
        public int MusteriId { get; set; }
        public string Icerik { get; set; }
        public bool GonderenAdminMi { get; set; }
        public DateTime Tarih { get; set; }
    }
}

