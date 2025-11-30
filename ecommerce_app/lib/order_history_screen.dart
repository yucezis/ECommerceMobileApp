import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'models/satislar_model.dart';

// Renkler (Senin teman)
const Color kBookPaper = Color(0xFFFEFAE0);
const Color kDarkGreen = Color(0xFF283618);
const Color kOliveGreen = Color(0xFF606C38);
const Color kDarkCoffee = Color(0xFF211508);

class SiparisGrubu {
  final String siparisNo;
  final DateTime tarih;
  final double toplamTutar;
  final List<Satis> urunler;

  SiparisGrubu({
    required this.siparisNo,
    required this.tarih,
    required this.toplamTutar,
    required this.urunler,
  });
}

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<Satis> _siparisler = [];
  bool _isLoading = true;
  String _hataMesaji = "";

  @override
  void initState() {
    super.initState();
    _siparisleriGetir();
  }

  String getBaseUrl() {
    String ipAdresim = "10.180.131.237";
    String port = "5126";
    return "http://$ipAdresim:$port/api";
  }

  List<SiparisGrubu> _gruplanmisSiparisler = []; 

  Future<void> _siparisleriGetir() async {
    final prefs = await SharedPreferences.getInstance();
    final int? musteriId = prefs.getInt('musteriId');

    if (musteriId == null) {
      setState(() {
        _hataMesaji = "Oturum bilgisi bulunamadı.";
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(Uri.parse("${getBaseUrl()}/Musteris/SatisGecmisi/$musteriId"));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        List<Satis> hamListe = body.map((item) => Satis.fromJson(item)).toList();

        // --- GRUPLAMA ALGORİTMASI ---
        Map<String, List<Satis>> gruplar = {};
        
        for (var satis in hamListe) {
          if (!gruplar.containsKey(satis.siparisNo)) {
            gruplar[satis.siparisNo] = [];
          }
          gruplar[satis.siparisNo]!.add(satis);
        }

        List<SiparisGrubu> tempListe = [];
        gruplar.forEach((siparisNo, urunler) {
          // O siparişin toplam tutarını hesapla
          double toplam = urunler.fold(0, (sum, item) => sum + item.toplamTutar);
          
          tempListe.add(SiparisGrubu(
            siparisNo: siparisNo,
            tarih: urunler.first.tarih, // Hepsinin tarihi aynıdır
            toplamTutar: toplam,
            urunler: urunler,
          ));
        });

        // Tarihe göre sırala (Yeni en üstte)
        tempListe.sort((a, b) => b.tarih.compareTo(a.tarih));

        if (mounted) {
          setState(() {
            _gruplanmisSiparisler = tempListe;
            _isLoading = false;
          });
        }
      } else {
        throw Exception("Siparişler yüklenemedi.");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hataMesaji = "Bir hata oluştu: $e";
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildDurumRozeti(int durumId) {
  String metin = "Bilinmiyor";
  Color renk = Colors.grey;
  IconData ikon = Icons.help_outline;

  switch (durumId) {
    case 0:
      metin = "Sipariş Alındı";
      renk = Colors.blue;
      ikon = Icons.assignment_turned_in_outlined;
      break;
    case 1:
      metin = "Hazırlanıyor";
      renk = Colors.orange;
      ikon = Icons.inventory_2_outlined;
      break;
    case 2:
      metin = "Kargoya Verildi";
      renk = Colors.purple;
      ikon = Icons.local_shipping_outlined;
      break;
    case 3:
      metin = "Teslim Edildi";
      renk = Colors.green;
      ikon = Icons.check_circle_outline;
      break;
    case 4:
      metin = "İptal Edildi";
      renk = Colors.red;
      ikon = Icons.cancel_outlined;
      break;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: renk.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: renk.withOpacity(0.5)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(ikon, size: 14, color: renk),
        const SizedBox(width: 5),
        Text(
          metin,
          style: TextStyle(color: renk, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBookPaper,
      appBar: AppBar(
        title: const Text("Sipariş Geçmişim", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: kDarkGreen,
        foregroundColor: kBookPaper,
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
    ? const Center(child: CircularProgressIndicator(color: kDarkGreen))
    : _hataMesaji.isNotEmpty
        ? Center(child: Text(_hataMesaji))
        : _gruplanmisSiparisler.isEmpty // _siparisler DEĞİL
            ? _buildBosDurum()
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _gruplanmisSiparisler.length, // _siparisler DEĞİL
                itemBuilder: (context, index) {
                  return _buildSiparisKarti(_gruplanmisSiparisler[index]);
                },
              ),
    );
  }

  Widget _buildSiparisKarti(SiparisGrubu siparis) {
    String tarihFormatli = "${siparis.tarih.day}.${siparis.tarih.month}.${siparis.tarih.year} - ${siparis.tarih.hour}:${siparis.tarih.minute.toString().padLeft(2, '0')}";
    
    // Siparişin durumunu listedeki ilk üründen alıyoruz (Hepsi aynıdır)
    int durumId = siparis.urunler.isNotEmpty ? siparis.urunler.first.siparisDurumu : 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        
        // 👇 BAŞLIK KISMINI DEĞİŞTİRDİK
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Sipariş No: ${siparis.siparisNo}",
              style: const TextStyle(fontWeight: FontWeight.bold, color: kDarkCoffee, fontSize: 14),
            ),
            // Durum Rozetini Buraya Koyuyoruz
            _buildDurumRozeti(durumId),
          ],
        ),
        
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(tarihFormatli, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              "${siparis.toplamTutar} ₺",
              style: const TextStyle(fontWeight: FontWeight.bold, color: kDarkGreen, fontSize: 16),
            ),
          ],
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: kOliveGreen.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.shopping_bag, color: kOliveGreen),
        ),
        
        // İÇERİK KISMI (Ürün Listesi - Aynen Kalıyor)
        children: siparis.urunler.map((urunSatis) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                urunSatis.urun?.urunGorsel ?? "",
                width: 40, height: 60, fit: BoxFit.cover,
                errorBuilder: (c, o, s) => const Icon(Icons.book, color: Colors.grey),
              ),
            ),
            title: Text(urunSatis.urun?.urunAdi ?? "Bilinmeyen Ürün", style: const TextStyle(fontWeight: FontWeight.w600)),
            trailing: Text("${urunSatis.fiyat} ₺", style: const TextStyle(fontWeight: FontWeight.bold)),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBosDurum() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const Text("Henüz siparişiniz bulunmuyor.", style: TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }
}