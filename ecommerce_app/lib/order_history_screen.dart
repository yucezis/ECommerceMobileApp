import 'dart:convert';
import 'dart:io'; // Dosya işlemleri için
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/satislar_model.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'models/urun_model.dart';


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

  File? _secilenResim;
  final ImagePicker _picker = ImagePicker();

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

  String? _resmiBase64Yap() {
    if (_secilenResim == null) return null;
    List<int> imageBytes = _secilenResim!.readAsBytesSync();
    return base64Encode(imageBytes);
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

        Map<String, List<Satis>> gruplar = {};
        
        for (var satis in hamListe) {
          String key = (satis.siparisNo != null && satis.siparisNo!.isNotEmpty)
              ? satis.siparisNo!
              : "TEMP-${satis.satisId}"; 
              
          if (!gruplar.containsKey(key)) {
            gruplar[key] = [];
          }
          gruplar[key]!.add(satis);
        }

        List<SiparisGrubu> tempListe = [];
        gruplar.forEach((siparisNo, urunler) {
          double toplam = urunler.fold(0, (sum, item) => sum + item.toplamTutar);
          var ilkUrun = urunler.first;
          
          String adresMetni = "Adres yok"; 
          if (ilkUrun.teslimatAdresi != null) {
             var adr = ilkUrun.teslimatAdresi!;
             adresMetni = "${adr.baslik} (${adr.sehir}/${adr.ilce})\n${adr.acikAdres}";
          }

          tempListe.add(SiparisGrubu(
            siparisNo: siparisNo,
            tarih: ilkUrun.tarih,
            toplamTutar: toplam,
            urunler: urunler,
            teslimatAdresi: adresMetni, 
          ));
        });

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

  Future<void> _yorumDetayiniGoster(String urunAdi, int? degerlendirmeId) async {
    if (degerlendirmeId == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator(color: kOliveGreen)),
    );

    try {
      final response = await http.get(
        Uri.parse("${getBaseUrl()}/Degerlendirmeler/GetirTek/$degerlendirmeId"),
      );

      if (mounted) Navigator.pop(context);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        
        if (mounted) {
          _yorumPenceresiniAc(urunAdi, data);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Yorum yüklenemedi.")));
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); 
      print("Hata: $e");
    }
  }

  void _yorumPenceresiniAc(String urunAdi, dynamic data) {
    showDialog(
      context: context,
      builder: (ctx) {
        bool onayli = data['onaylandi'] ?? false;
        String? resimUrl = data['resimUrl'];

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Column(
            children: [
              Text(urunAdi, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kDarkGreen), textAlign: TextAlign.center),
              const SizedBox(height: 5),
              Text(
                onayli ? "Yayında ✅" : "İnceleniyor ⏳", 
                style: TextStyle(fontSize: 12, color: onayli ? Colors.green : Colors.orange, fontWeight: FontWeight.bold)
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RatingBarIndicator(
                rating: (data['puan'] as int).toDouble(),
                itemBuilder: (context, index) => const Icon(Icons.star_rounded, color: Colors.amber),
                itemCount: 5,
                itemSize: 30.0,
                direction: Axis.horizontal,
              ),
              const SizedBox(height: 20),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: kBookPaper,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  (data['yorum'] != null && data['yorum'].toString().isNotEmpty) 
                      ? data['yorum'] 
                      : "Yorum yazılmamış.",
                  style: const TextStyle(color: kDarkCoffee, fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              ),

              if (resimUrl != null && resimUrl.isNotEmpty) ...[
                const SizedBox(height: 15),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    "${getBaseUrl().replaceAll('/api', '')}$resimUrl",
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (c, o, s) => const SizedBox(),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Kapat", style: TextStyle(color: kDarkGreen, fontWeight: FontWeight.bold)),
            )
          ],
        );
      },
    );
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

  void _degerlendirmePenceresiAc(int urunId, String urunAdi) {
    double secilenPuan = 5;
    TextEditingController yorumController = TextEditingController();
    
    setState(() {
      _secilenResim = null;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20, right: 20, top: 20
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Değerlendir: $urunAdi", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kDarkGreen), textAlign: TextAlign.center),
                  const SizedBox(height: 15),
                  
                  RatingBar.builder(
                    initialRating: 5,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => const Icon(Icons.star_rounded, color: Colors.amber, size: 36),
                    onRatingUpdate: (rating) {
                      secilenPuan = rating;
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  TextField(
                    controller: yorumController,
                    decoration: InputDecoration(
                      hintText: "Düşünceleriniz neler? (İsteğe bağlı)",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    maxLines: 3,
                  ),
                  
                  const SizedBox(height: 15),

                  Row(
                    children: [
                      InkWell(
                        onTap: () async {
                          final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
                          if (image != null) {
                            setModalState(() {
                              _secilenResim = File(image.path);
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey[400]!)
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.camera_alt, color: Colors.grey),
                              SizedBox(width: 5),
                              Text("Fotoğraf Ekle"),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      
                      if (_secilenResim != null)
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _secilenResim!,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              right: 0, top: 0,
                              child: InkWell(
                                onTap: () {
                                  setModalState(() => _secilenResim = null);
                                },
                                child: Container(
                                  color: Colors.black54,
                                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                                ),
                              ),
                            )
                          ],
                        )
                    ],
                  ),

                  const SizedBox(height: 10),
                  const Text("Not: Sadece puan verirseniz anında yayınlanır. Yorum yaparsanız onay beklersiniz.", style: TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kDarkGreen, 
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        
                        String? resimData = _resmiBase64Yap();
                        _yorumuKaydet(urunId, secilenPuan, yorumController.text, resimData);
                      },
                      child: const Text("GÖNDER", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  )
                ],
              ),
            );
          }
        );
      },
    );
  }

  Future<void> _yorumuKaydet(int urunId, double puan, String yorum, String? resimBase64) async {
    final prefs = await SharedPreferences.getInstance();
    final int? musteriId = prefs.getInt('musteriId');

    if (musteriId == null) return;

    try {
      final response = await http.post(
        Uri.parse("${getBaseUrl()}/Degerlendirmeler/Ekle"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "UrunId": urunId,
          "MusteriId": musteriId,
          "Puan": puan.toInt(),
          "Yorum": yorum,
          "ResimBase64": resimBase64 
        }),
      );

      if (mounted) {
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.body), backgroundColor: kDarkGreen));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: ${response.body}"), backgroundColor: Colors.red));
        }
      }
    } catch (e) {
      print("Yorum hatası: $e");
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

          if (siparis.urunler.first.siparisDurumu >= 1) 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () async {
                    final Uri url = Uri.parse("${getBaseUrl()}/Fatura/Olustur/${siparis.siparisNo}");
                    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fatura açılamadı.")));
                    }
                  },
                  icon: const Icon(Icons.picture_as_pdf, size: 20, color: Colors.redAccent),
                  label: const Text("E-Fatura Görüntüle", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    backgroundColor: Colors.redAccent.withOpacity(0.05),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                  ),
                ),
              ),
            ),
          
          ...siparis.urunler.map((urunSatis) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8, left: 16, right: 16, top: 4), 
              decoration: BoxDecoration(
                color: kBookPaper.withOpacity(0.5),
                border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2)))
              ),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

                  if (siparis.urunler.first.siparisDurumu == 3) 
                    Padding(
                      padding: const EdgeInsets.only(right: 10, bottom: 8),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          height: 30,
                          child: urunSatis.degerlendirmeYapildiMi
                              ? OutlinedButton.icon(
                                  onPressed: () {
                                    _yorumDetayiniGoster(urunSatis.urun?.urunAdi ?? "Ürün", urunSatis.degerlendirmeId);
                                  },
                                  icon: const Icon(Icons.check, size: 16, color: Colors.green),
                                  label: const Text("Değerlendirildi", style: TextStyle(fontSize: 12, color: Colors.green)),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.green, width: 1),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                  ),
                                )
                              : OutlinedButton.icon(
                                  onPressed: () {
                                    _degerlendirmePenceresiAc(urunSatis.urun?.urunId ?? 0, urunSatis.urun?.urunAdi ?? "Kitap");
                                  },
                                  icon: const Icon(Icons.star_rate_rounded, size: 16, color: Colors.amber),
                                  label: const Text("Değerlendir", style: TextStyle(fontSize: 12, color: kDarkGreen)),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: kDarkGreen, width: 1),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                  ),
                                ),
                        ),
                      ),
                    ),
                ],
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