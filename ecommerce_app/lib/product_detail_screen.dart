import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; 
import 'package:http/http.dart' as http;
import 'models/urun_model.dart'; 
import 'footer.dart';
import 'models/cart_service.dart';
import 'favorite_button.dart';

const Color kBookPaper = Color(0xFFFEFAE0);
const Color kBackgroundAccent = Color(0xFFFAEDCD);
const Color kDarkGreen = Color(0xFF283618);
const Color kOliveGreen = Color(0xFF606C38);
const Color kDarkCoffee = Color(0xFF211508);
const Color kSoftGrey = Color(0xFFF5F5F5);

class ProductDetailScreen extends StatefulWidget {
  final Urun urun;

  const ProductDetailScreen({super.key, required this.urun});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int adet = 1;
  
  // Yorum Değişkenleri
  List<dynamic> _yorumlar = [];
  bool _yorumlarYukleniyor = true;

  @override
  void initState() {
    super.initState();
    _yorumlariGetir();
  }

  String getBaseUrl() {
    return "http://10.180.131.237:5126/api"; // IP Adresini kontrol et
  }

  // API: Yorumları Getir
  Future<void> _yorumlariGetir() async {
    try {
      final response = await http.get(Uri.parse("${getBaseUrl()}/Degerlendirmeler/Getir/${widget.urun.urunId}"));
      if (response.statusCode == 200) {
        setState(() {
          _yorumlar = jsonDecode(response.body);
          _yorumlarYukleniyor = false;
        });
      }
    } catch (e) {
      print("Yorum hatası: $e");
      setState(() => _yorumlarYukleniyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final urun = widget.urun;
    bool indirimVar = urun.indirimliFiyat != null && urun.indirimliFiyat! > 0;

    return Scaffold(
      backgroundColor: kBackgroundAccent,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 5, 
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [kBackgroundAccent, kBookPaper],
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: -100, right: -50,
                        child: Container(
                          width: 350, height: 350,
                          decoration: BoxDecoration(color: kOliveGreen.withOpacity(0.08), shape: BoxShape.circle),
                        ),
                      ),
                      Hero(
                        tag: urun.urunGorsel,
                        child: Container(
                          height: 280, 
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(color: kDarkCoffee.withOpacity(0.3), offset: const Offset(12, 12), blurRadius: 25, spreadRadius: -5),
                              BoxShadow(color: kDarkCoffee.withOpacity(0.1), offset: const Offset(-4, -4), blurRadius: 10),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              urun.urunGorsel, fit: BoxFit.cover,
                              errorBuilder: (c, o, s) => Container(width: 180, color: kBookPaper, child: const Icon(Icons.book, size: 60, color: Colors.grey)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Expanded(flex: 5, child: SizedBox()), 
            ],
          ),

          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCircularButton(icon: Icons.arrow_back_ios_new, onTap: () => Footer.footerKey.currentState?.urundenCik()),
                    FavoriteButton(urun: widget.urun, size: 24),
                  ],
                ),
              ),
            ),
          ),
          
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.58,
              padding: const EdgeInsets.fromLTRB(25, 35, 25, 0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 40, offset: Offset(0, -10))],
              ),
              child: SingleChildScrollView( 
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      urun.urunAdi,
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: kDarkGreen, height: 1.1, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      urun.urunYazar.isNotEmpty ? urun.urunYazar : urun.urunMarka,
                      style: TextStyle(fontSize: 16, color: kOliveGreen.withOpacity(0.9), fontWeight: FontWeight.w500, fontStyle: FontStyle.italic),
                    ),
                    
                    if (indirimVar) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: const Color(0xFFBC4749).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: const Text("%15 İNDİRİM", style: TextStyle(color: Color(0xFFBC4749), fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ],

                    const SizedBox(height: 25),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildModernBadge(Icons.star_rounded, "4.8", Colors.amber),
                        _buildModernBadge(Icons.language, "Türkçe", Colors.blueGrey),
                        _buildModernBadge(Icons.auto_stories, "320 Syf", kOliveGreen),
                      ],
                    ),
                    const SizedBox(height: 25),
                    
                    const Text("Kitap Hakkında", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kDarkCoffee)),
                    const SizedBox(height: 10),
                    Text(
                      urun.aciklama.isNotEmpty ? urun.aciklama : "Açıklama Yok!",
                      style: TextStyle(fontSize: 15, color: kDarkCoffee.withOpacity(0.65), height: 1.7),
                    ),

                    const SizedBox(height: 30),
                    const Divider(),
                    const SizedBox(height: 10),

                    // --- SADECE YORUMLAR LİSTESİ (BUTON YOK) ---
                    const Text("Değerlendirmeler", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kDarkCoffee)),
                    
                    const SizedBox(height: 10),

                    _yorumlarYukleniyor 
                        ? const Center(child: CircularProgressIndicator(color: kDarkGreen))
                        : _yorumlar.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Center(child: Text("Henüz yorum yapılmamış.", style: TextStyle(color: Colors.grey[400]))),
                              )
                            : ListView.builder(
                                shrinkWrap: true, 
                                physics: const NeverScrollableScrollPhysics(), 
                                itemCount: _yorumlar.length,
                                itemBuilder: (context, index) {
                                  var yorum = _yorumlar[index];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 15),
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: kSoftGrey,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(yorum['musteriAdi'], style: const TextStyle(fontWeight: FontWeight.bold, color: kDarkCoffee)),
                                            RatingBarIndicator(
                                              rating: (yorum['puan'] as int).toDouble(),
                                              itemBuilder: (context, index) => const Icon(Icons.star_rounded, color: Colors.amber),
                                              itemCount: 5,
                                              itemSize: 16.0,
                                              direction: Axis.horizontal,
                                            ),
                                          ],
                                        ),
                                        // Eğer yorum varsa göster, yoksa sadece yıldız yeter
                                        if (yorum['yorum'] != null && yorum['yorum'].toString().isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Text(yorum['yorum'], style: TextStyle(color: kDarkCoffee.withOpacity(0.8), fontSize: 14)),
                                        ],
                                        const SizedBox(height: 5),
                                        Text(
                                          yorum['tarih'].toString().substring(0, 10), 
                                          style: TextStyle(fontSize: 10, color: Colors.grey[500])
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),

                    const SizedBox(height: 120), // Footer ve Buton için boşluk
                  ],
                ),
              ),
            ),
          ),

          // SEPETE EKLE BUTONU (SABİT EN ALTTA)
          Positioned(
            bottom: 20, left: 20, right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: kDarkGreen,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [BoxShadow(color: kDarkGreen.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(15)),
                    child: Row(
                      children: [
                        _buildQtyBtn(Icons.remove, () { if (adet > 1) setState(() => adet--); }),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text("$adet", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                        _buildQtyBtn(Icons.add, () => setState(() => adet++)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        await SepetServisi.sepeteEkle(urun);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${urun.urunAdi} sepete eklendi!"), backgroundColor: kDarkCoffee, duration: const Duration(milliseconds: 800)));
                        }
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("Sepete Ekle", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (indirimVar) Text("${urun.urunSatisFiyati}₺", style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.5), decoration: TextDecoration.lineThrough, decorationColor: Colors.white.withOpacity(0.5))),
                              const SizedBox(width: 8),
                              Text("${urun.indirimliFiyat ?? urun.urunSatisFiyati} ₺", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }

  Widget _buildCircularButton({required IconData icon, required VoidCallback onTap, Color color = kDarkGreen}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 45, width: 45,
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }

  Widget _buildModernBadge(IconData icon, String text, Color accentColor) {
    return Container(
      width: 90, padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: kSoftGrey, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Icon(icon, size: 22, color: accentColor),
          const SizedBox(height: 6),
          Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kDarkCoffee)),
        ],
      ),
    );
  }
}