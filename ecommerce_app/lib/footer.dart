import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'categories_screen.dart';
import 'product_detail_screen.dart';
import 'models/urun_model.dart';
import 'product_list_screen.dart'; 
import 'cart_screen.dart';

// --- RENK PALETİ ---
const Color kBookPaper = Color(0xFFFEFAE0); 
const Color kDarkGreen = Color(0xFF283618); 
const Color kOliveGreen = Color(0xFF606C38); 
const Color kCreamAccent = Color(0xFFFAEDCD);

class Footer extends StatefulWidget {
  const Footer({super.key});

  static final GlobalKey<FooterState> footerKey = GlobalKey<FooterState>();

  @override
  State<Footer> createState() => FooterState();
}

class FooterState extends State<Footer> {
  int _selectedIndex = 0;

  Widget? _aktifListeSayfasi; 
  Urun? _seciliUrun; 

  void sayfaDegistir(int index) {
    setState(() {
      _selectedIndex = index;
      _aktifListeSayfasi = null;
      _seciliUrun = null;
    });
  }

  void listeAc(Widget sayfa) {
    setState(() {
      _aktifListeSayfasi = sayfa;
      _seciliUrun = null; 
    });
  }

  void listedenCik() {
    setState(() {
      _aktifListeSayfasi = null;
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

  void kategoriyeGit(int id, String adi) {
    listeAc(ProductListScreen(
      title: adi,
      listType: ProductListType.category,
      kategoriId: id,
    ));
  }
  void kategoridenCik() => listedenCik();
  void indirimleriGoster() {
    listeAc(const ProductListScreen(
      title: "Büyük Fırsatlar",
      listType: ProductListType.discount,
    ));
  }
  void indirimdenCik() => listedenCik();


  @override
  Widget build(BuildContext context) {
    Widget aktifSayfa;

    if (_seciliUrun != null) {
      aktifSayfa = ProductDetailScreen(urun: _seciliUrun!);
    }
    
    else if (_aktifListeSayfasi != null) {
      aktifSayfa = _aktifListeSayfasi!;
    }
    else if (_selectedIndex == 0) {
      aktifSayfa = const HomeScreen();
    } 
    else if (_selectedIndex == 1) {
      aktifSayfa = const CategoriesScreen();
    } 
    else if (_selectedIndex == 2) {
      aktifSayfa = const CartScreen(); // <-- BURAYI DEĞİŞTİRDİK
    }
    else {
      aktifSayfa = const ProfileScreen();
    }

    bool navBarGizle = _seciliUrun != null;

    return Scaffold(
      backgroundColor: kBookPaper, 
      resizeToAvoidBottomInset: false, 
      
      body: Stack(
  children: [
    // Padding'i kaldırdık. Artık sayfa en alta kadar uzanacak.
    aktifSayfa,

    if (!navBarGizle)
      Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: _buildCustomNavigationBar(),
      ),
  ],
),
    );
  }

  Widget _buildCustomNavigationBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 25), 
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: kDarkGreen, 
        borderRadius: BorderRadius.circular(30), 
        boxShadow: [
          BoxShadow(
            color: kDarkGreen.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavBarItem(
            icon: Icons.cottage_outlined,
            activeIcon: Icons.cottage,
            label: "Anasayfa",
            isSelected: _selectedIndex == 0,
            onTap: () => sayfaDegistir(0),
          ),
          _NavBarItem(
            icon: Icons.grid_view_outlined,
            activeIcon: Icons.grid_view_rounded,
            label: "Kategoriler",
            isSelected: _selectedIndex == 1,
            onTap: () => sayfaDegistir(1),
          ),
          _NavBarItem(
            icon: Icons.shopping_basket_outlined,
            activeIcon: Icons.shopping_basket,
            label: "Sepet",
            isSelected: _selectedIndex == 2,
            onTap: () => sayfaDegistir(2),
          ),
          _NavBarItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: "Profil",
            isSelected: _selectedIndex == 3,
            onTap: () => sayfaDegistir(3),
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuad,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent, 
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? kCreamAccent : kOliveGreen.withOpacity(0.7),
              size: 24,
            ),
            
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: SizedBox(
                width: isSelected ? null : 0, 
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    isSelected ? label : "",
                    style: const TextStyle(
                      color: kCreamAccent, 
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}