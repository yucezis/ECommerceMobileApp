import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'models/urun_model.dart';
import 'models/kategori_model.dart';
import 'footer.dart';
import 'product_list_screen.dart';
import 'favorite_screen.dart';
import 'product_detail_screen.dart';

// RENK PALETİ
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

  // --- DEĞİŞKENLER ---
  late Future<List<Kategori>> _kategorilerFuture;
  late Future<List<Urun>> _cokSatanlarFuture; // Çok satanlar için ayrı future
  
  List<Urun> _tumUrunler = [];          
  List<Urun> _filtrelenmisUrunler = []; 
  bool _urunlerYukleniyor = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _urunleriGetir();
    _kategorilerFuture = kategorileriGetir();
    _cokSatanlarFuture = cokSatanlariGetir();
  }

  String getBaseUrl() {
    return "http://10.180.131.237:5126/api"; 
  }

  // 1. TÜM ÜRÜNLERİ ÇEK (Arama ve Öne Çıkanlar İçin)
  Future<void> _urunleriGetir() async {
    try {
      final response = await http.get(Uri.parse("${getBaseUrl()}/urun"));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        List<Urun> gelenUrunler = body.map((item) => Urun.fromJson(item)).toList();

        if (mounted) {
          setState(() {
            _tumUrunler = gelenUrunler;
            _filtrelenmisUrunler = gelenUrunler;
            _urunlerYukleniyor = false;
          });
        }
      } else {
        throw Exception("Hata: ${response.statusCode}");
      }
    } catch (e) {
      print("Ürün çekme hatası: $e");
      if (mounted) setState(() => _urunlerYukleniyor = false);
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

  Future<List<Urun>> cokSatanlariGetir() async {
    final response = await http.get(Uri.parse("${getBaseUrl()}/Urun/CokSatanlar"));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Urun.fromJson(item)).toList();
    } else {
      throw Exception("Çok satanlar yüklenemedi");
    }
  }

  // 2. ARAMA MANTIĞI
  void _aramaYap(String kelime) {
    if (kelime.isEmpty) {
      setState(() => _filtrelenmisUrunler = _tumUrunler);
    } else {
      setState(() {
        _filtrelenmisUrunler = _tumUrunler.where((urun) {
          final ad = urun.urunAdi.toLowerCase();
          final yazar = (urun.urunYazar ?? "").toLowerCase();
          final marka = (urun.urunMarka ?? "").toLowerCase();
          final aranan = kelime.toLowerCase();
          return ad.contains(aranan) || yazar.contains(aranan) || marka.contains(aranan);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool aramaAktif = _searchController.text.isNotEmpty;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: kBookPaper,
      drawer: _buildDrawer(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),

            Expanded(
              child: _urunlerYukleniyor
                  ? const Center(child: CircularProgressIndicator(color: kDarkGreen))
                  : aramaAktif
                      // ARAMA SONUÇLARI
                      ? _filtrelenmisUrunler.isEmpty
                          ? const Center(child: Text("Sonuç bulunamadı."))
                          : GridView.builder(
                              padding: const EdgeInsets.all(20),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.7,
                                crossAxisSpacing: 15,
                                mainAxisSpacing: 15,
                              ),
                              itemCount: _filtrelenmisUrunler.length,
                              itemBuilder: (context, index) {
                                return _buildProductCard(_filtrelenmisUrunler[index]);
                              },
                            )
                      // ANA SAYFA İÇERİĞİ
                      : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                              // ÇOK SATANLAR LİSTESİ (ROZETLİ)
                              _buildBestsellersList(),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETLAR ---

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      decoration: const BoxDecoration(
        color: kDarkGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.menu_rounded, color: kBookPaper, size: 28),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              const Row(
                children: [
                  Icon(Icons.auto_stories, color: kBookPaper),
                  SizedBox(width: 8),
                  Text("Books", style: TextStyle(color: kBookPaper, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ],
              ),
              Container(
                decoration: BoxDecoration(color: kOliveGreen.withOpacity(0.5), shape: BoxShape.circle),
                child: IconButton(
                  icon: const Icon(Icons.favorite_outline, color: kBookPaper),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritesScreen()));
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          TextField(
            controller: _searchController,
            onChanged: _aramaYap,
            style: const TextStyle(color: kDarkGreen),
            decoration: InputDecoration(
              hintText: "Kitap, yazar veya kategori ara...",
              hintStyle: TextStyle(color: kDarkGreen.withOpacity(0.5)),
              prefixIcon: const Icon(Icons.search, color: kOliveGreen),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: kDarkGreen),
                      onPressed: () {
                        _searchController.clear();
                        _aramaYap('');
                        FocusScope.of(context).unfocus();
                      },
                    )
                  : null,
              filled: true,
              fillColor: kBookPaper,
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  // Öne Çıkanlar (Yatay)
  Widget _buildFeaturedBooksList() {
    if (_tumUrunler.isEmpty) return const Center(child: Text("Ürün bulunamadı"));
    return SizedBox(
      height: 290,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20),
        itemCount: _tumUrunler.length,
        itemBuilder: (context, index) {
          final urun = _tumUrunler[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(urun: urun)));
            },
            child: _buildCardContent(urun),
          );
        },
      ),
    );
  }

  // Genel Kart Tasarımı
  Widget _buildCardContent(Urun urun) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 15, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: kDarkCoffee.withOpacity(0.1), spreadRadius: 2, blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: urun.urunGorsel.isNotEmpty
                  ? Image.network(urun.urunGorsel, width: double.infinity, fit: BoxFit.cover,
                      errorBuilder: (c, o, s) => Container(color: kCreamAccent, child: const Center(child: Icon(Icons.book, color: kOliveGreen))))
                  : Container(color: kCreamAccent, child: const Center(child: Icon(Icons.book, color: kOliveGreen))),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(urun.urunAdi, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: kDarkCoffee)),
                const SizedBox(height: 4),
                Text(urun.urunYazar ?? urun.urunMarka, style: const TextStyle(fontSize: 12, color: kOliveGreen), maxLines: 1),
                const SizedBox(height: 8),
                Text("${urun.urunSatisFiyati} ₺", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: kDarkGreen)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Arama Sonuçları Kartı
  Widget _buildProductCard(Urun urun) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(urun: urun)));
      },
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Container(width: double.infinity, color: Colors.grey[200],
                  child: Image.network(urun.urunGorsel, fit: BoxFit.cover,
                    errorBuilder: (c, o, s) => const Icon(Icons.book, color: Colors.grey, size: 40)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(urun.urunAdi, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: kDarkCoffee)),
                  const SizedBox(height: 4),
                  Text("${urun.urunSatisFiyati} ₺", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: kDarkGreen)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- ÇOK SATANLAR (ROZETLİ) ---
  Widget _buildBestsellersList() {
    return FutureBuilder<List<Urun>>(
      future: _cokSatanlarFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: kOliveGreen));
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Henüz satış yok."));
        
        final urunler = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: urunler.length,
          itemBuilder: (context, index) {
            final urun = urunler[index];
            return GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(urun: urun))),
              child: Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: kDarkCoffee.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
                child: Row(
                  children: [
                    // GÖRSEL VE ROZET
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(urun.urunGorsel, width: 70, height: 90, fit: BoxFit.cover, errorBuilder: (c, o, s) => const Icon(Icons.book)),
                        ),
                        // --- ROZET BURADA ---
                        Positioned(
                          top: 0, left: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: const BoxDecoration(
                              color: Color(0xFFBC4749),
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomRight: Radius.circular(8)),
                            ),
                            child: Text("${index + 1}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 15),
                    // BİLGİLER VE FİYAT
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(urun.urunAdi, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: kDarkCoffee)),
                      const SizedBox(height: 4),
                      Text(urun.urunYazar ?? urun.urunMarka, style: const TextStyle(fontSize: 12, color: kOliveGreen)),
                      const SizedBox(height: 8),
                      Text("${urun.urunSatisFiyati} ₺", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: kDarkGreen))
                    ]))
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Kategori Listesi
  Widget _buildCategoriesList() {
    return SizedBox(
      height: 45,
      child: FutureBuilder<List<Kategori>>(
        future: _kategorilerFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox();
          final kategoriler = snapshot.data!;
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20),
            itemCount: kategoriler.length,
            itemBuilder: (context, index) {
              final kategori = kategoriler[index];
              return GestureDetector(
                onTap: () {
                  Footer.footerKey.currentState?.listeAc(ProductListScreen(title: kategori.kategoriAdi, listType: ProductListType.category, kategoriId: kategori.kategoriID));
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), border: Border.all(color: kOliveGreen.withOpacity(0.3))),
                  alignment: Alignment.center,
                  child: Text(kategori.kategoriAdi, style: const TextStyle(color: kDarkGreen, fontWeight: FontWeight.w600)),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kDarkCoffee)),
          InkWell(
            onTap: () {
              if (title == "Kategoriler") Footer.footerKey.currentState?.sayfaDegistir(1);
              else if (title == "Çok Satanlar") Footer.footerKey.currentState?.listeAc(const ProductListScreen(title: "Çok Satanlar", listType: ProductListType.bestSeller));
            },
            child: const Row(children: [Text("Tümü", style: TextStyle(color: kOliveGreen, fontWeight: FontWeight.w600, fontSize: 14)), Icon(Icons.arrow_right_alt, color: kOliveGreen, size: 20)]),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialOfferBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: kOliveGreen, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: kOliveGreen.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))]),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: kCreamAccent, borderRadius: BorderRadius.circular(8)), child: const Text("%50 İNDİRİM", style: TextStyle(color: kDarkCoffee, fontWeight: FontWeight.bold, fontSize: 12))),
              const SizedBox(height: 10),
              const Text("Birçok Kitapta\nBüyük Fırsat", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 15),
              ElevatedButton(onPressed: () { Footer.footerKey.currentState?.listeAc(const ProductListScreen(title: "Büyük Fırsatlar", listType: ProductListType.discount)); }, style: ElevatedButton.styleFrom(backgroundColor: kBookPaper, foregroundColor: kDarkGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text("İncele", style: TextStyle(fontWeight: FontWeight.bold))),
            ]),
          ),
          const Icon(Icons.menu_book, size: 90, color: Colors.white24),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: kBookPaper,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: kDarkGreen),
            accountName: const Text("Hoşgeldiniz", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            accountEmail: const Text("Kitap dünyasına dalın!"),
            currentAccountPicture: CircleAvatar(backgroundColor: kBookPaper, child: const Icon(Icons.person, size: 40, color: kDarkGreen)),
          ),
        ],
      ),
    );
  }
}