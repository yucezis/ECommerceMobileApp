class Kategori {
  final int kategoriID;
  final String kategoriAdi;

  Kategori({
    required this.kategoriID,
    required this.kategoriAdi,
  });


  factory Kategori.fromJson(Map<String, dynamic> json) {
    return Kategori(
      kategoriID: json['kategoriID'] ?? 0,
      kategoriAdi: json['kategoriAdi'] ?? 'Kategori',
    );
  }
}