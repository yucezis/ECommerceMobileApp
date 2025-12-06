import 'urun_model.dart'; 
import 'adres_model.dart';

class Satis {
  final int satisId;
  final String siparisNo;
  final int siparisDurumu; 
  final DateTime tarih;
  final int adet;
  final double fiyat;
  final double toplamTutar;
  final Adres? teslimatAdresi;
  final Urun? urun; 
  final bool degerlendirmeYapildiMi; 
  final int? degerlendirmeId;
  final String? iadeKodu;

  Satis({
    required this.satisId,
    required this.siparisNo,
    required this.siparisDurumu, 
    required this.tarih,
    required this.adet,
    required this.fiyat,
    required this.toplamTutar,
    this.teslimatAdresi,
    this.urun,
    this.degerlendirmeYapildiMi = false,
    this.degerlendirmeId,
    this.iadeKodu,
  });

  factory Satis.fromJson(Map<String, dynamic> json) {
    return Satis(
      satisId: json['satislarId'] ?? 0,
      siparisNo: json['siparisNo'] ?? json['SiparisNo'] ?? '',
      siparisDurumu: json['siparisDurumu'] ?? json['SiparisDurumu'] ?? 0,
      
      tarih: json['tarih'] != null 
          ? DateTime.parse(json['tarih']) 
          : DateTime.now(),
      adet: json['adet'] ?? 0,
      fiyat: (json['fiyat'] ?? 0).toDouble(),
      toplamTutar: (json['toplamTutar'] ?? 0).toDouble(),
      urun: json['urun'] != null ? Urun.fromJson(json['urun']) : null,
      teslimatAdresi: (json['teslimatAdresi'] != null || json['TeslimatAdresi'] != null)
          ? Adres.fromJson(json['teslimatAdresi'] ?? json['TeslimatAdresi'])
          : null,
      degerlendirmeYapildiMi: json['degerlendirmeYapildiMi'] ?? false,
      degerlendirmeId: json['degerlendirmeId'],
      iadeKodu: json['iadeKodu'],
    );
  }
}