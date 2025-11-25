class Musteri {
  final int musteriId;
  final String musteriAdi;
  final String musteriSoyadi;
  final String musteriMail;
  final String musteriTelNo;
  final String musteriSehir;

  Musteri({
    required this.musteriId,
    required this.musteriAdi,
    required this.musteriSoyadi,
    required this.musteriMail,
    required this.musteriTelNo,
    required this.musteriSehir,
  });

  
  factory Musteri.fromJson(Map<String, dynamic> json) {
    return Musteri(
      musteriId: json['musteriId'] ?? json['MusteriId'] ?? 0,
      musteriAdi: json['musteriAdi'] ?? json['MusteriAdi'] ?? '',
      musteriSoyadi: json['musteriSoyadi'] ?? json['MusteriSoyadi'] ?? '',
      musteriMail: json['musteriMail'] ?? json['MusteriMail'] ?? '',
      musteriTelNo: json['musteriTelNo'] ?? json['MusteriTelNo'] ?? '',
      musteriSehir: json['musteriSehir'] ?? json['MusteriSehir'] ?? '',
    );
  }
}