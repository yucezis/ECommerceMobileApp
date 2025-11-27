import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'models/kategori_model.dart';
import 'footer.dart';

// --- RENK PALETİ ---
const Color kBookPaper = Color(0xFFFEFAE0); 
const Color kDarkGreen = Color(0xFF283618); 
const Color kOliveGreen = Color(0xFF606C38); 
const Color kDarkCoffee = Color(0xFF211508); 

final List<Color> _earthyCardColors = [
  const Color(0xFFFAEDCD), 
  const Color(0xFFE9EDC9), 
  const Color(0xFFCCD5AE), 
  const Color(0xFFD4A373).withOpacity(0.3), 
  const Color(0xFFFEFAE0), 
  const Color(0xFFE0E5B6), 
];

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late Future<List<Kategori>> _kategorilerFuture;

  final List<IconData> _icons = [
    Icons.menu_book_rounded, Icons.history_edu_rounded, Icons.science_rounded,
    Icons.auto_stories_rounded, Icons.psychology_rounded, Icons.rocket_launch_rounded,
    Icons.child_care_rounded, Icons.brush_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _kategorilerFuture = kategorileriGetir();
  }

  String getBaseUrl() {
    String ipAdresim = "10.180.131.237"; // IP adresini kontrol et
    String port = "5126";
    return "http://$ipAdresim:$port/api";
  }

  Future<List<Kategori>> kategorileriGetir() async {
    final response = await http.get(Uri.parse("${getBaseUrl()}/Kategori"));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Kategori.fromJson(item)).toList();
    } else {
      throw Exception("Kategoriler yüklenemedi");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBookPaper,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: FutureBuilder<List<Kategori>>(
              future: _kategorilerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: kDarkGreen));
                } else if (snapshot.hasError) {
                  return Center(child: Text("Hata: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Kategori bulunamadı.", style: TextStyle(color: kOliveGreen)));
                }

                final kategoriler = snapshot.data!;

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.3,
                  ),
                  itemCount: kategoriler.length,
                  itemBuilder: (context, index) {
                    return _buildCategoryCard(
                      kategoriler[index], 
                      _earthyCardColors[index % _earthyCardColors.length], 
                      _icons[index % _icons.length]
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Kategori kategori, Color color, IconData icon) {
    // Material widget'ı ekledik ki InkWell efekti görünsün ve tıklama algılansın
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          debugPrint("TIKLANDI: ${kategori.kategoriAdi} (ID: ${kategori.kategoriID})");
          
          if (Footer.footerKey.currentState != null) {
            // Footer'a git ve kategori değiştir
            Footer.footerKey.currentState?.kategoriyeGit(
              kategori.kategoriID,
              kategori.kategoriAdi,
            );
          } else {
            debugPrint("HATA: Footer Key bulunamadı! main.dart dosyasını kontrol et.");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Menü hatası: main.dart dosyasında key eksik!"))
            );
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: kDarkGreen.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: kDarkGreen),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  kategori.kategoriAdi,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: kDarkCoffee,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 25),
      decoration: const BoxDecoration(
        color: kDarkGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // GERİ BUTONU DÜZELTİLDİ
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: kBookPaper, size: 22),
                onPressed: () {
                  // Artık Navigator.pop değil, Ana Sayfa sekmesine dön diyoruz
                  Footer.footerKey.currentState?.sayfaDegistir(0);
                },
              ),
              const Text(
                "Kategoriler",
                style: TextStyle(
                  color: kBookPaper,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              // Sepet İkonu
              Stack(
                children: [
                  IconButton(
                    onPressed: () {}, 
                    icon: const Icon(Icons.shopping_bag_outlined, color: kBookPaper, size: 28),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Color(0xFFBC4749), shape: BoxShape.circle),
                      child: const Text("3", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            style: const TextStyle(color: kDarkGreen),
            decoration: InputDecoration(
              hintText: "Kategori Ara...",
              hintStyle: TextStyle(color: kDarkGreen.withOpacity(0.5)),
              prefixIcon: const Icon(Icons.search, color: kOliveGreen),
              filled: true,
              fillColor: kBookPaper,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}