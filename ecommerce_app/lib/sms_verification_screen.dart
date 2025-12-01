import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

const Color kDarkGreen = Color(0xFF283618);
const Color kOliveGreen = Color(0xFF606C38);

class SmsVerificationScreen extends StatefulWidget {
  const SmsVerificationScreen({super.key});

  @override
  State<SmsVerificationScreen> createState() => _SmsVerificationScreenState();
}

class _SmsVerificationScreenState extends State<SmsVerificationScreen> {
  final TextEditingController _codeController = TextEditingController();
  String _dogruKod = "";
  int _saniye = 180;
  Timer? _timer;
  bool _isLoading = false;
  
  // Bildirim görünürlüğü için değişken
  bool _isNotificationVisible = false;

  @override
  void initState() {
    super.initState();
    _kodUret();
    _sayaciBaslat();

    // Sayfa açıldıktan 1.5 saniye sonra bildirimi yukarıdan indir
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isNotificationVisible = true;
        });

        // 5 saniye ekranda kalsın sonra geri yukarı çıksın
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _isNotificationVisible = false;
            });
          }
        });
      }
    });
  }

  void _kodUret() {
    int code = Random().nextInt(9000) + 1000;
    setState(() {
      _dogruKod = code.toString();
    });
  }

  void _sayaciBaslat() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_saniye > 0) {
        if (mounted) setState(() => _saniye--);
      } else {
        _timer?.cancel();
      }
    });
  }

  void _dogrula() async {
    FocusScope.of(context).unfocus(); // Klavyeyi kapat

    if (_codeController.text == _dogruKod) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        Navigator.pop(context, true);
      }
    } else {
      // Hata durumunda alttan kırmızı uyarı (Hata için alt taraf uygundur)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Hatalı kod!"), backgroundColor: Colors.red),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String sureFormatli = "${(_saniye / 60).floor()}:${(_saniye % 60).toString().padLeft(2, '0')}";
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    // Bildirimin ineceği güvenli alan (Status bar altı)
    final topPadding = MediaQuery.of(context).padding.top; 

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false, // Donmayı engelleyen ayar
      appBar: AppBar(
        title: const Text("Güvenli Ödeme (3D Secure)"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      // STACK: Üst üste katmanlar oluşturmamızı sağlar
      body: Stack(
        children: [
          // KATMAN 1: ANA İÇERİK
          Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_outline, size: 60, color: kDarkGreen),
                    const SizedBox(height: 20),
                    const Text(
                      "Doğrulama Kodu",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Bankanız tarafından cep telefonunuza gönderilen 4 haneli kodu giriniz.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24, letterSpacing: 5, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        counterText: "",
                        hintText: "----",
                        hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5), letterSpacing: 5),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: kOliveGreen, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      sureFormatli,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _dogrula,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kDarkGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("ONAYLA", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                         _kodUret();
                         // Manuel istekte tekrar bildirim göster
                         setState(() => _isNotificationVisible = true);
                         Future.delayed(const Duration(seconds: 4), () {
                           if(mounted) setState(() => _isNotificationVisible = false);
                         });
                      },
                      child: const Text("Kodu Tekrar Gönder", style: TextStyle(color: Colors.grey)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // KATMAN 2: ÜSTTEN GELEN BİLDİRİM (Fake Notification)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500), // Kayma hızı
            curve: Curves.easeOutBack, // Hafif yaylanma efekti
            top: _isNotificationVisible ? topPadding + 10 : -100, // Görünürse aşağı in, değilse yukarı saklan
            left: 10,
            right: 10,
            child: Material(
              elevation: 10,
              borderRadius: BorderRadius.circular(12),
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900], // Koyu tema bildirim rengi
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))
                  ]
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                      child: const Icon(Icons.message, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "BANKA",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Onay kodunuz: $_dogruKod",
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}