class Urun {
  final int urunId;
  final String urunAdi;
  final String urunMarka;
  final String urunGorsel;
  final double urunSatisFiyati;
  final double? indirimliFiyat; 
  final String kategoriAdi;     
  final String aciklama;

  Urun({
    required this.urunId,
    required this.urunAdi,
    required this.urunMarka,
    required this.urunGorsel,
    required this.urunSatisFiyati,
    this.indirimliFiyat,
    required this.kategoriAdi,
    required this.aciklama,
  });


  factory Urun.fromJson(Map<String, dynamic> json) {
    return Urun(
      
      urunId: json['urunId'] ?? 0,
      urunAdi: json['urunAdi'] ?? 'İsimsiz Ürün',
      urunMarka: json['urunMarka'] ?? '',
      urunGorsel: json['urunGorsel'] ?? '',
      urunSatisFiyati: (json['urunSatisFiyati'] ?? 0).toDouble(),
      indirimliFiyat: json['indirimliFiyat'] != null 
          ? (json['indirimliFiyat']).toDouble() 
          : null,
          
      kategoriAdi: json['kategoriAdi'] ?? '',
      aciklama: json['aciklama'] ?? '',
    );
  }

  get urunYazar => null;
}