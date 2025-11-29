import 'package:flutter/material.dart';
import 'models/urun_model.dart';
import 'models/favorite_service.dart';
import 'footer.dart';
//import 'product_detail_screen.dart';

// --- RENK PALETİ ---
const Color kBookPaper = Color(0xFFFEFAE0);       // Kart ve Yazı Rengi
const Color kBackgroundAccent = Color(0xFFFAEDCD); // Zemin Rengi
const Color kDarkGreen = Color(0xFF283618);       // Başlık ve Butonlar
const Color kOliveGreen = Color(0xFF606C38);      // İkincil Renkler
const Color kDarkCoffee = Color(0xFF211508);      // Koyu Metinler
const Color kDiscountRed = Color(0xFFBC4749);     // Silme ve İndirim

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Urun> _favoriler = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _verileriGetir();
  }

  // --- MANTIK KISMI (AYNEN KORUNDU) ---
  void _verileriGetir() async {
    var veriler = await FavoriServisi.favorileriGetir();
    setState(() {
      _favoriler = veriler;
      _isLoading = false;
    });
  }

  Future<void> _sil(Urun urun) async {
    await FavoriServisi.favoriDegistir(urun);
    _verileriGetir(); // Listeyi yenile
    // İsteğe bağlı: Kullanıcıya silindiğine dair bilgi verebiliriz
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${urun.urunAdi} favorilerden kaldırıldı.", style: const TextStyle(color: kBookPaper)),
        backgroundColor: kDarkGreen,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // --- TASARIM KISMI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundAccent,
      
      appBar: AppBar(
        toolbarHeight: 80,
        title: const Text(
          "FAVORİLERİM", 
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            color: kBookPaper,
            letterSpacing: 1.5,
            fontSize: 22
          )
        ),
        centerTitle: true,
        backgroundColor: kDarkGreen,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        iconTheme: const IconThemeData(color: kBookPaper), 
      ),
      
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kDarkGreen))
          : _favoriler.isEmpty
              ? _buildBosDurum()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  itemCount: _favoriler.length,
                  itemBuilder: (context, index) {
                    return _buildFavoriKarti(_favoriler[index]);
                  },
                ),
    );
  }

  Widget _buildBosDurum() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: kBookPaper,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: kDarkCoffee.withOpacity(0.1), blurRadius: 20)]
            ),
            child: Icon(Icons.favorite_border, size: 60, color: kOliveGreen.withOpacity(0.5)),
          ),
          const SizedBox(height: 20),
          const Text(
            "Henüz favorin yok.", 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kDarkGreen)
          ),
          const SizedBox(height: 10),
          Text(
            "Beğendiğin kitapları kalp ikonuna\ntıklayarak buraya ekleyebilirsin.", 
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: kDarkCoffee.withOpacity(0.6))
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriKarti(Urun urun) {
    bool indirimVar = urun.indirimliFiyat != null && urun.indirimliFiyat! > 0;
    double guncelFiyat = indirimVar ? urun.indirimliFiyat! : urun.urunSatisFiyati;

    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        Footer.footerKey.currentState?.uruneGit(urun);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: kBookPaper, 
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: kDarkCoffee.withOpacity(0.08), 
              blurRadius: 15, 
              offset: const Offset(0, 5)
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, offset: const Offset(2, 2))]
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  urun.urunGorsel, 
                  width: 70, 
                  height: 100, 
                  fit: BoxFit.cover,
                  errorBuilder: (c, o, s) => Container(width: 70, height: 100, color: Colors.grey[300], child: const Icon(Icons.book)),
                ),
              ),
            ),
            
            const SizedBox(width: 20),
            
            // Ürün Bilgileri
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    urun.urunAdi, 
                    maxLines: 2, 
                    overflow: TextOverflow.ellipsis, 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kDarkCoffee)
                  ),
                  const SizedBox(height: 4),
                  // Eğer modelde yazar yoksa marka gösterilir (Orijinal mantık korunarak)
                  Text(
                    urun.urunYazar.isNotEmpty ? urun.urunYazar : urun.urunMarka,
                    style: const TextStyle(color: kOliveGreen, fontSize: 13, fontStyle: FontStyle.italic)
                  ),
                  const SizedBox(height: 10),
                  
                  // Fiyat Gösterimi
                  if (indirimVar) ...[
                    Row(
                      children: [
                        Text(
                          "${urun.urunSatisFiyati} ₺",
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: kOliveGreen.withOpacity(0.6),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "$guncelFiyat ₺",
                          style: const TextStyle(color: kDiscountRed, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    )
                  ] else ...[
                    Text(
                      "$guncelFiyat ₺", 
                      style: const TextStyle(color: kDarkGreen, fontWeight: FontWeight.bold, fontSize: 18)
                    ),
                  ],
                ],
              ),
            ),
            
            IconButton(
              icon: const Icon(Icons.favorite, size: 28), // Dolu kalp (Favorilerden çıkar anlamında)
              color: kDiscountRed, // Kırmızı
              onPressed: () => _sil(urun),
              tooltip: "Favorilerden Kaldır",
            ),
          ],
        ),
      ),
    );
  }
}