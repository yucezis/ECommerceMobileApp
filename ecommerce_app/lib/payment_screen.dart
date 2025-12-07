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
  String cardName = '';
  
  bool isCvvFocused = false;
  
  // Formun durumunu kontrol etmek için
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  // Kayıtlı kart mı kullanılıyor kontrolü
  bool _kayitliKartKullaniliyor = false;

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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String getBaseUrl() {
    return "http://10.180.131.237:5126/api";
  }

  String _kartNoFormatla(String hamNo) {
    String temiz = hamNo.replaceAll(' ', '');
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < temiz.length; i++) {
      buffer.write(temiz[i]);
      var index = i + 1;
      if (index % 4 == 0 && index != temiz.length) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
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
      print("Kart hata: $e");
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
    } catch (e) {
      print("Kart kaydetme hatası: $e");
    }
  }

  Future<void> _odemeYapVeSiparisVer() async {
    // --- VALIDASYON MANTIĞI GÜNCELLENDİ ---
    
    bool valid = false;

    if (_kayitliKartKullaniliyor) {
      // Eğer kayıtlı kart seçtiysek, Form widget'ının ne dediğine bakma.
      // Kendi değişkenlerimiz (cardNumber, cvv) dolu mu ona bak.
      if (cardNumber.isNotEmpty && expiryDate.isNotEmpty && cvvCode.length >= 3) {
        valid = true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen CVV kodunu giriniz.")));
        return;
      }
    } else {
      // Eğer elle yeni kart giriliyorsa, Form validasyonunu kullan.
      if (formKey.currentState!.validate()) {
        valid = true;
      }
    }

    if (!valid) return;

    FocusScope.of(context).unfocus();
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SmsVerificationScreen()),
    );

    if (result == true) {
      await _gerceklesecekOdemeIslemi();
    }
  }
  
  Future<void> _gerceklesecekOdemeIslemi() async {
    setState(() => _isLoading = true);
    try {
      // Sadece YENİ kart giriliyorsa ve kaydetme seçildiyse kaydet
      if (!_kayitliKartKullaniliyor && _kartKaydedilsinMi) {
        await _kartKaydet();
      }

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
        "cvv": cvvCode,
        "teslimatAdresiId": widget.secilenAdresId
      };

      var response = await http.post(
        Uri.parse("${getBaseUrl()}/Satislar/SiparisVer"),
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
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e"), backgroundColor: Colors.red));
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
      // 1. Kart numarasını formun seveceği şekilde (boşluklu) formatla
      cardNumber = _kartNoFormatla(kart.kartNumarasi);
      
      cardHolderName = kart.kartSahibi;
      expiryDate = "${kart.sonKullanmaAy}/${kart.sonKullanmaYil.substring(2)}";
      cvvCode = ""; 
      
      // 2. Formu sıfırla ki yeni değerleri alsın
      formKey = GlobalKey<FormState>();
      
      // 3. Durum işaretçisini güncelle
      _kayitliKartKullaniliyor = true;
      _kartKaydedilsinMi = false; 
      
      _tabController.animateTo(0);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen CVV kodunu giriniz.")));
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
          onTap: (index) {
             // Eğer kullanıcı tab değiştirirse ve 'Kart Bilgileri'ne elle geçerse,
             // manuel giriş moduna geçmesini sağlayalım.
             if (index == 0) {
               setState(() {
                 _kayitliKartKullaniliyor = false;
               });
             }
          },
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
                // Burada kritik bir kontrol yapıyoruz.
                // Eğer kayıtlı bir kart seçiliyse ve kullanıcı sadece CVV giriyorsa,
                // Modelden gelen boş 'cardNumber' verisinin bizim dolu 'cardNumber'ımızı ezmesini engelliyoruz.
                if (_kayitliKartKullaniliyor && (data!.cardNumber.isEmpty || data.cardNumber.length < 5)) {
                   // Sadece CVV ve Focus'u güncelle, diğerlerini koru
                   cvvCode = data.cvvCode;
                   isCvvFocused = data.isCvvFocused;
                } else {
                   // Manuel girişte veya tam güncellemede her şeyi al
                   cardNumber = data!.cardNumber;
                   expiryDate = data.expiryDate;
                   cardHolderName = data.cardHolderName;
                   cvvCode = data.cvvCode;
                   isCvvFocused = data.isCvvFocused;
                }
              });
            },
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Checkbox sadece kayıtlı kart kullanılmıyorsa görünsün
                if (!_kayitliKartKullaniliyor)
                  CheckboxListTile(
                    title: const Text("Kartımı sonraki alışverişler için kaydet"),
                    value: _kartKaydedilsinMi,
                    activeColor: kOliveGreen,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (val) {
                      setState(() {
                        _kartKaydedilsinMi = val ?? false;
                      });
                    },
                  ),
                
                if (_kartKaydedilsinMi && !_kayitliKartKullaniliyor)
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
                      Text(kart.kartIsmi, style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600)),
                      const Icon(Icons.credit_card, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(maskeliNumara, style: const TextStyle(color: Colors.white, fontSize: 22, letterSpacing: 2, fontFamily: 'Courier')),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(kart.kartSahibi.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text("${kart.sonKullanmaAy}/${kart.sonKullanmaYil.length >= 2 ? kart.sonKullanmaYil.substring(2) : kart.sonKullanmaYil}", style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 30),
                  const Center(child: Text("SEÇ VE KULLAN", style: TextStyle(color: kBookPaper, fontWeight: FontWeight.bold)))
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}