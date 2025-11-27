import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// --- RENK PALETİ ---
const Color kBookPaper = Color(0xFFFEFAE0); // Arka plan (Krem)
const Color kDarkGreen = Color(0xFF283618); // Ana Buton & Başlık
const Color kOliveGreen = Color(0xFF606C38); // İkonlar & Vurgular
const Color kDarkCoffee = Color(0xFF211508); // Metinler

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _adController = TextEditingController();
  final _soyadController = TextEditingController();
  final _mailController = TextEditingController();
  final _sifreController = TextEditingController();
  final _sifreTekrarController = TextEditingController();
  final _telController = TextEditingController();

  bool _sifreGizli = true;
  bool _sifreTekrarGizli = true;
  bool _isLoading = false;

  String getBaseUrl() {
    String ipAdresim = "10.180.131.237";
    String port = "5126";
    return "http://$ipAdresim:$port/api";
  }

  Future<void> _kayitOl() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse("${getBaseUrl()}/Musteris");
      final body = jsonEncode({
        "MusteriAdi": _adController.text,
        "MusteriSoyadi": _soyadController.text,
        "MusteriMail": _mailController.text,
        "MusteriSifre": _sifreController.text,
        "MusteriTelNo": _telController.text,
        "MusteriSehir": "Belirtilmedi",
        "Durum": true
      });

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Kayıt Başarılı! Kitap dünyasına hoş geldiniz."),
            backgroundColor: kOliveGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Hata: ${response.body}"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Bağlantı Hatası: $e"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBookPaper, // Krem rengi arka plan
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Şeffaf AppBar
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: kDarkGreen),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- BAŞLIK ALANI ---
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.menu_book_rounded, size: 60, color: kDarkGreen),
                      const SizedBox(height: 10),
                      Text(
                        "Yeni Bir Sayfa Aç",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: kDarkGreen,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Kitap dünyasına katılmak için formu doldur.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: kOliveGreen),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 35),

                // --- FORM ALANI ---
                Row(
                  children: [
                    Expanded(
                      child: _buildModernField(
                        controller: _adController,
                        label: "Ad",
                        icon: Icons.person,
                        validator: (val) => val!.isEmpty ? "Gerekli" : null,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildModernField(
                        controller: _soyadController,
                        label: "Soyad",
                        icon: Icons.person_outline,
                        validator: (val) => val!.isEmpty ? "Gerekli" : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                _buildModernField(
                  controller: _mailController,
                  label: "E-Posta Adresi",
                  icon: Icons.alternate_email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.isEmpty) return "Mail adresi gerekli";
                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(val)) return "Geçerli bir mail giriniz";
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                _buildModernField(
                  controller: _telController,
                  label: "Telefon Numarası",
                  icon: Icons.phone_android_rounded,
                  keyboardType: TextInputType.phone,
                  validator: (val) {
                    if (val == null || val.isEmpty) return "Telefon gerekli";
                    if (val.length < 10) return "En az 10 hane";
                    if (!RegExp(r'^[0-9]+$').hasMatch(val)) return "Sadece rakam";
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                _buildModernField(
                  controller: _sifreController,
                  label: "Şifre",
                  icon: Icons.lock_outline,
                  isPassword: true,
                  isObscure: _sifreGizli,
                  onVisibilityToggle: () => setState(() => _sifreGizli = !_sifreGizli),
                  validator: (val) {
                    if (val == null || val.length < 6) return "En az 6 karakter";
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                _buildModernField(
                  controller: _sifreTekrarController,
                  label: "Şifre Tekrar",
                  icon: Icons.lock_reset,
                  isPassword: true,
                  isObscure: _sifreTekrarGizli,
                  onVisibilityToggle: () => setState(() => _sifreTekrarGizli = !_sifreTekrarGizli),
                  validator: (val) {
                    if (val != _sifreController.text) return "Şifreler uyuşmuyor";
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                // --- KAYIT OL BUTONU ---
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _kayitOl,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kDarkGreen,
                      foregroundColor: kBookPaper,
                      elevation: 5,
                      shadowColor: kDarkGreen.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: kBookPaper)
                        : const Text(
                            "Hemen Kayıt Ol",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Modern Tasarımlı Input Helper
  Widget _buildModernField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isObscure = false,
    VoidCallback? onVisibilityToggle,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: kDarkCoffee,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6), // Hafif şeffaf beyaz dolgu
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: kDarkGreen.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            obscureText: isObscure,
            keyboardType: keyboardType,
            validator: validator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: const TextStyle(color: kDarkGreen, fontWeight: FontWeight.w500),
            cursorColor: kOliveGreen,
            decoration: InputDecoration(
              hintText: isPassword ? "******" : label,
              hintStyle: TextStyle(color: kOliveGreen.withOpacity(0.5)),
              prefixIcon: Icon(icon, color: kOliveGreen),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: kOliveGreen,
                      ),
                      onPressed: onVisibilityToggle,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none, // Çerçeveyi kaldırdık, sadece dolgu
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: kDarkGreen, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.redAccent, width: 1),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }
}