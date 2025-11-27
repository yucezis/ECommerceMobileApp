import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'categories_screen.dart';
import 'category_product_screen.dart';
import 'product_detail_screen.dart';
import 'models/urun_model.dart';

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

    // Sayfa Yönlendirme Mantığı
    if (_seciliUrun != null) {
      aktifSayfa = ProductDetailScreen(urun: _seciliUrun!);
    } else if (_selectedIndex == 0) {
      aktifSayfa = const HomeScreen();
    } else if (_selectedIndex == 1) {
      if (_aktifKategoriId != null) {
        aktifSayfa = CategoryProductsScreen(
          kategoriId: _aktifKategoriId!,
          kategoriAdi: _aktifKategoriAdi!,
        );
      } else {
        aktifSayfa = const CategoriesScreen();
      }
    } else if (_selectedIndex == 2) {
      aktifSayfa = const Center(child: Text("Sepet Sayfası")); // Sepet ekranın buraya gelecek
    } else {
      aktifSayfa = const ProfileScreen();
    }

    // Ürün detay sayfasındaysak navigasyon barı gizle (Çünkü ürün detayda kendi barı var)
    bool navBarGizle = _seciliUrun != null;

    return Scaffold(
      backgroundColor: kBookPaper, // Genel arka plan
      // Klavye açıldığında butonların yukarı kaymasını engellemek için:
      resizeToAvoidBottomInset: false, 
      
      // Body Stack ile sarılırsa nav bar sayfanın üstünde yüzebilir (floating effect)
      body: Stack(
        children: [
          // Aktif Sayfa İçeriği
          aktifSayfa,

          // Özel Navigasyon Barı (Alt Kısım)
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
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 25), // Kenarlardan boşluk bırakarak "Floating" hissi ver
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: kDarkGreen, // Koyu Yeşil Arka Plan
        borderRadius: BorderRadius.circular(30), // Tam yuvarlak köşeler
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

// --- ÖZEL NAVİGASYON BUTONU ---
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
          // Seçiliyse açık renk, değilse şeffaf
          color: isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent, 
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? kCreamAccent : kOliveGreen.withOpacity(0.7), // Pasif ikonlar daha soluk
              size: 24,
            ),
            
            // Seçili olduğunda metni göster (Animasyonlu genişleme)
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: SizedBox(
                width: isSelected ? null : 0, // Seçili değilse genişlik 0
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    isSelected ? label : "",
                    style: const TextStyle(
                      color: kCreamAccent, // Krem rengi yazı
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