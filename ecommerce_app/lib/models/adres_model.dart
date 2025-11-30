class Adres {
  final int? adresId; 
  final String baslik;
  final String sehir;
  final String ilce;
  final String acikAdres;
  final int musteriId;

  Adres({
    this.adresId,
    required this.baslik,
    required this.sehir,
    required this.ilce,
    required this.acikAdres,
    required this.musteriId,
  });

  factory Adres.fromJson(Map<String, dynamic> json) {
    return Adres(
      adresId: json['adresId'],
      baslik: json['baslik'],
      sehir: json['sehir'],
      ilce: json['ilce'],
      acikAdres: json['acikAdres'],
      musteriId: json['musteriId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'adresId': adresId ?? 0,
      'baslik': baslik,
      'sehir': sehir,
      'ilce': ilce,
      'acikAdres': acikAdres,
      'musteriId': musteriId,
    };
  }
}