import 'urun_model.dart'; 

class Satis {
  final int satisId;
  final DateTime tarih;
  final int adet;
  final double fiyat;
  final double toplamTutar;
  final Urun? urun; 

  Satis({
    required this.satisId,
    required this.tarih,
    required this.adet,
    required this.fiyat,
    required this.toplamTutar,
    this.urun,
  });

  factory Satis.fromJson(Map<String, dynamic> json) {
    return Satis(
      satisId: json['satislarId'] ?? 0,
      tarih: json['tarih'] != null 
          ? DateTime.parse(json['tarih']) 
          : DateTime.now(),
      adet: json['adet'] ?? 0,
      fiyat: (json['fiyat'] ?? 0).toDouble(),
      toplamTutar: (json['toplamTutar'] ?? 0).toDouble(),
      urun: json['urun'] != null ? Urun.fromJson(json['urun']) : null,
    );
  }
}