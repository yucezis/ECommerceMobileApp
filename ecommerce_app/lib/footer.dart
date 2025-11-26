import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'categories_screen.dart';
import 'category_product_screen.dart';
import 'product_detail_screen.dart';
import 'models/urun_model.dart';

class Footer extends StatefulWidget {
  const Footer({super.key});

  static final GlobalKey<FooterState> footerKey = GlobalKey<FooterState>();

  @override
 
  State<Footer> createState() => FooterState();
}

class FooterState extends State<Footer> {
  int _selectedIndex = 0;
  int? _aktifKategoriId;
  String? _aktifKategoriAdi;
  Urun? _seciliUrun;

  void sayfaDegistir(int index) {
    setState(() {
      _selectedIndex = index;
      _aktifKategoriId = null; 
      _seciliUrun = null;
    });
  }

  void kategoriyeGit(int id, String adi) {
    setState(() {
      _selectedIndex = 1; 
      _aktifKategoriId = id;
      _aktifKategoriAdi = adi;
      _seciliUrun = null;
    });
  }

  void kategoridenCik() {
    setState(() {
      _aktifKategoriId = null; 
    });
  }

  void uruneGit(Urun urun) {
    setState(() {
      _seciliUrun = urun;
    });
  }

  void urundenCik() {
    setState(() {
      _seciliUrun = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget aktifSayfa;

    if (_seciliUrun != null) {
      aktifSayfa = ProductDetailScreen(urun: _seciliUrun!);
    }
    else if (_selectedIndex == 0) {
      aktifSayfa = const HomeScreen();
    } 
    else if (_selectedIndex == 1) {
      if (_aktifKategoriId != null) {
        aktifSayfa = CategoryProductsScreen(
          kategoriId: _aktifKategoriId!,
          kategoriAdi: _aktifKategoriAdi!,
        );
      } else {
        aktifSayfa = const CategoriesScreen();
      }
    } 
    else if (_selectedIndex == 2) {
      aktifSayfa = const Center(child: Text("Sepet Sayfası"));
    } 
    else {
      aktifSayfa = const ProfileScreen();
    }

    return Scaffold(
      body: aktifSayfa,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF6200EE),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          sayfaDegistir(index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.category_outlined), label: "Kategoriler"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: "Sepet"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profil"),
        ],
      ),
    );
  }
}