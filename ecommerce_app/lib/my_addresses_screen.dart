import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'models/adres_model.dart';

// Renkler
const Color kBookPaper = Color(0xFFFEFAE0);
const Color kDarkGreen = Color(0xFF283618);
const Color kOliveGreen = Color(0xFF606C38);
const Color kDiscountRed = Color(0xFFBC4749);

class MyAddressesScreen extends StatefulWidget {
  const MyAddressesScreen({super.key});

  @override
  State<MyAddressesScreen> createState() => _MyAddressesScreenState();
}

class _MyAddressesScreenState extends State<MyAddressesScreen> {
  List<Adres> _adresler = [];
  bool _isLoading = true;

  // Form Kontrolcüleri
  final _baslikController = TextEditingController();
  final _sehirController = TextEditingController();
  final _ilceController = TextEditingController();
  final _acikAdresController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _adresleriGetir();
  }

  String getBaseUrl() {
    return "http://10.180.131.237:5126/api"; // Kendi IP adresin
  }

  // --- API: ADRESLERİ GETİR ---
  Future<void> _adresleriGetir() async {
    final prefs = await SharedPreferences.getInstance();
    final int? musteriId = prefs.getInt('musteriId');

    if (musteriId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await http.get(Uri.parse("${getBaseUrl()}/Adresler/Listele/$musteriId"));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        setState(() {
          _adresler = body.map((item) => Adres.fromJson(item)).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Hata: $e");
      setState(() => _isLoading = false);
    }
  }

  // --- API: ADRES SİL ---
  Future<void> _adresSil(int adresId) async {
    // Emin misin diye soralım
    bool? eminMi = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Adresi Sil"),
        content: const Text("Bu adresi silmek istediğinize emin misiniz?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("İptal", style: TextStyle(color: Colors.grey))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Sil", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (eminMi != true) return;

    try {
      final response = await http.delete(Uri.parse("${getBaseUrl()}/Adresler/Sil/$adresId"));

      if (response.statusCode == 200) {
        _adresleriGetir(); // Listeyi yenile
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Adres silindi."), backgroundColor: kDarkGreen));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e"), backgroundColor: Colors.red));
    }
  }

  // --- API: ADRES EKLE ---
  Future<void> _adresEkle() async {
    final prefs = await SharedPreferences.getInstance();
    final int? musteriId = prefs.getInt('musteriId');
    if (musteriId == null) return;

    if (_baslikController.text.isEmpty || _acikAdresController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen zorunlu alanları doldurun.")));
      return;
    }

    Adres yeniAdres = Adres(
      baslik: _baslikController.text,
      sehir: _sehirController.text,
      ilce: _ilceController.text,
      acikAdres: _acikAdresController.text,
      musteriId: musteriId,
    );

    try {
      final response = await http.post(
        Uri.parse("${getBaseUrl()}/Adresler/Ekle"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(yeniAdres.toJson()),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context); // BottomSheet'i kapat
        _temizleForm();
        _adresleriGetir(); // Listeyi yenile
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Adres başarıyla eklendi."), backgroundColor: kDarkGreen));
      }
    } catch (e) {
      print("Ekleme hatası: $e");
    }
  }

  void _temizleForm() {
    _baslikController.clear();
    _sehirController.clear();
    _ilceController.clear();
    _acikAdresController.clear();
  }

  void _yeniAdresEklePenceresiAc() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20, right: 20, top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Yeni Adres Ekle", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kDarkGreen)),
            const SizedBox(height: 15),
            TextField(controller: _baslikController, decoration: const InputDecoration(labelText: "Adres Başlığı (Ev, İş)", border: OutlineInputBorder())),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: TextField(controller: _sehirController, decoration: const InputDecoration(labelText: "Şehir", border: OutlineInputBorder()))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: _ilceController, decoration: const InputDecoration(labelText: "İlçe", border: OutlineInputBorder()))),
              ],
            ),
            const SizedBox(height: 10),
            TextField(controller: _acikAdresController, decoration: const InputDecoration(labelText: "Açık Adres", border: OutlineInputBorder()), maxLines: 3),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _adresEkle,
                style: ElevatedButton.styleFrom(backgroundColor: kDarkGreen, foregroundColor: Colors.white),
                child: const Text("KAYDET", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBookPaper,
      appBar: AppBar(
        title: const Text("Kayıtlı Adreslerim"),
        backgroundColor: kDarkGreen,
        foregroundColor: kBookPaper,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kDarkGreen))
          : _adresler.isEmpty
              ? _buildBosDurum()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _adresler.length,
                  itemBuilder: (context, index) {
                    final adres = _adresler[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: kOliveGreen.withOpacity(0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.location_on, color: kOliveGreen),
                        ),
                        title: Text(adres.baslik, style: const TextStyle(fontWeight: FontWeight.bold, color: kDarkGreen)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text("${adres.sehir} / ${adres.ilce}\n${adres.acikAdres}", style: TextStyle(color: Colors.grey[700])),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: kDiscountRed),
                          onPressed: () => _adresSil(adres.adresId ?? 0),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _yeniAdresEklePenceresiAc,
        backgroundColor: kDarkGreen,
        foregroundColor: kBookPaper,
        icon: const Icon(Icons.add),
        label: const Text("Yeni Adres"),
      ),
    );
  }

  Widget _buildBosDurum() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          const Text("Henüz kayıtlı adresiniz yok.", style: TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }
}