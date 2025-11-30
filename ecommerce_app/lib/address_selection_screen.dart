import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/adres_model.dart';
import '../models/urun_model.dart';
import 'payment_screen.dart'; // Ödeme ekranını import et

// Renkler (Senin teman)
const Color kBookPaper = Color(0xFFFEFAE0);
const Color kDarkGreen = Color(0xFF283618);
const Color kOliveGreen = Color(0xFF606C38);

class AddressSelectionScreen extends StatefulWidget {
  final double toplamTutar;
  final List<Urun> sepetUrunleri;

  const AddressSelectionScreen({
    super.key,
    required this.toplamTutar,
    required this.sepetUrunleri,
  });

  @override
  State<AddressSelectionScreen> createState() => _AddressSelectionScreenState();
}

class _AddressSelectionScreenState extends State<AddressSelectionScreen> {
  List<Adres> _adresler = [];
  bool _isLoading = true;
  int? _selectedAdresId; // Seçilen adresin ID'sini tutar

  // Form Kontrolcüleri (Yeni Ekleme İçin)
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
    // BURAYA KENDİ IP ADRESİNİ YAZ
    return "http://10.180.131.237:5126/api";
  }

  // API: Adresleri Listele
  Future<void> _adresleriGetir() async {
    final prefs = await SharedPreferences.getInstance();
    final int? musteriId = prefs.getInt('musteriId');

    if (musteriId == null) return;

    try {
      final response = await http.get(Uri.parse("${getBaseUrl()}/Adresler/Listele/$musteriId"));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        setState(() {
          _adresler = body.map((item) => Adres.fromJson(item)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Adres getirme hatası: $e");
      setState(() => _isLoading = false);
    }
  }

  // API: Yeni Adres Ekle
  Future<void> _adresEkle() async {
    final prefs = await SharedPreferences.getInstance();
    final int? musteriId = prefs.getInt('musteriId');

    if (musteriId == null) return;

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
        Navigator.pop(context); // Formu kapat
        _temizleForm();
        _adresleriGetir(); // Listeyi yenile
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Adres eklendi!")));
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
      isScrollControlled: true, // Klavye açılınca yukarı kaysın
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Yeni Adres Ekle", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(controller: _baslikController, decoration: const InputDecoration(labelText: "Başlık (Ev, İş)")),
            Row(
              children: [
                Expanded(child: TextField(controller: _sehirController, decoration: const InputDecoration(labelText: "Şehir"))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: _ilceController, decoration: const InputDecoration(labelText: "İlçe"))),
              ],
            ),
            TextField(controller: _acikAdresController, decoration: const InputDecoration(labelText: "Açık Adres"), maxLines: 2),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _adresEkle,
              style: ElevatedButton.styleFrom(backgroundColor: kDarkGreen, foregroundColor: Colors.white),
              child: const Text("Kaydet"),
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
        title: const Text("Teslimat Adresi Seçin"),
        backgroundColor: kDarkGreen,
        foregroundColor: kBookPaper,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: _adresler.isEmpty
                      ? const Center(child: Text("Kayıtlı adresiniz yok. Lütfen ekleyin."))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _adresler.length,
                          itemBuilder: (context, index) {
                            final adres = _adresler[index];
                            final bool isSelected = _selectedAdresId == adres.adresId;

                            return Card(
                              color: isSelected ? kOliveGreen.withOpacity(0.1) : Colors.white,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(color: isSelected ? kOliveGreen : Colors.transparent, width: 2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                onTap: () {
                                  setState(() {
                                    _selectedAdresId = adres.adresId;
                                  });
                                },
                                leading: Icon(
                                  isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                                  color: isSelected ? kOliveGreen : Colors.grey,
                                ),
                                title: Text(adres.baslik, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text("${adres.sehir} / ${adres.ilce}\n${adres.acikAdres}"),
                                isThreeLine: true,
                              ),
                            );
                          },
                        ),
                ),
                
                // ALT BAR (Yeni Ekle ve Devam Et)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))],
                  ),
                  child: Column(
                    children: [
                      // Yeni Adres Ekle Butonu
                      OutlinedButton.icon(
                        onPressed: _yeniAdresEklePenceresiAc,
                        icon: const Icon(Icons.add, color: kDarkGreen),
                        label: const Text("Yeni Adres Ekle", style: TextStyle(color: kDarkGreen)),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          side: const BorderSide(color: kDarkGreen),
                        ),
                      ),
                      const SizedBox(height: 10),
                      
                      // Ödemeye Geç Butonu
                      ElevatedButton(
                        onPressed: _selectedAdresId == null
                            ? null // Adres seçilmediyse pasif
                            : () async {
                                // Seçilen adresi bul
                                // final secilenAdres = _adresler.firstWhere((element) => element.adresId == _selectedAdresId);
                                
                                // Ödeme Ekranına Git
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PaymentScreen(
                                      toplamTutar: widget.toplamTutar,
                                      sepetUrunleri: widget.sepetUrunleri,
                                      // İlerde buraya 'secilenAdres'i de gönderebilirsin
                                    ),
                                  ),
                                );
                                
                                // Eğer ödeme başarılıysa geriye dön (true)
                                if (result == true) {
                                  Navigator.pop(context, true);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kDarkGreen,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("ÖDEMEYE GEÇ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}