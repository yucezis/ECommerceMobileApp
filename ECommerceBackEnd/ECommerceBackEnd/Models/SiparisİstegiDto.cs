using ECommerceBackEnd.Models;

public class SiparisIstegiDto
{
    public List<Satislar> SepetUrunleri { get; set; } 
    public string KartSahibi { get; set; }           
    public string KartNumarasi { get; set; }       
    public string SonKullanmaTarihi { get; set; }    
    public string Cvv { get; set; }
}