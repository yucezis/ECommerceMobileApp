import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/musteri_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

// --- RENK PALETİ ---
const Color kBookPaper = Color(0xFFFEFAE0); // Arka plan (Krem)
const Color kDarkGreen = Color(0xFF283618); // Header & Başlık
const Color kOliveGreen = Color(0xFF606C38); // İkonlar & Vurgular
const Color kDarkCoffee = Color(0xFF211508); // Metinler
const Color kCreamAccent = Color(0xFFFAEDCD); // Hafif vurgu

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Musteri? _musteri;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _musteriGetir();
  }

  Future<void> _musteriGetir() async {
    final prefs = await SharedPreferences.getInstance();
    
    final int? kayitliId = prefs.getInt('musteriId');

    if (kayitliId == null) {
    debugPrint("Hata: Kullanıcı ID'si bulunamadı. Giriş yapılmamış olabilir.");
    setState(() => _isLoading = false);
    return;
    }

    final String ipAdresim = "10.180.131.237";
    final url = Uri.parse("http://$ipAdresim:5126/api/Musteris/$kayitliId");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _musteri = Musteri.fromJson(data);
            _isLoading = false;
          });
        }
      } else {
        debugPrint("Hata: ${response.statusCode}");
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("API Hatası: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBookPaper,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kDarkGreen))
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 60),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Hesabım",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: kDarkCoffee,
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildMenuItem(
                          icon: Icons.shopping_bag_outlined,
                          title: "Siparişlerim",
                          subtitle: "Geçmiş siparişlerini incele",
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          icon: Icons.favorite_border,
                          title: "Favorilerim",
                          subtitle: "Beğendiğin kitaplar burada",
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          icon: Icons.location_on_outlined,
                          title: "Adreslerim",
                          subtitle: _musteri?.musteriSehir ?? "Adres eklenmedi",
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          icon: Icons.credit_card,
                          title: "Ödeme Yöntemleri",
                          subtitle: "Kayıtlı kartların",
                          onTap: () {},
                        ),
                        
                        const SizedBox(height: 25),
                        const Text(
                          "Uygulama Ayarları",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: kDarkCoffee,
                          ),
                        ),
                        const SizedBox(height: 15),
                        
                        _buildMenuItem(
                          icon: Icons.help_outline,
                          title: "Yardım ve Destek",
                          subtitle: "SSS ve İletişim",
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          icon: Icons.logout,
                          title: "Çıkış Yap",
                          subtitle: "Hesabından güvenle çık",
                          isDestructive: true,
                          onTap: () async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.clear();
                            if (mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                                (route) => false,
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // --- WIDGETS ---

  Widget _buildProfileHeader() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // 1. Arka Plan Kutusu
        Container(
          width: double.infinity,
          height: 330, 
          decoration: const BoxDecoration(
            color: kDarkGreen,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
            boxShadow: [
               BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new, color: kBookPaper),
                      ),
                      const Text(
                        "Profilim",
                        style: TextStyle(color: kBookPaper, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.settings, color: kBookPaper),
                      ),
                    ],
                  ),
                ),
                // Profil Resmi ve İsim
                const SizedBox(height: 5), // Biraz boşlukları da dengeledik
                Container(
                  padding: const EdgeInsets.all(4), 
                  decoration: const BoxDecoration(
                    color: kBookPaper, 
                    shape: BoxShape.circle,
                  ),
                  child: const CircleAvatar(
                    radius: 45,
                    backgroundImage: NetworkImage("https://r.resimlink.com/YP4EnpRIiaJ.jpeg"),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _musteri != null 
                      ? "${_musteri!.musteriAdi} ${_musteri!.musteriSoyadi}" 
                      : "Kullanıcı",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: kBookPaper,
                  ),
                ),
                Text(
                  _musteri?.musteriMail ?? "...",
                  style: TextStyle(
                    fontSize: 14,
                    color: kBookPaper.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 2. Yüzen İstatistik Kartı
        Positioned(
          bottom: -40, 
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: kDarkGreen.withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem("Siparişler", "12"),
                _buildVerticalDivider(),
                _buildStatItem("Puanım", "350"),
                _buildVerticalDivider(),
                _buildStatItem("Yorumlar", "5"),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: kDarkGreen,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey.withOpacity(0.3),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: kDarkGreen.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDestructive ? Colors.redAccent.withOpacity(0.1) : kOliveGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.redAccent : kOliveGreen,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDestructive ? Colors.redAccent : kDarkCoffee,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              )
            : null,
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }
}