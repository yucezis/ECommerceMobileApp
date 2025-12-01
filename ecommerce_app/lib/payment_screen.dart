import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/urun_model.dart';
import 'models/card_model.dart';
import 'models/cart_service.dart';
import 'sms_verification_screen.dart';

const Color kDarkGreen = Color(0xFF283618);
const Color kOliveGreen = Color(0xFF606C38);
const Color kBookPaper = Color(0xFFFEFAE0);

class PaymentScreen extends StatefulWidget {
  final double toplamTutar;
  final List<Urun> sepetUrunleri;
  final int secilenAdresId;

  const PaymentScreen({
    super.key,
    required this.toplamTutar,
    required this.sepetUrunleri,
    required this.secilenAdresId,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> with SingleTickerProviderStateMixin {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  
  // 1. Kart İsmi Değişkeni
  String cardName = ''; 
  
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

  Future<void> _kartKaydet() async {
    final prefs = await SharedPreferences.getInstance();
    final int? musteriId = prefs.getInt('musteriId');
    if (musteriId == null) return;

    List<String> tarihParcalari = expiryDate.split('/');
    if (tarihParcalari.length < 2) return;
    
    String ay = tarihParcalari[0];
    String yil = "20${tarihParcalari[1]}"; 

    String kaydedilecekIsim = cardName.trim().isEmpty ? "Kartım" : cardName.trim();

    KayitliKart yeniKart = KayitliKart(
      kartIsmi: kaydedilecekIsim, 
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
      print("Kart başarıyla kaydedildi: $kaydedilecekIsim");
    } catch (e) {
      print("Kart kaydetme hatası: $e");
    }
  }

  Future<void> _odemeYapVeSiparisVer() async {
    // 1. Form kontrolü
    if (!formKey.currentState!.validate()) {
      return;
    }

    // 2. Klavyeyi garanti kapat (Payment ekranındaki klavye)
    FocusScope.of(context).unfocus();

    // 3. SMS Ekranına Git ve SONUCU BEKLE
    // result değişkeni, SMS ekranından dönen 'true' değeri olacak
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SmsVerificationScreen(),
      ),
    );

    // 4. Eğer sonuç 'true' ise (Doğrulama başarılıysa) ödeme işlemini yap
    if (result == true) {
      // SMS ekranı kapandı, şimdi API isteğini atıyoruz
      await _gerceklesecekOdemeIslemi();
    } else {
      // Kullanıcı SMS ekranında geri tuşuna bastı veya iptal etti
      print("SMS doğrulaması yapılmadı.");
    }
  }

  Future<void> _gerceklesecekOdemeIslemi() async {
    setState(() => _isLoading = true);

    try {
      if (_kartKaydedilsinMi) {
        await _kartKaydet();
      }

      final prefs = await SharedPreferences.getInstance();
      final int? musteriId = prefs.getInt('musteriId');
      if (musteriId == null) throw Exception("Oturum hatası");

      // 2. Ürün Listesini Hazırla
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
        "cvv": cvvCode,
        "teslimatAdresiId": widget.secilenAdresId
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

  void _kartSec(KayitliKart kart) {
    setState(() {
      cardNumber = kart.kartNumarasi;
      cardHolderName = kart.kartSahibi;
      expiryDate = "${kart.sonKullanmaAy}/${kart.sonKullanmaYil.substring(2)}";
      cvvCode = ""; 
      _kartKaydedilsinMi = false; 
      _tabController.animateTo(0);
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
            child: Column(
              children: [
                CheckboxListTile(
                  title: const Text("Kartımı sonraki alışverişler için kaydet"),
                  value: _kartKaydedilsinMi,
                  activeColor: kOliveGreen,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading, // Checkbox solda olsun
                  onChanged: (val) {
                    setState(() {
                      _kartKaydedilsinMi = val ?? false;
                    });
                  },
                ),
                
                // 3. YENİ EKLENEN KISIM: KART İSMİ ALANI
                // Sadece checkbox işaretliyse görünsün
                if (_kartKaydedilsinMi)
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: "Kart İsmi (Örn: Maaş Kartım)",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        prefixIcon: const Icon(Icons.label, color: kOliveGreen),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      onChanged: (val) {
                        setState(() {
                          cardName = val;
                        });
                      },
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 10),
          
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

        // GÜVENLİK KONTROLÜ: Kart numarası 4 haneden kısaysa hata vermesin
        String maskeliNumara = "**** **** **** ";
        if (kart.kartNumarasi.length >= 4) {
          maskeliNumara += kart.kartNumarasi.substring(kart.kartNumarasi.length - 4);
        } else {
          maskeliNumara += "####";
        }

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
                      // Eğer modelde kartIsmi yoksa hata verir, o yüzden modeli güncellemelisin
                      Text(kart.kartIsmi, style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600)),
                      const Icon(Icons.credit_card, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    maskeliNumara, // Güvenli numara
                    style: const TextStyle(color: Colors.white, fontSize: 22, letterSpacing: 2, fontFamily: 'Courier'),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(kart.kartSahibi.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      // Yılın son 2 hanesini alırken de güvenlik kontrolü
                      Text("${kart.sonKullanmaAy}/${kart.sonKullanmaYil.length >= 2 ? kart.sonKullanmaYil.substring(2) : kart.sonKullanmaYil}", 
                           style: const TextStyle(color: Colors.white)),
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