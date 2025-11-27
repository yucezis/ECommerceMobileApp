import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'footer.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // Color Palette
  final Color primary = const Color(0xFF606C38);
  final Color darkGreen = const Color(0xFF283618);
  final Color cream = const Color(0xFFFEFAE0);
  final Color brown = const Color(0xFF211508);

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
            SnackBar(
              content: const Text("Giriş Başarılı! Hoşgeldiniz."),
              backgroundColor: brown,
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Footer()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Hatalı E-posta veya Şifre!"),
              backgroundColor: brown,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Bağlantı Hatası: $e"),
            backgroundColor: brown,
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
      backgroundColor: cream,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: primary.withOpacity(.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  size: 80,
                  color: darkGreen,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                "Books",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: darkGreen,
                  letterSpacing: 1.3,
                ),
              ),

              const SizedBox(height: 40),

              // TEXTFIELD DESIGNED
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

              // LOGIN BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _girisYap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: darkGreen,
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

              // REGISTER LINK
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Hesabın yok mu?",
                      style: TextStyle(color: darkGreen, fontSize: 14)),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const RegisterScreen()));
                    },
                    child: Text(
                      "Kayıt Ol",
                      style: TextStyle(
                        color: primary,
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
      cursorColor: darkGreen,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: label,
        labelStyle: TextStyle(color: darkGreen),
        prefixIcon: Icon(icon, color: darkGreen),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary.withOpacity(.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary, width: 2),
        ),
      ),
    );
  }
}
