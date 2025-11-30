import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/urun_model.dart';
import 'models/card_model.dart';
import 'models/cart_service.dart';


const Color kDarkGreen = Color(0xFF283618);
const Color kOliveGreen = Color(0xFF606C38);
const Color kBookPaper = Color(0xFFFEFAE0);

class PaymentScreen extends StatefulWidget {
  final double toplamTutar;
  final List<Urun> sepetUrunleri;

  const PaymentScreen({
    super.key,
    required this.toplamTutar,
    required this.sepetUrunleri,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> with SingleTickerProviderStateMixin {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _kartKaydedilsinMi = false;
  
  late TabController _tabController;
  List<KayitliKart> _kayitliKartlar = [];
  bool _kartlarYukleniyor = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _kayitliKartlariGetir();
  }

  String getBaseUrl() {
    return "http://10.180.131.237:5126/api";
  }

  Future<void> _kayitliKartlariGetir() async {
    final prefs = await SharedPreferences.getInstance();
    final int? musteriId = prefs.getInt('musteriId');
    if (musteriId == null) return;

    try {
      final response = await http.get(Uri.parse("${getBaseUrl()}/Kartlar/Listele/$musteriId"));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        setState(() {
          _kayitliKartlar = body.map((e) => KayitliKart.fromJson(e)).toList();
          _kartlarYukleniyor = false;
        });
      }
    } catch (e) {
      print("Kart getirme hatası: $e");
      setState(() => _kartlarYukleniyor = false);
    }
  }

  // --- API: KART KAYDET ---
  Future<void> _kartKaydet() async {
    final prefs = await SharedPreferences.getInstance();
    final int? musteriId = prefs.getInt('musteriId');
    if (musteriId == null) return;

    // Tarihi parçala (MM/YY formatından)
    List<String> tarihParcalari = expiryDate.split('/');
    String ay = tarihParcalari[0];
    String yil = "20${tarihParcalari[1]}"; // 24 -> 2024 yapıyoruz

    KayitliKart yeniKart = KayitliKart(
      kartIsmi: "Kartım", // İstersen kullanıcıya girdirebilirsin
      kartSahibi: cardHolderName,
      kartNumarasi: cardNumber.replaceAll(' ', ''),
      sonKullanmaAy: ay,
      sonKullanmaYil: yil,
      musteriId: musteriId,
    );

    try {
      await http.post(
        Uri.parse("${getBaseUrl()}/Kartlar/Ekle"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(yeniKart.toJson()),
      );
      print("Kart başarıyla kaydedildi.");
    } catch (e) {
      print("Kart kaydetme hatası: $e");
    }
  }

  // --- ÖDEME VE SİPARİŞ ---
  Future<void> _odemeYapVeSiparisVer() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Eğer kullanıcı "Kartı Kaydet" dediyse önce onu kaydet
      if (_kartKaydedilsinMi) {
        await _kartKaydet();
      }

      // 2. Sipariş API İsteği Hazırla
      final prefs = await SharedPreferences.getInstance();
      final int? musteriId = prefs.getInt('musteriId');
      if (musteriId == null) throw Exception("Oturum hatası");

      List<Map<String, dynamic>> urunListesi = widget.sepetUrunleri.map((urun) {
        return {
          "urunId": urun.urunId,
          "musteriId": musteriId,
          "adet": 1,
          "fiyat": urun.urunSatisFiyati ?? 0,
        };
      }).toList();

      Map<String, dynamic> requestBody = {
        "sepetUrunleri": urunListesi,
        "kartSahibi": cardHolderName,
        "kartNumarasi": cardNumber.replaceAll(' ', ''),
        "sonKullanmaTarihi": expiryDate,
        "cvv": cvvCode
      };

      var url = Uri.parse("${getBaseUrl()}/Satislar/SiparisVer");
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        await SepetServisi.sepetiBosalt();
        if (mounted) _basariliDialogGoster();
      } else {
        throw Exception("Sipariş hatası: ${response.body}");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _basariliDialogGoster() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        content: const Text("Ödeme Başarılı! Siparişiniz alındı.", textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(true);
            },
            child: const Text("Tamam"),
          )
        ],
      ),
    );
  }

  // Kayıtlı Kart Seçildiğinde Formu Doldur
  void _kartSec(KayitliKart kart) {
    setState(() {
      cardNumber = kart.kartNumarasi;
      cardHolderName = kart.kartSahibi;
      // Backendde Yıl 2024 diye tutuluyor, UI MM/YY istiyor. Dönüştürüyoruz:
      expiryDate = "${kart.sonKullanmaAy}/${kart.sonKullanmaYil.substring(2)}";
      cvvCode = ""; // Güvenlik için CVV boş gelir
      _kartKaydedilsinMi = false; // Zaten kayıtlı
      
      // İlk sekmeye (Ödeme Formuna) geri dön
      _tabController.animateTo(0);
      
      // CVV'ye odaklansın diye bir uyarı verebiliriz
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kart bilgileri dolduruldu. Lütfen CVV giriniz.")));
    });
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      title: const Text("Ödeme Yap"),
      backgroundColor: kDarkGreen,
      
      // 1. BAŞLIK VE GERİ BUTONU RENGİ
      foregroundColor: kBookPaper, 
      
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: kBookPaper,
        
        labelColor: kBookPaper, 
        unselectedLabelColor: kBookPaper.withOpacity(0.5), 
        
        tabs: const [
          Tab(text: "KART BİLGİLERİ", icon: Icon(Icons.credit_card)),
          Tab(text: "KAYITLI KARTLARIM", icon: Icon(Icons.wallet)),
        ],
      ),
    ),
    body: TabBarView(
      controller: _tabController,
      children: [
        _buildOdemeFormu(),
        
        _buildKayitliKartlarListesi(),
      ],
    ),
  );
}

  Widget _buildOdemeFormu() {
    return SingleChildScrollView(
      child: Column(
        children: [
          CreditCardWidget(
            cardNumber: cardNumber,
            expiryDate: expiryDate,
            cardHolderName: cardHolderName,
            cvvCode: cvvCode,
            showBackView: isCvvFocused,
            obscureCardNumber: true,
            obscureCardCvv: true,
            isHolderNameVisible: true,
            cardBgColor: kDarkGreen,
            isSwipeGestureEnabled: true,
            onCreditCardWidgetChange: (CreditCardBrand creditCardBrand) {},
          ),
          CreditCardForm(
            formKey: formKey,
            obscureCvv: true,
            obscureNumber: true,
            cardNumber: cardNumber,
            cvvCode: cvvCode,
            isHolderNameVisible: true,
            isCardNumberVisible: true,
            isExpiryDateVisible: true,
            cardHolderName: cardHolderName,
            expiryDate: expiryDate,
            onCreditCardModelChange: (CreditCardModel? data) {
              setState(() {
                cardNumber = data!.cardNumber;
                expiryDate = data.expiryDate;
                cardHolderName = data.cardHolderName;
                cvvCode = data.cvvCode;
                isCvvFocused = data.isCvvFocused;
              });
            },
          ),
          
          // Kartı Kaydet Checkbox
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CheckboxListTile(
              title: const Text("Kartımı sonraki alışverişler için kaydet"),
              value: _kartKaydedilsinMi,
              activeColor: kOliveGreen,
              onChanged: (val) {
                setState(() {
                  _kartKaydedilsinMi = val ?? false;
                });
              },
            ),
          ),
          
          const SizedBox(height: 10),
          
          // Toplam Tutar ve Buton
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Ödenecek Tutar:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("${widget.toplamTutar.toStringAsFixed(2)} ₺", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kOliveGreen)),
                  ],
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: kOliveGreen),
                    onPressed: _isLoading ? null : _odemeYapVeSiparisVer,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("ÖDEMEYİ TAMAMLA", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKayitliKartlarListesi() {
    if (_kartlarYukleniyor) {
      return const Center(child: CircularProgressIndicator(color: kOliveGreen));
    }
    if (_kayitliKartlar.isEmpty) {
      return const Center(child: Text("Kayıtlı kartınız bulunmuyor."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _kayitliKartlar.length,
      itemBuilder: (context, index) {
        final kart = _kayitliKartlar[index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          color: kDarkGreen,
          child: InkWell(
            onTap: () => _kartSec(kart),
            borderRadius: BorderRadius.circular(15),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(kart.kartIsmi, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                      const Icon(Icons.credit_card, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "**** **** **** ${kart.kartNumarasi.substring(kart.kartNumarasi.length - 4)}",
                    style: const TextStyle(color: Colors.white, fontSize: 22, letterSpacing: 2, fontFamily: 'Courier'),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(kart.kartSahibi.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text("${kart.sonKullanmaAy}/${kart.sonKullanmaYil.substring(2)}", style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 30),
                  const Center(
                    child: Text("SEÇ VE KULLAN", style: TextStyle(color: kBookPaper, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}