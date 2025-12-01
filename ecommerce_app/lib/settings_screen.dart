import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const Color kBookPaper = Color(0xFFFEFAE0);
const Color kDarkGreen = Color(0xFF283618);
const Color kOliveGreen = Color(0xFF606C38);

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = true;
  final _formKey = GlobalKey<FormState>();

  // Form Kontrolcüleri
  final _adController = TextEditingController();
  final _soyadController = TextEditingController();
  final _telController = TextEditingController();
  final _mailController = TextEditingController();
  final _sifreController = TextEditingController();

  int? _musteriId;

  @override
  void initState() {
    super.initState();
    _bilgileriGetir();
  }

  String getBaseUrl() {
    return "http://10.180.131.237:5126/api"; 
  }

  Future<void> _bilgileriGetir() async {
    final prefs = await SharedPreferences.getInstance();
    _musteriId = prefs.getInt('musteriId');

    if (_musteriId == null) return;

    try {
      final response = await http.get(Uri.parse("${getBaseUrl()}/Musteris/$_musteriId"));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        
        setState(() {
          _adController.text = data['musteriAdi'] ?? "";
          _soyadController.text = data['musteriSoyadi'] ?? "";
          _telController.text = data['musteriTelNo'] ?? "";
          _mailController.text = data['musteriMail'] ?? "";
          _sifreController.text = data['musteriSifre'] ?? ""; 
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Hata: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _guncelleBaslat() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("${getBaseUrl()}/Musteris/KodGonder/$_musteriId"),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        if (mounted) _kodPenceresiAc();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hata: ${response.body}"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Bağlantı hatası: $e")));
    }
  }

  void _kodPenceresiAc() {
    TextEditingController kodController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Güvenlik Doğrulaması"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Lütfen mail adresinize gönderilen doğrulama kodunu giriniz."),
            const SizedBox(height: 15),
            TextField(
              controller: kodController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 6,
              decoration: const InputDecoration(
                hintText: "KOD",
                border: OutlineInputBorder(),
                counterText: ""
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("İptal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx); 
              _guncelleTamamla(kodController.text); 
            },
            style: ElevatedButton.styleFrom(backgroundColor: kDarkGreen, foregroundColor: kBookPaper),
            child: const Text("ONAYLA"),
          )
        ],
      ),
    );
  }

  Future<void> _guncelleTamamla(String girilenKod) async {
    if (girilenKod.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kod boş olamaz.")));
      return;
    }

    setState(() => _isLoading = true);

    Map<String, dynamic> paket = {
      "MusteriVerisi": {
        "MusteriId": _musteriId,
        "MusteriAdi": _adController.text,
        "MusteriSoyadi": _soyadController.text,
        "MusteriTelNo": _telController.text,
        "MusteriMail": _mailController.text, 
        "MusteriSifre": _sifreController.text,
        "Durum": true
      },
      "Kod": girilenKod
    };

    try {
      final response = await http.put(
        Uri.parse("${getBaseUrl()}/Musteris/GuncelleOnayli"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(paket),
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('adSoyad', "${_adController.text} ${_soyadController.text}");

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Bilgiler başarıyla güncellendi!"), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Hata: ${response.body}"), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBookPaper,
      appBar: AppBar(
        title: const Text("Profil Ayarları"),
        backgroundColor: kDarkGreen,
        foregroundColor: kBookPaper,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kDarkGreen))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: kOliveGreen,
                      // Resim Linki
                      backgroundImage: const NetworkImage("https://r.resimlink.com/YP4EnpRIiaJ.jpeg"),
                      child: const Icon(Icons.person, size: 60, color: Colors.transparent), 
                    ),
                    const SizedBox(height: 30),
                    
                    _buildTextField("Ad", _adController, Icons.person),
                    const SizedBox(height: 15),
                    _buildTextField("Soyad", _soyadController, Icons.person_outline),
                    const SizedBox(height: 15),
                    _buildTextField("Telefon", _telController, Icons.phone, inputType: TextInputType.phone),
                    const SizedBox(height: 15),
                    
                    _buildTextField("E-Posta", _mailController, Icons.email, inputType: TextInputType.emailAddress, isReadOnly: true),
                    
                    const SizedBox(height: 15),
                    _buildTextField("Şifre", _sifreController, Icons.lock, isPassword: true),
                    
                    const SizedBox(height: 40),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _guncelleBaslat, 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kDarkGreen,
                          foregroundColor: kBookPaper,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 5,
                        ),
                        child: const Text("BİLGİLERİ GÜNCELLE", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool isPassword = false, TextInputType inputType = TextInputType.text, bool isReadOnly = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: inputType,
      readOnly: isReadOnly, 
      validator: (value) => value!.isEmpty ? "$label boş bırakılamaz" : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: isReadOnly ? Colors.grey : kOliveGreen), 
        filled: true,
        fillColor: isReadOnly ? Colors.grey[200] : Colors.white, 
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kDarkGreen, width: 2)),
      ),
    );
  }
}