namespace AdminPanel.Models
{
    public class DashboardViewModel
    {
        public int UrunSayisi { get; set; }
        public decimal ToplamSatis { get; set; }
        public int KullaniciSayisi { get; set; }
        public int DusukStokAdedi { get; set; }
        public int ToplamStok { get; set; }
        public decimal BugunkuSatis { get; set; }
        public List<CokSatanUrun> CokSatanlar { get; set; } 
    }

    public class CokSatanUrun
    {
        public string UrunAdi { get; set; }
        public int Adet { get; set; }
    }
}
