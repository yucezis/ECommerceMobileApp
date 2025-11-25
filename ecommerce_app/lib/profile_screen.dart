import 'package:flutter/material.dart';
import 'dart:convert'; 
import 'package:http/http.dart' as http; 
import 'models/musteri_model.dart'; 

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
    final String ipAdresim = "10.180.131.237";
    final url = Uri.parse("http://$ipAdresim:5126/api/Musteris/1");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _musteri = Musteri.fromJson(data);
          _isLoading = false; 
        });
      } else {
        debugPrint("Hata: ${response.statusCode}");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("API Hatası: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color.fromARGB(255,64, 38, 42);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF3E0),
      appBar: AppBar(
        title: const Text(
          "Profilim",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings, color: Colors.white),
          ),
        ],
      ),
     
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  
                  _buildProfileHeader(primaryColor),

                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        _buildMenuItem(
                          icon: Icons.shopping_bag_outlined,
                          title: "Siparişlerim",
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          icon: Icons.favorite_border,
                          title: "Favorilerim",
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          icon: Icons.location_on_outlined,
                          title: "Adreslerim (${_musteri?.musteriSehir ?? ''})",
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          icon: Icons.credit_card,
                          title: "Ödeme Yöntemlerim",
                          onTap: () {},
                        ),
                        const Divider(),
                        _buildMenuItem(
                          icon: Icons.help_outline,
                          title: "Yardım ve Destek",
                          onTap: () {},
                        ),
                        _buildMenuItem(
                          icon: Icons.logout,
                          title: "Çıkış Yap",
                          color: Colors.redAccent,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader(Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 48,
              backgroundImage: NetworkImage(
                  "https://cdn-icons-png.flaticon.com/512/3135/3135715.png"), 
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
              color: Colors.white,
            ),
          ),
          
          Text(
            _musteri?.musteriMail ?? "...",
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = const Color(0xFF333333),
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color == Colors.redAccent ? color : const Color(0xFF6200EE)),
      ),
      title: Text(
        title,
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w500, color: color),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 5),
    );
  }
}