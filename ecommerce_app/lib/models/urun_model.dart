class Urun {
  final int urunId;
  final String urunAdi;
  final String urunMarka;
  final String urunYazar;
  final String urunGorsel;
  final double urunSatisFiyati;
  final double? indirimliFiyat;
  final String aciklama;
  final int urunStok;
  final String kategoriAdi;
  final int kategoriID; 
  final int? urunSayfa;
  final String? urunDil;

  int sepetAdedi;

  Urun({
    required this.urunId,
    required this.urunAdi,
    required this.urunMarka,
    required this.urunYazar,
    required this.urunGorsel,
    required this.urunSatisFiyati,
    this.indirimliFiyat,
    required this.aciklama,
    required this.urunStok,
    required this.kategoriAdi,
    required this.kategoriID, 
    this.urunDil,
    this.urunSayfa,
    this.sepetAdedi = 1,
  });

  factory Urun.fromJson(Map<String, dynamic> json) {
    return Urun(
      urunId: json['urunId'] ?? 0,
      urunAdi: json['urunAdi'] ?? '',
      urunMarka: json['urunMarka'] ?? '',
      urunYazar: json['UrunYazar'] ?? json['urunYazar'] ?? '',
      urunGorsel: json['urunGorsel'] ?? '',
      urunSatisFiyati: (json['urunSatisFiyati'] ?? 0).toDouble(),
      indirimliFiyat: json['indirimliFiyat'] != null
          ? (json['indirimliFiyat']).toDouble()
          : null,
      aciklama: json['aciklama'] ?? '',
      urunStok: json['urunStok'] ?? 0,
      kategoriAdi: json['kategoriAdi'] ?? '',
      
      kategoriID: json['kategoriID'] ?? json['KategoriID'] ?? 0, 
      sepetAdedi: json['sepetAdedi'] ?? 1,
      urunDil: json['urunDil'] ?? json['UrunDil'], 
      urunSayfa: json['urunSayfa'] ?? json['UrunSayfa'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'urunId': urunId,
      'urunAdi': urunAdi,
      'urunMarka': urunMarka,
      'urunYazar': urunYazar,
      'urunGorsel': urunGorsel,
      'urunSatisFiyati': urunSatisFiyati,
      'indirimliFiyat': indirimliFiyat,
      'aciklama': aciklama,
      'urunStok': urunStok,
      'kategoriAdi': kategoriAdi,
      'kategoriID': kategoriID,
      'sepetAdedi': sepetAdedi,
      'urunSayfa' : urunSayfa,
      'urunDil' : urunDil
    };
  }

}
