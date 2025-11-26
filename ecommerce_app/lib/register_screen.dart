import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _adController = TextEditingController();
  final _soyadController = TextEditingController();
  final _mailController = TextEditingController();
  final _sifreController = TextEditingController();
  final _telController = TextEditingController();
  final _sehirController = TextEditingController();
  bool _isLoading = false;

  String getBaseUrl() {
    String ipAdresim = "10.180.131.237"; 
    String port = "5126";
    return "http://$ipAdresim:$port/api";
  }

  Future<void> _kayitOl() async {
    setState(() => _isLoading = true);

    try {
      final url = Uri.parse("${getBaseUrl()}/Musteris"); 

      final body = jsonEncode({
        "MusteriAdi": _adController.text,
        "MusteriSoyadi": _soyadController.text,
        "MusteriMail": _mailController.text,
        "MusteriSifre": _sifreController.text,
        "MusteriTelNo": _telController.text,
        "MusteriSehir": _sehirController.text,
        "Durum": true
      });

      final response = await http.post(
        url, 
        headers: {"Content-Type": "application/json"}, 
        body: body
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kayıt Başarılı! Giriş yapabilirsiniz."), backgroundColor: Colors.green));
          Navigator.pop(context); // Giriş ekranına dön
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: ${response.body}"), backgroundColor: Colors.red));
        }
      }
    } catch (e) {
      
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kayıt Ol"), backgroundColor: const Color(0xFF6200EE), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInput("Ad", _adController, Icons.person),
            const SizedBox(height: 15),
            _buildInput("Soyad", _soyadController, Icons.person_outline),
            const SizedBox(height: 15),
            _buildInput("Mail", _mailController, Icons.email),
            const SizedBox(height: 15),
            _buildInput("Şifre", _sifreController, Icons.lock, obscure: true),
            const SizedBox(height: 15),
            _buildInput("Telefon", _telController, Icons.phone),
            const SizedBox(height: 15),
            _buildInput("Şehir", _sehirController, Icons.location_city),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _kayitOl,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6200EE), foregroundColor: Colors.white),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Kayıt Ol", style: TextStyle(fontSize: 18)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, IconData icon, {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
    );
  }
}