using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace AdminPanel.Models
{
    public class DegerlendirmeViewModel
    {
        public int DegerlendirmeId { get; set; }
        public int Puan { get; set; }
        public string Yorum { get; set; }
        public DateTime Tarih { get; set; }
        public bool Onaylandi { get; set; }
        public string UrunAdi { get; set; }    
        public string MusteriAdi { get; set; }
    }
}
