import 'dart:async';
import 'dart:math'; 
import 'package:flutter/material.dart';

const Color kDarkGreen = Color(0xFF283618);
const Color kOliveGreen = Color(0xFF606C38);
const Color kBookPaper = Color(0xFFFEFAE0);

class SmsVerificationScreen extends StatefulWidget {
  final Function onVerified;

  const SmsVerificationScreen({super.key, required this.onVerified});

  @override
  State<SmsVerificationScreen> createState() => _SmsVerificationScreenState();
}

class _SmsVerificationScreenState extends State<SmsVerificationScreen> {
  final TextEditingController _codeController = TextEditingController();
  
  String _dogruKod = "";
  
  int _saniye = 180;
  Timer? _timer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _kodUret(); 
    _sayaciBaslat();
    
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("BANKA: Onay kodunuz: $_dogruKod"), 
            backgroundColor: Colors.blue[800],
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height - 150, 
              left: 10, 
              right: 10
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    });
  }

  void _kodUret() {
    int code = Random().nextInt(9000) + 1000; 
    setState(() {
      _dogruKod = code.toString();
    });
    print("Üretilen Kod: $_dogruKod");
  }

  void _sayaciBaslat() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_saniye > 0) {
        setState(() {
          _saniye--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  void _dogrula() async {
    FocusScope.of(context).unfocus(); 

    if (_codeController.text == _dogruKod) {
      setState(() => _isLoading = true);
      
      await Future.delayed(const Duration(seconds: 1)); 
      
      if (mounted) {
        Navigator.pop(context); // Sayfayı kapat
        widget.onVerified(); // Ödemeyi tetikle
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hatalı kod! Lütfen tekrar deneyin."), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String sureFormatli = "${(_saniye / 60).floor()}:${(_saniye % 60).toString().padLeft(2, '0')}";

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Güvenli Ödeme (3D Secure)"),
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20), 
                const Icon(Icons.lock_outline, size: 60, color: kDarkGreen),
                const SizedBox(height: 20),
                const Text(
                  "Doğrulama Kodu",
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
                  style: const TextStyle(fontSize: 24, letterSpacing: 10, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    counterText: "",
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
                
                TextButton(
                  onPressed: () {
                  },
                  child: const Text("Kodu Tekrar Gönder", style: TextStyle(color: Colors.grey)),
                ),
                
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }
}