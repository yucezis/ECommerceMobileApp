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
    String ipAdresim = "10.180.131.237"; // Kendi IP adresin
    String port = "5126";
    return "http://$ipAdresim:$port/api";
  }

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
      // API Endpoint: api/Musteris/SatisGecmisi/5
      final response = await http.get(Uri.parse("${getBaseUrl()}/Musteris/SatisGecmisi/$musteriId"));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        List<Satis> gelenSiparisler = body.map((item) => Satis.fromJson(item)).toList();

        // Tarihe göre yeniden eskiye sırala
        gelenSiparisler.sort((a, b) => b.tarih.compareTo(a.tarih));

        if (mounted) {
          setState(() {
            _siparisler = gelenSiparisler;
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
              : _siparisler.isEmpty
                  ? _buildBosDurum()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _siparisler.length,
                      itemBuilder: (context, index) {
                        return _buildSiparisKarti(_siparisler[index]);
                      },
                    ),
    );
  }

  Widget _buildSiparisKarti(Satis satis) {
    // Tarih Formatı (Yıl-Ay-Gün Saat:Dakika)
    String tarihFormatli = "${satis.tarih.day}.${satis.tarih.month}.${satis.tarih.year} - ${satis.tarih.hour}:${satis.tarih.minute.toString().padLeft(2, '0')}";

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: kDarkGreen.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border(left: BorderSide(color: kOliveGreen, width: 5)), // Sol tarafa yeşil çizgi
      ),
      child: Row(
        children: [
          // Ürün Resmi
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 70,
              height: 90,
              color: Colors.grey[200],
              child: satis.urun != null
                  ? Image.network(
                      satis.urun!.urunGorsel,
                      fit: BoxFit.cover,
                      errorBuilder: (c, o, s) => const Icon(Icons.book, color: Colors.grey),
                    )
                  : const Icon(Icons.image_not_supported),
            ),
          ),
          const SizedBox(width: 15),
          
          // Bilgiler
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  satis.urun?.urunAdi ?? "Bilinmeyen Ürün",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: kDarkCoffee,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  "Sipariş Tarihi: $tarihFormatli",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${satis.adet} Adet",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      "${satis.toplamTutar} ₺",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: kDarkGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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