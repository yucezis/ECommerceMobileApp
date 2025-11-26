import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'urun.dart';
import 'kategori.dart';
import 'categories_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late Future<List<Urun>> _urunlerFuture;
  late Future<List<Kategori>> _kategorilerFuture;

  @override
  void initState() {
    super.initState();
    _urunlerFuture = urunleriGetir();
    _kategorilerFuture = kategorileriGetir();
  }

  String getBaseUrl() {
    if (Platform.isAndroid) {
      return "http://10.180.131.237:5126/api";
    } else {
      return "http://localhost:5126/api";
    }
  }

  Future<List<Urun>> urunleriGetir() async {
    final String adres = "http://10.180.131.237:5126/api/urun";

    final response = await http.get(Uri.parse(adres));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Urun.fromJson(item)).toList();
    } else {
      throw Exception("Ürünler yüklenemedi: ${response.statusCode}");
    }
  }

  Future<List<Kategori>> kategorileriGetir() async {
    final String adres = "http://10.180.131.237:5126/api/Kategori";

    final response = await http.get(Uri.parse(adres));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Kategori.fromJson(item)).toList();
    } else {
      throw Exception("Kategoriler yüklenemedi: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF3E0),
      key: _scaffoldKey,
      drawer: _buildDrawer(),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildSpecialOfferBanner(),
              const SizedBox(height: 25),
              _buildSectionTitle("Kategoriler"),
              const SizedBox(height: 15),
              _buildCategoriesList(),
              const SizedBox(height: 25),

              _buildSectionTitle("Öne Çıkan Kitaplar"),
              const SizedBox(height: 15),
              _buildFeaturedBooksList(),

              const SizedBox(height: 25),

              _buildSectionTitle("Çok Satanlar"),
              const SizedBox(height: 15),
              _buildBestsellersList(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<Urun>> cokSatanlariGetir() async {
    final response = await http.get(
      Uri.parse("${getBaseUrl()}/Urun/CokSatanlar"),
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Urun.fromJson(item)).toList();
    } else {
      throw Exception("Çok satanlar yüklenemedi");
    }
  }

  // --- WIDGETLAR ----------------------------------------------

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color.fromARGB(255,64, 38, 42),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
              const Text(
                "Books",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.notifications_none, color: Colors.white),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
              hintText: "Kitap Arayın...",
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialOfferBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Özel Fiyatlar",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Birçok kitapta indirim!",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7D00),
                  ),
                  child: const Text(
                    "Alışverişe Başla",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.local_offer, size: 60, color: Colors.orange),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          InkWell(
            onTap: () {
              if (title == "Kategoriler") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CategoriesScreen(),
                  ),
                );
              }
            },
            child: const Text(
              "Hepsini Gör >",
              style: TextStyle(
                color: Color.fromARGB(255, 221, 118, 28),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList() {
    return SizedBox(
      height: 100,
      child: FutureBuilder<List<Kategori>>(
        future: _kategorilerFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty)
            return const SizedBox();
          final kategoriler = snapshot.data!;
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20),
            itemCount: kategoriler.length,
            itemBuilder: (context, index) {
              final kategori = kategoriler[index];
              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 15),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.menu_book,
                        color: Color.fromARGB(255, 52, 43, 59),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      kategori.kategoriAdi,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFeaturedBooksList() {
    return SizedBox(
      height: 280,
      child: FutureBuilder<List<Urun>>(
        future: _urunlerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty)
            return const Center(child: Text("Hiç ürün yok"));
          final urunler = snapshot.data!;
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20),
            itemCount: urunler.length,
            itemBuilder: (context, index) {
              final urun = urunler[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(15),
                        ),
                        child: urun.urunGorsel.isNotEmpty
                            ? Image.network(
                                urun.urunGorsel,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (c, o, s) => const Center(
                                  child: Icon(
                                    Icons.book,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : const Center(
                                child: Icon(
                                  Icons.book,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            urun.urunAdi,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            urun.urunMarka,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "${urun.urunSatisFiyati} ₺",
                            style: const TextStyle(
                              color: Color(0xFF6200EE),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBestsellersList() {
    return FutureBuilder<List<Urun>>(
      future: cokSatanlariGetir(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Henüz satış yok."));
        }

        final urunler = snapshot.data!;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: urunler.length,
          itemBuilder: (context, index) {
            final urun = urunler[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: urun.urunGorsel.isNotEmpty
                            ? Image.network(
                                urun.urunGorsel,
                                width: 80,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (c, o, s) => Container(
                                  width: 80,
                                  height: 100,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.book),
                                ),
                              )
                            : Container(
                                width: 80,
                                height: 100,
                                color: Colors.grey[200],
                                child: const Icon(Icons.book),
                              ),
                      ),
                      // Sıralama Rozeti
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                          ),
                          child: Text(
                            "#${index + 1}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 15),
                  // Bilgi Alanı
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          urun.urunAdi,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          (urun.urunYazar != null && urun.urunYazar!.isNotEmpty)
                              ? urun.urunYazar!
                              : urun.urunMarka,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              "${urun.urunSatisFiyati} ₺",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6200EE),
                              ),
                            ),
                            // İndirim varsa eski fiyatı çizili gösterelim
                            if (urun.indirimliFiyat != null &&
                                urun.indirimliFiyat! > 0) ...[
                              const SizedBox(width: 8),
                              Text(
                                "${urun.indirimliFiyat} ₺",
                                style: const TextStyle(
                                  fontSize: 12,
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      // Column yerine ListView kullandık.
      // Böylece kategoriler açılınca ekran taşarsa aşağı kaydırılabilir.
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 1. BÖLÜM: Menü Başlığı (Header - Senin Kodun)
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 48, 42, 57),
            ),
            accountName: const Text(
              "Hoşgeldiniz",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: const Text("Kitap dünyasına dalın!"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: const Icon(
                Icons.person,
                size: 40,
                color: Color.fromARGB(255, 48, 42, 57),
              ),
            ),
          ),

          ExpansionTile(
            leading: const Icon(
              Icons.topic,
              color: Color.fromARGB(255, 48, 42, 57),
            ),
            title: const Text(
              "Kategoriler",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            shape: const Border(),
            childrenPadding: EdgeInsets.zero,

            children: [
              FutureBuilder<List<Kategori>>(
                future: _kategorilerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Kategori bulunamadı"),
                    );
                  }

                  final kategoriler = snapshot.data!;

                  return Column(
                    children: kategoriler.map((kategori) {
                      return ListTile(
                        contentPadding: const EdgeInsets.only(
                          left: 30,
                          right: 10,
                        ),
                        leading: const Icon(
                          Icons.menu_book,
                          size: 20,
                          color: Colors.grey,
                        ),
                        title: Text(
                          kategori.kategoriAdi,
                          style: const TextStyle(fontSize: 15),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: Colors.grey,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),

          ListTile(
            leading: const Icon(
              Icons.settings,
              color: Color.fromARGB(255, 48, 42, 57),
            ),
            title: const Text("Ayarlar", style: TextStyle(fontSize: 16)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(
              Icons.favorite,
              color: Color.fromARGB(255, 48, 42, 57),
            ),
            title: const Text("Favoriler", style: TextStyle(fontSize: 16)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Color.fromARGB(255, 48, 42, 57),
            ),
            title: const Text("Çıkış Yap", style: TextStyle(fontSize: 16)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(
              Icons.accessibility,
              color: Color.fromARGB(255, 48, 42, 57),
            ),
            title: const Text("Hakkımızda", style: TextStyle(fontSize: 16)),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
