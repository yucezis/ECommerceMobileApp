import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'models/urun_model.dart';
import 'footer.dart';

const Color kBookPaper = Color(0xFFFEFAE0); 
const Color kDarkGreen = Color(0xFF283618); 
const Color kOliveGreen = Color(0xFF606C38); 
const Color kDarkCoffee = Color(0xFF211508);
const Color kCreamAccent = Color(0xFFFAEDCD); 

class CategoryProductsScreen extends StatefulWidget {
  final int kategoriId;
  final String kategoriAdi;

  const CategoryProductsScreen({
    super.key,
    required this.kategoriId,
    required this.kategoriAdi,
  });

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  List<Urun> _urunListesi = [];
  bool _isLoading = true;
  String _hataMesaji = "";
  String _seciliSiralama = "Varsayılan";

  @override
  void initState() {
    super.initState();
    _urunleriGetir();
  }

  String getBaseUrl() {
    String ipAdresim = "10.180.131.237";
    String port = "5126";
    return "http://$ipAdresim:$port/api";
  }

  Future<void> _urunleriGetir() async {
    try {
      final response = await http.get(Uri.parse("${getBaseUrl()}/Urun"));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        List<Urun> tumUrunler = body.map((item) => Urun.fromJson(item)).toList();
        // Sadece seçili kategoriye ait ürünleri filtrele
        List<Urun> filtrelenmis = tumUrunler.where((u) => u.kategoriID == widget.kategoriId).toList();

        if (mounted) {
          setState(() {
            _urunListesi = filtrelenmis;
            _isLoading = false;
          });
        }
      } else {
        throw Exception("Ürünler yüklenemedi");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hataMesaji = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _sirala(String secenek) {
    setState(() {
      _seciliSiralama = secenek;
      if (secenek == "Fiyat Artan") {
        _urunListesi.sort((a, b) => a.urunSatisFiyati.compareTo(b.urunSatisFiyati));
      } else if (secenek == "Fiyat Azalan") {
        _urunListesi.sort((a, b) => b.urunSatisFiyati.compareTo(a.urunSatisFiyati));
      } else if (secenek == "Çok Satanlar") {
        // Stok veya satış adedine göre sıralama (Örnek: stok azalan)
        _urunListesi.sort((a, b) => a.urunStok.compareTo(b.urunStok));
      }
    });
  }

  void _siralamaMenusuAc() {
    showModalBottomSheet(
      context: context,
      backgroundColor: kBookPaper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 320,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.all(Radius.circular(10))),
                ),
              ),
              const Text("Sıralama Seçenekleri", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kDarkGreen)),
              const SizedBox(height: 10),
              _buildSortOption(Icons.sort, "Varsayılan"),
              _buildSortOption(Icons.arrow_upward_rounded, "Fiyat Artan"),
              _buildSortOption(Icons.arrow_downward_rounded, "Fiyat Azalan"),
              _buildSortOption(Icons.star_outline_rounded, "Çok Satanlar"),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(IconData icon, String title) {
    bool isSelected = _seciliSiralama == title;
    return ListTile(
      leading: Icon(icon, color: isSelected ? kOliveGreen : Colors.grey),
      title: Text(
        title, 
        style: TextStyle(
          color: isSelected ? kOliveGreen : kDarkCoffee, 
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
        )
      ),
      trailing: isSelected ? const Icon(Icons.check, color: kOliveGreen) : null,
      onTap: () {
        _sirala(title);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBookPaper,
      appBar: AppBar(
        title: Text(widget.kategoriAdi, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        centerTitle: true,
        backgroundColor: kDarkGreen,
        foregroundColor: kBookPaper,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () {
            Footer.footerKey.currentState?.kategoridenCik();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: _siralamaMenusuAc,
            tooltip: "Sırala",
          ),
        ],
      ),
      
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kDarkGreen))
          : _hataMesaji.isNotEmpty
              ? Center(child: Text("Hata: $_hataMesaji", style: const TextStyle(color: Colors.red)))
              : _urunListesi.isEmpty
                  ? _buildBosDurum()
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65, // Kartlar biraz daha kısa ve dengeli
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _urunListesi.length,
                      itemBuilder: (context, index) {
                        return _buildUrunKarti(_urunListesi[index]);
                      },
                    ),
    );
  }

  Widget _buildUrunKarti(Urun urun) {
    bool indirimVar = urun.indirimliFiyat != null && urun.indirimliFiyat! > 0;

    return GestureDetector(
      onTap: () {
        Footer.footerKey.currentState?.uruneGit(urun);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: kDarkGreen.withOpacity(0.08),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. RESİM ALANI
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          urun.urunGorsel,
                          fit: BoxFit.contain,
                          errorBuilder: (c, o, s) => Container(
                            color: kBookPaper,
                            child: const Center(child: Icon(Icons.book, size: 40, color: Colors.grey)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Favori İkonu
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: const Icon(Icons.favorite_border, color: Colors.grey, size: 20),
                    ),
                  ),
                  // İndirim Rozeti
                  if (indirimVar)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFBC4749), // Koyu Kırmızı (Toprak tonlarına uygun)
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text("FIRSAT", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            ),
            
            // 2. BİLGİ ALANI
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          urun.urunAdi,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: kDarkCoffee,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          urun.urunYazar.isNotEmpty ? urun.urunYazar : urun.urunMarka,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    
                    // Fiyat ve Sepet Butonu
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (indirimVar) ...[
                              Text(
                                "${urun.urunSatisFiyati} ₺",
                                style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                "${urun.indirimliFiyat} ₺",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: kDarkGreen,
                                ),
                              ),
                            ] else ...[
                              Text(
                                "${urun.urunSatisFiyati} ₺",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: kDarkGreen,
                                ),
                              ),
                            ],
                          ],
                        ),
                        
                        InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("${urun.urunAdi} sepete eklendi!"),
                                backgroundColor: kOliveGreen,
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: kOliveGreen,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.add_shopping_cart_rounded, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBosDurum() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book_rounded, size: 80, color: kDarkGreen.withOpacity(0.3)),
          const SizedBox(height: 20),
          const Text(
            "Bu rafta henüz kitap yok.",
            style: TextStyle(fontSize: 16, color: kOliveGreen, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 5),
          const Text(
            "Başka kategorilere göz atabilirsin.",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}