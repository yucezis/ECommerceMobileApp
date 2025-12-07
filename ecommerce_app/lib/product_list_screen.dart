import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; 
import 'models/urun_model.dart';
import 'footer.dart';
import 'models/cart_service.dart';
import 'favorite_button.dart';
import 'login_screen.dart'; 

const Color kBookPaper = Color(0xFFFEFAE0);
const Color kDarkGreen = Color(0xFF283618);
const Color kOliveGreen = Color(0xFF606C38);
const Color kDarkCoffee = Color(0xFF211508);
const Color kCreamAccent = Color(0xFFFAEDCD);
const Color kRedBadge = Color(0xFFBC4749);

enum ProductListType { category, discount, bestSeller }

class ProductListScreen extends StatefulWidget {
  final String title;
  final ProductListType listType;
  final int? kategoriId;

  const ProductListScreen({
    super.key,
    required this.title,
    required this.listType,
    this.kategoriId,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Urun> _urunListesi = [];
  bool _isLoading = true;
  String _hataMesaji = "";
  String _seciliSiralama = "Varsayılan";

  @override
  void initState() {
    super.initState();
    _verileriGetir();
  }

  String getBaseUrl() {
    return "http://10.180.131.237:5126/api"; 
  }

  Future<bool> _oturumVarMi() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('musteriId');
  }

  void _girisYapUyarisiAc(String islemAdi) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Giriş Yapmalısınız"),
        content: Text("Bu ürünü $islemAdi için lütfen giriş yapın veya üye olun."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Vazgeç", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kDarkGreen),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const LoginScreen())
              );
            },
            child: const Text("Giriş Yap", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Future<void> _verileriGetir() async {
    try {
      String endpoint = "/Urun";
      
      if (widget.listType == ProductListType.bestSeller) {
        endpoint = "/Urun/CokSatanlar";
      }

      final response = await http.get(Uri.parse("${getBaseUrl()}$endpoint"));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        List<Urun> tumUrunler = body.map((item) => Urun.fromJson(item)).toList();
        List<Urun> filtrelenmisListe = [];

        if (widget.listType == ProductListType.category) {
          filtrelenmisListe = tumUrunler.where((u) => u.kategoriID == widget.kategoriId).toList();
        } 
        else if (widget.listType == ProductListType.discount) {
          filtrelenmisListe = tumUrunler.where((u) => u.indirimliFiyat != null && u.indirimliFiyat! > 0).toList();
        } 
        else {
          filtrelenmisListe = tumUrunler;
        }

        if (mounted) {
          setState(() {
            _urunListesi = filtrelenmisListe;
            _isLoading = false;
          });
        }
      } else {
        throw Exception("Veriler yüklenemedi: ${response.statusCode}");
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
      backgroundColor: kBookPaper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25))
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
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(10)),
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
      title: Text(title, style: TextStyle(
        color: isSelected ? kOliveGreen : kDarkCoffee, 
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
      )
      ),
      trailing: isSelected ? const Icon(Icons.check, color: kOliveGreen) : null,
      onTap: () { _sirala(title); Navigator.pop(context); },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBookPaper, 
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
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
            Footer.footerKey.currentState?.listedenCik(); 
          },
        ),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list_rounded), onPressed: _siralamaMenusuAc),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: kDarkGreen))
          : _hataMesaji.isNotEmpty 
              ? Center(child: Text("Hata: $_hataMesaji", style: const TextStyle(color: Colors.red)))
              : _urunListesi.isEmpty 
                  ? _buildBosDurum()
                  : Column(
                      children: [
                        if (_seciliSiralama != "Varsayılan")
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                            color: kCreamAccent, 
                            child: Row(
                              children: [
                                const Icon(Icons.sort, size: 16, color: kOliveGreen),
                                const SizedBox(width: 8),
                                Text(
                                  "Sıralama: $_seciliSiralama",
                                  style: const TextStyle(color: kOliveGreen, fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () => _sirala("Varsayılan"),
                                  child: const Icon(Icons.close, size: 18, color: kOliveGreen),
                                )
                              ],
                            ),
                          ),

                        Expanded(
                          child: GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, 
                              childAspectRatio: 0.65, 
                              crossAxisSpacing: 16, 
                              mainAxisSpacing: 16, 
                            ),
                            itemCount: _urunListesi.length,
                            itemBuilder: (context, index) {
                              return _buildUrunKarti(_urunListesi[index]);
                            },
                          ),
                        ),
                      ],
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
                  Positioned(
                    top: 8,
                    right: 8,
                    
                    child: FavoriteButton(
                      urun: urun,
                      size: 20,
                    ),
                  ),
                  if (indirimVar)
                    Positioned(
                      top: 8, left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: kRedBadge, 
                          borderRadius: BorderRadius.circular(8)
                        ),
                        child: const Text("FIRSAT", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            ),
            
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
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: kDarkCoffee, height: 1.2)
                        ),
                        const SizedBox(height: 4),
                        Text(
                          urun.urunYazar.isNotEmpty ? urun.urunYazar : urun.urunMarka, 
                          maxLines: 1, 
                          overflow: TextOverflow.ellipsis, 
                          style: const TextStyle(color: Colors.grey, fontSize: 12)
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          if (indirimVar) ...[
                            Text("${urun.urunSatisFiyati} ₺", style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 11)),
                            Text("${urun.indirimliFiyat} ₺", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kRedBadge)),
                          ] else ...[
                            Text("${urun.urunSatisFiyati} ₺", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kDarkCoffee)),
                          ]
                        ]),
                        
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {
                            bool girisYapti = await _oturumVarMi();
                            if (!girisYapti) {
                              _girisYapUyarisiAc("sepete eklemek");
                              return; 
                            }

                            await SepetServisi.sepeteEkle(urun);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("${urun.urunAdi} sepete eklendi!"),
                                  backgroundColor: kDarkCoffee,
                                  duration: const Duration(milliseconds: 800),
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: kOliveGreen, 
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.add_shopping_cart_rounded, 
                              color: Colors.white, 
                              size: 18,
                            ),
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
            "Aradığın kriterde kitap yok.",
            style: TextStyle(fontSize: 16, color: kOliveGreen, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}