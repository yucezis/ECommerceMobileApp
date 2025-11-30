using AdminPanel.Models; 

public class SiparisGrupViewModel
{
    public string SiparisNo { get; set; }
    public DateTime Tarih { get; set; }
    public string MusteriAdSoyad { get; set; }
    public decimal ToplamTutar { get; set; }
    public SiparisDurum Durum { get; set; }

    public List<SatislarViewModel> Urunler { get; set; }
}