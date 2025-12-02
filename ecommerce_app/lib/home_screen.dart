import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'models/urun_model.dart';
import 'models/kategori_model.dart';
import 'footer.dart';
import 'product_list_screen.dart';
import 'favorite_screen.dart';

const Color kBookPaper = Color(0xFFFEFAE0);
const Color kDarkGreen = Color(0xFF283618);
const Color kOliveGreen = Color(0xFF606C38);
const Color kDarkCoffee = Color(0xFF211508);
const Color kCreamAccent = Color(0xFFFAEDCD);
const Color kpink = Color.fromARGB(255, 188, 71, 73);

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
    String ipAdresim = "10.180.131.237";
    String port = "5126";
    return "http://$ipAdresim:$port/api";
  }

  Future<List<Urun>> urunleriGetir() async {
    final String adres = "${getBaseUrl()}/urun";
    final response = await http.get(Uri.parse(adres));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Urun.fromJson(item)).toList();
    } else {
      throw Exception("Ürünler yüklenemedi: ${response.statusCode}");
    }
  }

  Future<List<Kategori>> kategorileriGetir() async {
    final String adres = "${getBaseUrl()}/Kategori";
    final response = await http.get(Uri.parse(adres));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Kategori.fromJson(item)).toList();
    } else {
      throw Exception("Kategoriler yüklenemedi: ${response.statusCode}");
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: kBookPaper,
      drawer: _buildDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 25),

              _buildSpecialOfferBanner(),
              const SizedBox(height: 30),

              _buildSectionTitle("Kategoriler"),
              const SizedBox(height: 15),
              _buildCategoriesList(),
              const SizedBox(height: 30),

              _buildSectionTitle("Öne Çıkan Kitaplar"),
              const SizedBox(height: 15),
              _buildFeaturedBooksList(),
              const SizedBox(height: 30),

              _buildSectionTitle("Çok Satanlar"),
              const SizedBox(height: 15),
              _buildBestsellersList(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETLAR ----------------------------------------------

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      decoration: const BoxDecoration(
        color: kDarkGreen, // Header rengi
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.menu_rounded,
                  color: kBookPaper,
                  size: 28,
                ),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              const Row(
                children: [
                  Icon(Icons.auto_stories, color: kBookPaper),
                  SizedBox(width: 8),
                  Text(
                    "Books",
                    style: TextStyle(
                      color: kBookPaper,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              Container(
  decoration: BoxDecoration(
    color: kOliveGreen.withOpacity(0.5),
    shape: BoxShape.circle,
  ),
  child: IconButton(
    icon: const Icon(Icons.favorite_outline, color: kBookPaper),
    // HATALI OLAN: onTap: () { ... }
    // DOĞRUSU:
    onPressed: () { 
      Navigator.push(
        context, 
        MaterialPageRoute(builder: (context) => const FavoritesScreen())
      );
    },
  ),
),
            ],
          ),
          const SizedBox(height: 25),
          TextField(
            style: const TextStyle(color: kDarkGreen),
            decoration: InputDecoration(
              hintText: "Kitap, yazar veya kategori ara...",
              hintStyle: TextStyle(color: kDarkGreen.withOpacity(0.5)),
              prefixIcon: const Icon(Icons.search, color: kOliveGreen),
              filled: true,
              fillColor: kBookPaper,
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
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
        color: kOliveGreen,
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: NetworkImage(
            "https://www.transparenttextures.com/patterns/cubes.png",
          ),
          fit: BoxFit.cover,
          opacity: 0.1,
        ),
        boxShadow: [
          BoxShadow(
            color: kOliveGreen.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: kCreamAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "%50 İNDİRİM",
                    style: TextStyle(
                      color: kDarkCoffee,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                const Text(
                  "Birçok Kitapta\nBüyük Fırsat",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    Footer.footerKey.currentState?.listeAc(
                      const ProductListScreen(
                        title: "Büyük Fırsatlar",
                        listType: ProductListType.discount,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kBookPaper,
                    foregroundColor: kDarkGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "İncele",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          // Süsleme İkonu
          Transform.rotate(
            angle: -0.2,
            child: const Icon(Icons.menu_book, size: 90, color: Colors.white24),
          ),
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
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: kDarkCoffee,
            ),
          ),
          InkWell(
            onTap: () {
              if (title == "Kategoriler") {
                Footer.footerKey.currentState?.sayfaDegistir(1);
              } else if (title == "Çok Satanlar") {
                Footer.footerKey.currentState?.listeAc(
                  const ProductListScreen(
                    title: "Çok Satanlar",
                    listType: ProductListType.bestSeller,
                  ),
                );
              }
            },
            child: const Row(
              children: [
                Text(
                  "Tümü",
                  style: TextStyle(
                    color: kOliveGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Icon(Icons.arrow_right_alt, color: kOliveGreen, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList() {
    return SizedBox(
      height: 45,
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
              return GestureDetector(
                onTap: () {
                  Footer.footerKey.currentState?.listeAc(
                    ProductListScreen(
                      title: kategori.kategoriAdi,
                      listType: ProductListType.category,
                      kategoriId: kategori.kategoriID,
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: kOliveGreen.withOpacity(0.3)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    kategori.kategoriAdi,
                    style: const TextStyle(
                      color: kDarkGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
      height: 290,
      child: FutureBuilder<List<Urun>>(
        future: _urunlerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: kOliveGreen),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Hiç ürün yok"));
          }
          final urunler = snapshot.data!;
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20),
            itemCount: urunler.length,
            itemBuilder: (context, index) {
              final urun = urunler[index];
              return GestureDetector(
                onTap: () {
                  Footer.footerKey.currentState?.uruneGit(urun);
                },
                child: Container(
                  width: 150,
                  margin: const EdgeInsets.only(right: 15, bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: kDarkCoffee.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
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
                                  errorBuilder: (c, o, s) => Container(
                                    color: kCreamAccent,
                                    child: const Center(
                                      child: Icon(
                                        Icons.book,
                                        color: kOliveGreen,
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  color: kCreamAccent,
                                  child: const Center(
                                    child: Icon(Icons.book, color: kOliveGreen),
                                  ),
                                ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
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
                                color: kDarkCoffee,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              urun.urunMarka,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${urun.urunSatisFiyati} ₺",
                                  style: const TextStyle(
                                    color: kDarkGreen,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const Icon(
                                  Icons.favorite_outline,
                                  color: kpink,
                                  size: 20,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
          return const Center(
            child: CircularProgressIndicator(color: kOliveGreen),
          );
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
            return GestureDetector(
              onTap: () {
                Footer.footerKey.currentState?.uruneGit(urun);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: kDarkCoffee.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
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
                                  width: 70,
                                  height: 90,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, o, s) => Container(
                                    width: 70,
                                    height: 90,
                                    color: kCreamAccent,
                                    child: const Icon(
                                      Icons.book,
                                      color: kOliveGreen,
                                    ),
                                  ),
                                )
                              : Container(
                                  width: 70,
                                  height: 90,
                                  color: kCreamAccent,
                                  child: const Icon(
                                    Icons.book,
                                    color: kOliveGreen,
                                  ),
                                ),
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: const BoxDecoration(
                              color: Color(
                                0xFFBC4749,
                              ),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                bottomRight: Radius.circular(8),
                              ),
                            ),
                            child: Text(
                              "${index + 1}",
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
                              color: kDarkCoffee,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            urun.urunYazar.isNotEmpty
                                ? urun.urunYazar
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
                                  color: kDarkGreen,
                                ),
                              ),
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
                    const Icon(Icons.chevron_right, color: kOliveGreen),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: kBookPaper,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: kDarkGreen),
            accountName: const Text(
              "Hoşgeldiniz",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: const Text("Kitap dünyasına dalın!"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: kBookPaper,
              child: const Icon(Icons.person, size: 40, color: kDarkGreen),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ExpansionTile(
                  iconColor: kDarkGreen,
                  collapsedIconColor: kOliveGreen,
                  leading: const Icon(Icons.category, color: kOliveGreen),
                  title: const Text(
                    "Kategoriler",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: kDarkCoffee,
                    ),
                  ),
                  children: [
                    FutureBuilder<List<Kategori>>(
                      future: _kategorilerFuture,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.isEmpty)
                          return const SizedBox();
                        return Column(
                          children: snapshot.data!.map((kategori) {
                            return ListTile(
                              contentPadding: const EdgeInsets.only(left: 40),
                              leading: const Icon(
                                Icons.circle,
                                size: 8,
                                color: kOliveGreen,
                              ),
                              title: Text(
                                kategori.kategoriAdi,
                                style: const TextStyle(fontSize: 14),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                                Footer.footerKey.currentState?.kategoriyeGit(
                                  kategori.kategoriID,
                                  kategori.kategoriAdi,
                                );
                              },
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
                ListTile(
                  leading: const Icon(Icons.settings, color: kOliveGreen),
                  title: const Text(
                    "Ayarlar",
                    style: TextStyle(color: kDarkCoffee),
                  ),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.favorite, color: kOliveGreen),
                  title: const Text(
                    "Favoriler",
                    style: TextStyle(color: kDarkCoffee),
                  ),
                  onTap: () => Navigator.pop(context),
                ),
                const Divider(color: Colors.grey),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  title: const Text(
                    "Çıkış Yap",
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
