import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;
import 'home_screen.dart';

const Color kDarkGreen = Color(0xFF283618);
const Color kBookPaper = Color(0xFFFEFAE0);

class EmailVerifyScreen extends StatefulWidget {
  final int musteriId;

  const EmailVerifyScreen({super.key, required this.musteriId});

  @override
  State<EmailVerifyScreen> createState() => _EmailVerifyScreenState();
}

class _EmailVerifyScreenState extends State<EmailVerifyScreen> {
  final _kodController = TextEditingController();
  bool _isLoading = false;

  String getBaseUrl() {
    return "http://10.180.131.237:5126/api"; 
  }

  Future<void> _dogrula() async {
    if (_kodController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("${getBaseUrl()}/Musteris/Dogrula"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "MusteriId": widget.musteriId,
          "Kod": _kodController.text
        }),
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('musteriId', widget.musteriId);
        await prefs.setBool('isLoggedIn', true);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Hoş geldiniz!"), backgroundColor: Colors.green, duration: Duration(seconds: 1)),
          );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()), 
            (route) => false, 
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: ${response.body}"), backgroundColor: Colors.red));
        }
      }
    } catch (e) {
      print(e);
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bağlantı hatası oluştu."), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("E-Posta Doğrulama"), backgroundColor: Colors.white, elevation: 0, foregroundColor: Colors.black),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mark_email_read_outlined, size: 80, color: kDarkGreen),
            const SizedBox(height: 20),
            const Text("Hesabınızı Doğrulayın", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Lütfen e-posta adresinize gönderilen 6 haneli kodu giriniz.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            
            TextField(
              controller: _kodController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 5, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                counterText: "",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            
            const SizedBox(height: 30),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _dogrula,
                style: ElevatedButton.styleFrom(backgroundColor: kDarkGreen, foregroundColor: Colors.white),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("DOĞRULA", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}