import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'models/satislar_model.dart';
//import 'models/adres_model.dart'; 

const Color kBookPaper = Color(0xFFFEFAE0);
const Color kDarkGreen = Color(0xFF283618);
const Color kOliveGreen = Color(0xFF606C38);
const Color kDarkCoffee = Color(0xFF211508);

class SiparisGrubu {
  final String siparisNo;
  final DateTime tarih;
  final double toplamTutar;
  final List<Satis> urunler;
  final String teslimatAdresi;

  SiparisGrubu({
    required this.siparisNo,
    required this.tarih,
    required this.toplamTutar,
    required this.urunler,
    required this.teslimatAdresi,
  });
}

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  bool _isLoading = true;
  String _hataMesaji = "";
  List<SiparisGrubu> _gruplanmisSiparisler = [];

  @override
  void initState() {
    super.initState();
    _siparisleriGetir();
  }

  String getBaseUrl() {
    // BURAYA KENDİ IP ADRESİNİ YAZMAYI UNUTMA
    String ipAdresim = "10.180.131.237";
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
      final response = await http.get(Uri.parse("${getBaseUrl()}/Musteris/SatisGecmisi/$musteriId"));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        List<Satis> hamListe = body.map((item) => Satis.fromJson(item)).toList();

        // Gruplama Mantığı
        Map<String, List<Satis>> gruplar = {};
        
        for (var satis in hamListe) {
          // Eğer sipariş no null ise geçici ID oluştur
          String key = (satis.siparisNo != null && satis.siparisNo!.isNotEmpty)
              ? satis.siparisNo!
              : "TEMP-${satis.satisId}"; // Modelde satisId olduğundan emin ol
              
          if (!gruplar.containsKey(key)) {
            gruplar[key] = [];
          }
          gruplar[key]!.add(satis);
        }

        List<SiparisGrubu> tempListe = [];
        gruplar.forEach((siparisNo, urunler) {
          double toplam = urunler.fold(0, (sum, item) => sum + item.toplamTutar);
          
          // Grubun ilk ürününden tarih ve adres bilgisini alıyoruz
          var ilkUrun = urunler.first;
          
          // --- ADRES MANTIĞI DÜZELTİLDİ ---
          String adresMetni = "Adres yok"; 

          // Eğer modelde teslimatAdresi dolu gelmişse formatla
          if (ilkUrun.teslimatAdresi != null) {
             var adr = ilkUrun.teslimatAdresi!;
             adresMetni = "${adr.baslik} (${adr.sehir}/${adr.ilce})\n${adr.acikAdres}";
          }
          // ---------------------------------

          tempListe.add(SiparisGrubu(
            siparisNo: siparisNo,
            tarih: ilkUrun.tarih,
            toplamTutar: toplam,
            urunler: urunler,
            teslimatAdresi: adresMetni, 
          ));
        });

        // Tarihe göre sırala (En yeni en üstte)
        tempListe.sort((a, b) => b.tarih.compareTo(a.tarih));

        if (mounted) {
          setState(() {
            _gruplanmisSiparisler = tempListe;
            _isLoading = false;
          });
        }
      } else {
        throw Exception("Siparişler yüklenemedi. Kod: ${response.statusCode}");
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
      case 0: metin = "Sipariş Alındı"; renk = Colors.blue; ikon = Icons.assignment_turned_in_outlined; break;
      case 1: metin = "Hazırlanıyor"; renk = Colors.orange; ikon = Icons.inventory_2_outlined; break;
      case 2: metin = "Kargoya Verildi"; renk = Colors.purple; ikon = Icons.local_shipping_outlined; break;
      case 3: metin = "Teslim Edildi"; renk = Colors.green; ikon = Icons.check_circle_outline; break;
      case 4: metin = "İptal Edildi"; renk = Colors.red; ikon = Icons.cancel_outlined; break;
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
          Text(metin, style: TextStyle(color: renk, fontWeight: FontWeight.bold, fontSize: 12)),
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
            : _gruplanmisSiparisler.isEmpty 
                ? _buildBosDurum()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _gruplanmisSiparisler.length, 
                    itemBuilder: (context, index) {
                      return _buildSiparisKarti(_gruplanmisSiparisler[index]);
                    },
                  ),
    );
  }

  Widget _buildSiparisKarti(SiparisGrubu siparis) {
    String tarihFormatli = "${siparis.tarih.day}.${siparis.tarih.month}.${siparis.tarih.year} - ${siparis.tarih.hour}:${siparis.tarih.minute.toString().padLeft(2, '0')}";
    int durumId = siparis.urunler.isNotEmpty ? siparis.urunler.first.siparisDurumu : 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: kOliveGreen.withOpacity(0.15), shape: BoxShape.circle),
          child: const Icon(Icons.shopping_bag, color: kOliveGreen, size: 24),
        ),
        
        title: Text(
          "Sipariş No: ${siparis.siparisNo}",
          style: const TextStyle(fontWeight: FontWeight.bold, color: kDarkCoffee, fontSize: 15),
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildDurumRozeti(durumId),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(tarihFormatli, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
                Text("${siparis.toplamTutar.toStringAsFixed(2)} ₺", style: const TextStyle(fontWeight: FontWeight.w800, color: kDarkGreen, fontSize: 16)),
              ],
            )
          ],
        ),

        children: [
          // --- ADRES KUTUSU ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withOpacity(0.3))
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Teslimat Adresi:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.orange)),
                      const SizedBox(height: 2),
                      Text(
                        siparis.teslimatAdresi, 
                        style: const TextStyle(fontSize: 13, color: kDarkCoffee),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Ürün Listesi
          ...siparis.urunler.map((urunSatis) {
            return Container(
              decoration: BoxDecoration(
                color: kBookPaper.withOpacity(0.5),
                border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2)))
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: SizedBox(
                  width: 45,
                  height: 60,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      urunSatis.urun?.urunGorsel ?? "",
                      fit: BoxFit.cover,
                      errorBuilder: (c, o, s) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.book, size: 20, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                title: Text(
                  urunSatis.urun?.urunAdi ?? "Bilinmeyen Ürün",
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text("Adet: ${urunSatis.adet}", style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                trailing: Text("${(urunSatis.fiyat * urunSatis.adet).toStringAsFixed(2)} ₺", style: const TextStyle(fontWeight: FontWeight.bold, color: kDarkCoffee)),
              ),
            );
          }).toList(),
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