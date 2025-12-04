import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'footer.dart';
import 'register_screen.dart';

// --- RENKLERİ BURAYA (CLASS DIŞINA) TAŞIDIK ---
const Color kPrimary = Color(0xFF606C38);
const Color kDarkGreen = Color(0xFF283618);
const Color kCream = Color(0xFFFEFAE0);
const Color kBrown = Color(0xFF211508);
const Color kBookPaper = Color(0xFFFEFAE0); 
const Color kOliveGreen = Color(0xFF606C38); // İkonlar için

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  String getBaseUrl() {
    String ipAdresim = "10.180.131.237";
    String port = "5126";
    return "http://$ipAdresim:$port/api";
  }

  Future<void> _girisYap() async {
    setState(() => _isLoading = true);

    try {
      final url = Uri.parse("${getBaseUrl()}/Musteris/Login");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "Mail": _emailController.text,
          "Sifre": _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        int musteriId = data['musteriId'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('musteriId', musteriId);
        await prefs.setString('musteriAd', data['musteriAdi']);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Giriş Başarılı! Hoşgeldiniz."),
              backgroundColor: kBrown,
            ),
          );
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Footer(key: Footer.footerKey)));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Hatalı E-posta veya Şifre!"),
              backgroundColor: kBrown,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Bağlantı Hatası: $e"),
            backgroundColor: kBrown,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sifreSifirla(String mail) async {
    if (mail.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator(color: kDarkGreen)),
    );

    try {
      final response = await http.post(
        Uri.parse("${getBaseUrl()}/Musteris/SifremiUnuttum"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"Mail": mail}),
      );

      if (mounted) Navigator.pop(context); 

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Yeni şifreniz mail adresinize gönderildi."), backgroundColor: Colors.green),
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
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e")));
      }
    }
  }

  void _sifremiUnuttumPenceresiAc() {
    TextEditingController mailController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Şifremi Unuttum", style: TextStyle(color: kDarkGreen)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Sisteme kayıtlı e-posta adresinizi giriniz. Yeni şifreniz mail olarak gönderilecektir."),
            const SizedBox(height: 15),
            TextField(
              controller: mailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: "E-Posta Adresi",
                prefixIcon: Icon(Icons.email_outlined, color: kPrimary),
                border: OutlineInputBorder(),
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
            style: ElevatedButton.styleFrom(backgroundColor: kDarkGreen, foregroundColor: kCream),
            onPressed: () => _sifreSifirla(mailController.text),
            child: const Text("GÖNDER"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kPrimary.withOpacity(.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  size: 80,
                  color: kDarkGreen,
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "Books",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: kDarkGreen,
                  letterSpacing: 1.3,
                ),
              ),

              const SizedBox(height: 40),

              _buildStyledTextField(
                controller: _emailController,
                label: "E-Posta",
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 20),

              _buildStyledTextField(
                controller: _passwordController,
                label: "Şifre",
                icon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 30),
              
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _sifremiUnuttumPenceresiAc,
                  child: const Text(
                    "Şifremi Unuttum?",
                    style: TextStyle(
                      color: kDarkGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _girisYap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: kDarkGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Giriş Yap",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Hesabın yok mu?",
                      style: TextStyle(color: kDarkGreen, fontSize: 14)),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const RegisterScreen()));
                    },
                    child: const Text(
                      "Kayıt Ol",
                      style: TextStyle(
                        color: kPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      cursorColor: kDarkGreen,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: label,
        labelStyle: const TextStyle(color: kDarkGreen),
        prefixIcon: Icon(icon, color: kDarkGreen),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: kPrimary.withOpacity(.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kPrimary, width: 2),
        ),
      ),
    );
  }
}