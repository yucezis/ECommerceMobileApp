import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'kategori.dart'; 

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late Future<List<Kategori>> _kategorilerFuture;

 
  final List<Color> _cardColors = [
    const Color(0xFFE3F2FD), 
    const Color(0xFFFCE4EC), 
    const Color(0xFFE0F7FA),
    const Color(0xFFFFF3E0), 
    const Color(0xFFF3E5F5), 
    const Color(0xFFE8F5E9), 
  ];

  
  final List<IconData> _icons = [
    Icons.menu_book,
    Icons.search,
    Icons.favorite,
    Icons.rocket_launch,
    Icons.auto_stories,
    Icons.psychology,
    Icons.history_edu,
    Icons.star,
  ];

  @override
  void initState() {
    super.initState();
    _kategorilerFuture = kategorileriGetir();
  }

  // --- API BAĞLANTISI ---
  String getBaseUrl() {
    if (Platform.isAndroid) {
      return "http://10.0.2.2:5126/api"; // Port numaran: 5126
    } else {
      return "http://10.180.131.237:5126/api";
    }
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
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 1. MOR BAŞLIK VE ARAMA ALANI
          _buildHeader(context),

          // 2. KATEGORİLER IZGARASI (GRID)
          Expanded(
            child: FutureBuilder<List<Kategori>>(
              future: _kategorilerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Hata: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Kategori bulunamadı."));
                }

                final kategoriler = snapshot.data!;

                return GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Yan yana 2 tane
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.1, // Kartın en/boy oranı
                  ),
                  itemCount: kategoriler.length,
                  itemBuilder: (context, index) {
                    final kategori = kategoriler[index];
                    // Renk ve İkon seçimi (Sırayla)
                    final color = _cardColors[index % _cardColors.length];
                    final icon = _icons[index % _icons.length];

                    return Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // İkon (Veritabanında olmadığı için listeden seçiyoruz)
                          Icon(icon, size: 40, color: Colors.black54), // İstersen renkli yapabilirsin
                          const SizedBox(height: 10),
                          
                          // Kategori Adı
                          Text(
                            kategori.kategoriAdi,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 5),
                          
                          // Kitap Sayısı (API'de olmadığı için temsili gösteriyoruz)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${(index + 1) * 124} books", // Temsili sayı
                                style: const TextStyle(fontSize: 12, color: Colors.black54),
                              ),
                              const SizedBox(width: 5),
                              const Icon(Icons.arrow_forward_ios, size: 10, color: Colors.black45)
                            ],
                          )
                        ],
                      ),
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

  // ÖZEL HEADER TASARIMI
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF6200EE), // Mor Renk
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0), // Tasarımda düz görünüyor ama istersen 30 yapabilirsin
          bottomRight: Radius.circular(0),
        ),
      ),
      child: Column(
        children: [
          // Geri Butonu ve Başlık
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context), // Geri dön
              ),
              const Text(
                "Kategoriler",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Stack(
                children: [
                  const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: const Text("3", style: TextStyle(color: Colors.white, fontSize: 10)),
                    ),
                  )
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Arama Çubuğu
          TextField(
            decoration: InputDecoration(
              hintText: "Kategori Ara...",
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10), // Köşeli tasarım
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}