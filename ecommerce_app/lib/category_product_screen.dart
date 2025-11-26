import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'models/urun_model.dart';
import 'footer.dart'; 

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
        _urunListesi.sort((a, b) => a.urunStok.compareTo(b.urunStok));
      }
    });
  }

  void _siralamaMenusuAc() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Sıralama Seçenekleri", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Divider(),
              ListTile(leading: const Icon(Icons.sort), title: const Text("Varsayılan"), onTap: () { _sirala("Varsayılan"); Navigator.pop(context); }, selected: _seciliSiralama == "Varsayılan"),
              ListTile(leading: const Icon(Icons.arrow_upward), title: const Text("Fiyat Artan"), onTap: () { _sirala("Fiyat Artan"); Navigator.pop(context); }, selected: _seciliSiralama == "Fiyat Artan"),
              ListTile(leading: const Icon(Icons.arrow_downward), title: const Text("Fiyat Azalan"), onTap: () { _sirala("Fiyat Azalan"); Navigator.pop(context); }, selected: _seciliSiralama == "Fiyat Azalan"),
              ListTile(leading: const Icon(Icons.star), title: const Text("Çok Satanlar"), onTap: () { _sirala("Çok Satanlar"); Navigator.pop(context); }, selected: _seciliSiralama == "Çok Satanlar"),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      
      appBar: AppBar(
        title: Text(widget.kategoriAdi, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF6200EE),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Footer.footerKey.currentState?.kategoridenCik();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _siralamaMenusuAc,
            tooltip: "Sırala",
          ),
        ],
      ),
      
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _hataMesaji.isNotEmpty 
              ? Center(child: Text("Hata: $_hataMesaji"))
              : _urunListesi.isEmpty 
                  ? _buildBosDurum()
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, 
                        childAspectRatio: 0.58, 
                        crossAxisSpacing: 15, 
                        mainAxisSpacing: 20, 
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
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. RESİM
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: Image.network(
                        urun.urunGorsel,
                        fit: BoxFit.contain,
                        errorBuilder: (c, o, s) => Container(
                          color: Colors.grey[100],
                          child: const Center(child: Icon(Icons.book, size: 40, color: Colors.grey)),
                        ),
                      ),
                    ),
                  ),
                 
                  Positioned(
                    top: 8, right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]),
                      child: const Icon(Icons.favorite_border, color: Colors.grey, size: 22),
                    ),
                  ),
                  
                  if (indirimVar)
                    Positioned(
                      top: 8, left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(8)),
                        child: const Text("İNDİRİM", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            ),
           
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(urun.urunAdi, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF2D2D2D))),
                        const SizedBox(height: 4),
                        Text(urun.urunYazar.isNotEmpty ? urun.urunYazar : urun.urunMarka, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (indirimVar) ...[
                              Text("${urun.urunSatisFiyati} ₺", style: const TextStyle(decoration: TextDecoration.lineThrough, decorationColor: Colors.red, color: Colors.red, fontSize: 12, fontWeight: FontWeight.w500)),
                              Text("${urun.indirimliFiyat} ₺", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF6200EE))),
                            ] else ...[
                              Text("${urun.urunSatisFiyati} ₺", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF6200EE))),
                            ],
                          ],
                        ),
                        
                        InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${urun.urunAdi} sepete eklendi!"), duration: const Duration(seconds: 1), backgroundColor: const Color(0xFF6200EE)));
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: const Color(0xFF6200EE), borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20),
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
          Icon(Icons.menu_book, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const Text("Bu kategoride henüz ürün yok.", style: TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }
}