import 'package:flutter/material.dart';
import 'models/urun_model.dart';
import 'models/cart_service.dart';
import 'footer.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'models/cart_service.dart'; 

// --- RENK PALETİ ---
const Color kBookPaper = Color(0xFFFEFAE0);
const Color kBackgroundAccent = Color(0xFFFAEDCD);
const Color kDarkGreen = Color(0xFF283618);
const Color kOliveGreen = Color(0xFF606C38);
const Color kDarkCoffee = Color(0xFF211508);
const Color kDiscountRed = Color(0xFFBC4749);

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

// 👇 TÜM KODLAR BU SINIFIN İÇİNDE OLMALI 👇
class _CartScreenState extends State<CartScreen> {
  List<Urun> _sepetUrunleri = [];
  bool _isLoading = true;
  double _toplamTutar = 0;

  @override
  void initState() {
    super.initState();
    _sepetiYukle();
  }

  Future<void> _sepetiYukle() async {
    List<Urun> urunler = await SepetServisi.sepetiGetir();
    double toplam = 0;
    for (var u in urunler) {
      double fiyat = (u.indirimliFiyat != null && u.indirimliFiyat! > 0)
          ? u.indirimliFiyat!
          : u.urunSatisFiyati;
      toplam += fiyat;
    }

    if (mounted) {
      setState(() {
        _sepetUrunleri = urunler;
        _toplamTutar = toplam;
        _isLoading = false;
      });
    }
  }

  Future<void> _urunuSil(int id) async {
    await SepetServisi.sepettenSil(id);
    _sepetiYukle();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ürün sepetten çıkarıldı.", style: TextStyle(color: kBookPaper)),
          backgroundColor: kDarkGreen,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  // 👇 _satinAl FONKSİYONU BURADA (SINIFIN İÇİNDE) OLMALI 👇
  Future<void> _satinAl() async {
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final int? musteriId = prefs.getInt('musteriId');

    if (musteriId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Sipariş vermek için lütfen giriş yapın."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      setState(() => _isLoading = false);
      return;
    }

    String ipAdresim = "10.180.131.237"; 
    String port = "5126";
    final url = Uri.parse("http://$ipAdresim:$port/api/Musteris/SepetOnayla");

    try {
      final bodyVerisi = jsonEncode({
        "MusteriId": musteriId,
        "SepetUrunleri": _sepetUrunleri.map((e) => {
          "UrunId": e.urunId,
          "Fiyat": (e.indirimliFiyat != null && e.indirimliFiyat! > 0) 
                   ? e.indirimliFiyat 
                   : e.urunSatisFiyati
        }).toList(),
      });
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: bodyVerisi,
      );

      if (response.statusCode == 200) {
        var cevapJson = jsonDecode(response.body);
        String siparisNo = cevapJson['siparisNo'] ?? "---";

        await SepetServisi.sepetiBosalt();

        if (mounted) {
          setState(() {
            _sepetUrunleri = [];
            _toplamTutar = 0;
            _isLoading = false;
          });

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 30),
                  SizedBox(width: 10),
                  Text("Sipariş Alındı!", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              content: Text(
                "Siparişiniz başarıyla oluşturuldu.\n\nSipariş No:\n👉 $siparisNo\n\nSiparişlerim sayfasından durumunu takip edebilirsiniz.",
                style: const TextStyle(fontSize: 16),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Tamam", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kDarkGreen)),
                )
              ],
            ),
          );
        }
      } else {
        throw Exception("Sunucu Hatası: ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Bir hata oluştu: $e"), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundAccent,
      appBar: AppBar(
        toolbarHeight: 80,
        title: const Text(
          "SEPETİM",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: kBookPaper,
            letterSpacing: 1.5,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: kDarkGreen,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        iconTheme: const IconThemeData(color: kBookPaper),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kDarkGreen))
          : _sepetUrunleri.isEmpty
              ? _buildBosSepet()
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        itemCount: _sepetUrunleri.length,
                        itemBuilder: (context, index) {
                          return _buildSepetKarti(_sepetUrunleri[index]);
                        },
                      ),
                    ),
                    _buildAltToplam(),
                    const SizedBox(height: 100), // Footer boşluğu
                  ],
                ),
    );
  }

  Widget _buildBosSepet() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: kBookPaper,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: kDarkCoffee.withOpacity(0.1), blurRadius: 20)],
            ),
            child: Icon(
              Icons.shopping_basket_outlined,
              size: 60,
              color: kOliveGreen.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Sepetiniz henüz boş.",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kDarkGreen),
          ),
          const SizedBox(height: 10),
          Text(
            "Beğendiğiniz kitapları eklemeye başlayın.",
            style: TextStyle(fontSize: 14, color: kDarkCoffee.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }

  Widget _buildSepetKarti(Urun urun) {
    bool indirimVar = urun.indirimliFiyat != null && urun.indirimliFiyat! > 0;
    double guncelFiyat = indirimVar ? urun.indirimliFiyat! : urun.urunSatisFiyati;

    return GestureDetector(
      onTap: () {
        Footer.footerKey.currentState?.uruneGit(urun);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: kBookPaper,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: kDarkCoffee.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))
          ],
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, offset: const Offset(2, 2))],
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(urun.urunAdi, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kDarkCoffee)),
                  const SizedBox(height: 4),
                  Text(urun.urunYazar.isNotEmpty ? urun.urunYazar : urun.urunMarka, style: const TextStyle(color: kOliveGreen, fontSize: 13, fontStyle: FontStyle.italic)),
                  const SizedBox(height: 10),
                  if (indirimVar) ...[
                    Row(
                      children: [
                        Text("${urun.urunSatisFiyati} ₺", style: TextStyle(decoration: TextDecoration.lineThrough, color: kOliveGreen.withOpacity(0.6), fontSize: 14)),
                        const SizedBox(width: 8),
                        Text("$guncelFiyat ₺", style: const TextStyle(color: kDiscountRed, fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    )
                  ] else ...[
                    Text("$guncelFiyat ₺", style: const TextStyle(color: kDarkGreen, fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              color: kDiscountRed,
              onPressed: () => _urunuSil(urun.urunId),
              tooltip: "Sepetten Çıkar",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAltToplam() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
      decoration: BoxDecoration(
        color: kBookPaper,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 30, offset: const Offset(0, -10))],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Toplam Tutar", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kOliveGreen)),
                Text("${_toplamTutar.toStringAsFixed(2)} ₺", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kDarkGreen)),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                // 👇 DÜZELTİLMİŞ BUTON KISMI
                onPressed: _sepetUrunleri.isEmpty ? null : () => _satinAl(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kDarkGreen,
                  foregroundColor: kBookPaper,
                  elevation: 8,
                  shadowColor: kDarkGreen.withOpacity(0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  disabledBackgroundColor: Colors.grey.shade300, // Boşken gri olsun
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Ödemeyi Tamamla", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    SizedBox(width: 10),
                    Icon(Icons.arrow_forward_rounded, size: 22),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}