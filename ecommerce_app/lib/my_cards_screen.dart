import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart'; 
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/card_model.dart';

const Color kBookPaper = Color(0xFFFEFAE0);
const Color kDarkGreen = Color(0xFF283618);
const Color kOliveGreen = Color(0xFF606C38);
const Color kDiscountRed = Color(0xFFBC4749);

class MyCardsScreen extends StatefulWidget {
  const MyCardsScreen({super.key});

  @override
  State<MyCardsScreen> createState() => _MyCardsScreenState();
}

class _MyCardsScreenState extends State<MyCardsScreen> {
  List<KayitliKart> _kartlar = [];
  bool _isLoading = true;

  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  String cardName = ''; 
  bool isCvvFocused = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _kartlariGetir();
  }

  String getBaseUrl() {
    return "http://10.180.131.237:5126/api"; 
  }

  Future<void> _kartlariGetir() async {
    final prefs = await SharedPreferences.getInstance();
    final int? musteriId = prefs.getInt('musteriId');

    if (musteriId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await http.get(Uri.parse("${getBaseUrl()}/Kartlar/Listele/$musteriId"));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        setState(() {
          _kartlar = body.map((item) => KayitliKart.fromJson(item)).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Hata: $e");
      setState(() => _isLoading = false);
    }
  }

  // --- API: KART SİL ---
  Future<void> _kartSil(int kartId) async {
    bool? eminMi = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Kartı Sil"),
        content: const Text("Bu kartı silmek istediğinize emin misiniz?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("İptal", style: TextStyle(color: Colors.grey))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Sil", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (eminMi != true) return;

    try {
      final response = await http.delete(Uri.parse("${getBaseUrl()}/Kartlar/Sil/$kartId"));

      if (response.statusCode == 200) {
        _kartlariGetir(); // Listeyi yenile
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kart silindi."), backgroundColor: kDarkGreen));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e"), backgroundColor: Colors.red));
    }
  }

  // --- API: KART EKLE (DÜZELTİLMİŞ) ---
  Future<void> _kartEkle() async {
    // 1. Form Validasyonu (Boş mu?)
    if (cardNumber.isEmpty || expiryDate.isEmpty || cardHolderName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen tüm alanları doldurun.")));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final int? musteriId = prefs.getInt('musteriId');
    
    if (musteriId == null) {
      print("HATA: Müşteri ID yok.");
      return;
    }

    // 2. Tarih Formatı Kontrolü (Hata buradaydı!)
    // Gelen veri "12/25" formatında olmalı.
    if (!expiryDate.contains('/') || expiryDate.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Geçersiz tarih formatı.")));
      return;
    }

    List<String> tarihParcalari = expiryDate.split('/');
    String ay = tarihParcalari[0];
    String yil = "20${tarihParcalari[1]}"; // 25 -> 2025 yapıyoruz

    // Kart İsmi boşsa varsayılan ata
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
      print("Gönderilen JSON: ${jsonEncode(yeniKart.toJson())}");

      final response = await http.post(
        Uri.parse("${getBaseUrl()}/Kartlar/Ekle"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(yeniKart.toJson()),
      );

      print("API Cevabı: ${response.statusCode} - ${response.body}"); 
      if (response.statusCode == 200) {
        Navigator.pop(context); 
        _sifirlaForm(); 
        _kartlariGetir(); 
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kart başarıyla eklendi."), backgroundColor: kDarkGreen));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: ${response.body}"), backgroundColor: Colors.red));
      }
    } catch (e) {
      print("Ekleme hatası: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Bağlantı hatası: $e")));
    }
  }

  void _sifirlaForm() {
    setState(() {
      cardNumber = '';
      expiryDate = '';
      cardHolderName = '';
      cvvCode = '';
      cardName = '';
      isCvvFocused = false;
    });
  }

  void _yeniKartEklePenceresiAc() {
    _sifirlaForm();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 10, right: 10, top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Yeni Kart Ekle", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kDarkGreen)),
                    
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
                      isSwipeGestureEnabled: false,
                      onCreditCardWidgetChange: (CreditCardBrand brand) {},
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
                        setModalState(() {
                          cardNumber = data!.cardNumber;
                          expiryDate = data.expiryDate;
                          cardHolderName = data.cardHolderName;
                          cvvCode = data.cvvCode;
                          isCvvFocused = data.isCvvFocused;
                        });
                        
                        setState(() {
                           cardNumber = data!.cardNumber;
                           expiryDate = data.expiryDate;
                           cardHolderName = data.cardHolderName;
                           cvvCode = data.cvvCode;
                        });
                      },
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Kart İsmi (Örn: Maaş Kartım)",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.label, color: kOliveGreen),
                        ),
                        onChanged: (val) {
                          setState(() {
                            cardName = val;
                          });
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            _kartEkle();
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: kDarkGreen, foregroundColor: Colors.white),
                          child: const Text("KAYDET", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBookPaper,
      appBar: AppBar(
        title: const Text("Kayıtlı Kartlarım"),
        backgroundColor: kDarkGreen,
        foregroundColor: kBookPaper,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kDarkGreen))
          : _kartlar.isEmpty
              ? _buildBosDurum()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _kartlar.length,
                  itemBuilder: (context, index) {
                    final kart = _kartlar[index];
                    
                    String maskeliNo = "**** **** **** ";
                    if (kart.kartNumarasi.length >= 4) {
                      maskeliNo += kart.kartNumarasi.substring(kart.kartNumarasi.length - 4);
                    } else {
                      maskeliNo += "####";
                    }

                    return Column(
                      children: [
                        CreditCardWidget(
                          cardNumber: kart.kartNumarasi,
                          expiryDate: "${kart.sonKullanmaAy}/${kart.sonKullanmaYil.substring(2)}",
                          cardHolderName: kart.kartSahibi,
                          cvvCode: "xxx",
                          showBackView: false,
                          isHolderNameVisible: true,
                          cardBgColor: kDarkGreen,
                          isSwipeGestureEnabled: false,
                          onCreditCardWidgetChange: (brand) {},
                        ),
                        
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 3))],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Kart İsmi:", style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  Text(kart.kartIsmi, style: const TextStyle(fontWeight: FontWeight.bold, color: kDarkGreen)),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: kDiscountRed),
                                onPressed: () => _kartSil(kart.kartId ?? 0),
                                tooltip: "Kartı Sil",
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _yeniKartEklePenceresiAc,
        backgroundColor: kDarkGreen,
        foregroundColor: kBookPaper,
        icon: const Icon(Icons.add_card),
        label: const Text("Yeni Kart"),
      ),
    );
  }

  Widget _buildBosDurum() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.credit_card_off_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          const Text("Henüz kayıtlı kartınız yok.", style: TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }
}