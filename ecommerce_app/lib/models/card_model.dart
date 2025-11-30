class KayitliKart {
  final int? kartId;
  final String kartIsmi;
  final String kartSahibi;
  final String kartNumarasi;
  final String sonKullanmaAy;
  final String sonKullanmaYil;
  final int musteriId;

  KayitliKart({
    this.kartId,
    required this.kartIsmi,
    required this.kartSahibi,
    required this.kartNumarasi,
    required this.sonKullanmaAy,
    required this.sonKullanmaYil,
    required this.musteriId,
  });

  factory KayitliKart.fromJson(Map<String, dynamic> json) {
    return KayitliKart(
      kartId: json['kartId'],
      kartIsmi: json['kartIsmi'] ?? 'Kartım',
      kartSahibi: json['kartSahibi'],
      kartNumarasi: json['kartNumarasi'],
      sonKullanmaAy: json['sonKullanmaAy'],
      sonKullanmaYil: json['sonKullanmaYil'],
      musteriId: json['musteriId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kartIsmi': kartIsmi,
      'kartSahibi': kartSahibi,
      'kartNumarasi': kartNumarasi,
      'sonKullanmaAy': sonKullanmaAy,
      'sonKullanmaYil': sonKullanmaYil,
      'musteriId': musteriId,
    };
  }
}