import 'dart:convert';
import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; 
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart'; 
import 'models/urun_model.dart'; 
import 'footer.dart';
import 'models/cart_service.dart';
import 'favorite_button.dart';
import 'login_screen.dart';

const Color kBookPaper = Color(0xFFFEFAE0);
const Color kBackgroundAccent = Color(0xFFFAEDCD);
const Color kDarkGreen = Color(0xFF283618);
const Color kOliveGreen = Color(0xFF606C38);
const Color kDarkCoffee = Color(0xFF211508);
const Color kSoftGrey = Color(0xFFF5F5F5);

class ProductDetailScreen extends StatefulWidget {
  final Urun urun;

  const ProductDetailScreen({super.key, required this.urun});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int adet = 1;
  
  List<dynamic> _yorumlar = [];
  bool _yorumlarYukleniyor = true;
  
  bool _isLoggedIn = false; 

  File? _secilenResim;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _yorumlariGetir();
    _oturumDurumunuKontrolEt(); 
  }

  String getBaseUrl() {
    return "http://10.180.131.237:5126/api"; 
  }

  Future<bool> _oturumVarMi() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('musteriId'); 
  }

  Future<void> _oturumDurumunuKontrolEt() async {
    bool girisYapti = await _oturumVarMi();
    if (mounted) {
      setState(() {
        _isLoggedIn = girisYapti;
      });
    }
  }

  void _girisYapUyarisiAc(String islemAdi) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Giriş Yapmalısınız"),
        content: Text("Bu ürünü $islemAdi için lütfen giriş yapın veya üye olun."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Vazgeç", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kDarkGreen),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const LoginScreen())
              );
            },
            child: const Text("Giriş Yap", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Future<void> _resimSec(StateSetter setModalState) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (image != null) {
      setModalState(() {
        _secilenResim = File(image.path);
      });
    }
  }

  String? _resmiBase64Yap() {
    if (_secilenResim == null) return null;
    List<int> imageBytes = _secilenResim!.readAsBytesSync();
    return base64Encode(imageBytes);
  }

  Future<void> _yorumlariGetir() async {
    try {
      final response = await http.get(Uri.parse("${getBaseUrl()}/Degerlendirmeler/Getir/${widget.urun.urunId}"));
      if (response.statusCode == 200) {
        setState(() {
          _yorumlar = jsonDecode(response.body);
          _yorumlarYukleniyor = false;
        });
      }
    } catch (e) {
      print("Yorum hatası: $e");
      setState(() => _yorumlarYukleniyor = false);
    }
  }

  Future<void> _yorumuKaydet(double puan, String yorum) async {
    if (!await _oturumVarMi()) {
      _girisYapUyarisiAc("değerlendirmek");
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final int? musteriId = prefs.getInt('musteriId');

    String? resimData = _resmiBase64Yap();

    try {
      final response = await http.post(
        Uri.parse("${getBaseUrl()}/Degerlendirmeler/Ekle"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "UrunId": widget.urun.urunId,
          "MusteriId": musteriId,
          "Puan": puan.toInt(),
          "Yorum": yorum,
          "ResimBase64": resimData
        }),
      );

      if (mounted) {
        if (response.statusCode == 200) {
          _yorumlariGetir(); 
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.body), backgroundColor: kDarkGreen));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: ${response.body}"), backgroundColor: Colors.red));
        }
      }
    } catch (e) {
      print(e);
    }
  }

  void _yorumYapPenceresiAc() {
    if (!_isLoggedIn) {
      _girisYapUyarisiAc("değerlendirmek");
      return;
    }

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
                  const Text("Değerlendir", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kDarkGreen)),
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
                      hintText: "Düşünceleriniz neler?",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      filled: true,
                      fillColor: kSoftGrey,
                    ),
                    maxLines: 3,
                  ),
                  
                  const SizedBox(height: 15),

                  Row(
                    children: [
                      InkWell(
                        onTap: () => _resimSec(setModalState),
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
                                width: 60, height: 60, fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              right: 0, top: 0,
                              child: InkWell(
                                onTap: () {
                                  setModalState(() => _secilenResim = null);
                                },
                                child: Container(
                                  decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                                ),
                              ),
                            )
                          ],
                        )
                    ],
                  ),
                  
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
                        _yorumuKaydet(secilenPuan, yorumController.text);
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

  void _resmiBuyut(String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10), 
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              InteractiveViewer(
                panEnabled: true, 
                boundaryMargin: const EdgeInsets.all(20),
                minScale: 0.5,
                maxScale: 4.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(imageUrl, fit: BoxFit.contain),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.6),
                  radius: 20,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final urun = widget.urun;
    bool indirimVar = urun.indirimliFiyat != null && urun.indirimliFiyat! > 0;

    return Scaffold(
      backgroundColor: kBackgroundAccent,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 5, 
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [kBackgroundAccent, kBookPaper],
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: -100, right: -50,
                        child: Container(
                          width: 350, height: 350,
                          decoration: BoxDecoration(color: kOliveGreen.withOpacity(0.08), shape: BoxShape.circle),
                        ),
                      ),
                      Hero(
                        tag: urun.urunGorsel,
                        child: Container(
                          height: 280, 
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(color: kDarkCoffee.withOpacity(0.3), offset: const Offset(12, 12), blurRadius: 25, spreadRadius: -5),
                              BoxShadow(color: kDarkCoffee.withOpacity(0.1), offset: const Offset(-4, -4), blurRadius: 10),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              urun.urunGorsel, fit: BoxFit.cover,
                              errorBuilder: (c, o, s) => Container(width: 180, color: kBookPaper, child: const Icon(Icons.book, size: 60, color: Colors.grey)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Expanded(flex: 5, child: SizedBox()), 
            ],
          ),

          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCircularButton(icon: Icons.arrow_back_ios_new, onTap: () => Footer.footerKey.currentState?.urundenCik()),
                    
                    _isLoggedIn
                        ? FavoriteButton(urun: widget.urun, size: 24)
                        : _buildCircularButton( 
                            icon: Icons.favorite_border,
                            color: Colors.grey, 
                            onTap: () => _girisYapUyarisiAc("favorilere eklemek"),
                          ),
                  ],
                ),
              ),
            ),
          ),
          
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.58,
              padding: const EdgeInsets.fromLTRB(25, 35, 25, 0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 40, offset: Offset(0, -10))],
              ),
              child: SingleChildScrollView( 
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      urun.urunAdi,
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: kDarkGreen, height: 1.1, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      urun.urunYazar.isNotEmpty ? urun.urunYazar : urun.urunMarka,
                      style: TextStyle(fontSize: 16, color: kOliveGreen.withOpacity(0.9), fontWeight: FontWeight.w500, fontStyle: FontStyle.italic),
                    ),
                    
                    if (indirimVar) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: const Color(0xFFBC4749).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: const Text("%15 İNDİRİM", style: TextStyle(color: Color(0xFFBC4749), fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ],

                    const SizedBox(height: 25),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildModernBadge(Icons.star_rounded, "4.8", Colors.amber),
                        _buildModernBadge(Icons.language, urun.urunDil ?? "-", Colors.blueGrey),
                        _buildModernBadge(Icons.auto_stories, "${urun.urunSayfa ?? '-'} Syf", kOliveGreen),
                      ],
                    ),
                    const SizedBox(height: 25),
                    
                    const Text("Kitap Hakkında", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kDarkCoffee)),
                    const SizedBox(height: 10),
                    Text(
                      urun.aciklama.isNotEmpty ? urun.aciklama : "Açıklama Yok!",
                      style: TextStyle(fontSize: 15, color: kDarkCoffee.withOpacity(0.65), height: 1.7),
                    ),

                    const SizedBox(height: 30),
                    const Divider(),
                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Değerlendirmeler", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kDarkCoffee)),
                        TextButton.icon(
                          onPressed: _yorumYapPenceresiAc, // Burada da kontrol var
                          icon: const Icon(Icons.rate_review_outlined, size: 18, color: kDarkGreen),
                          label: const Text("Yorum Yap", style: TextStyle(color: kDarkGreen, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                    
                    const SizedBox(height: 10),

                    _yorumlarYukleniyor 
                        ? const Center(child: CircularProgressIndicator(color: kDarkGreen))
                        : _yorumlar.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Center(child: Text("Henüz yorum yapılmamış. İlk yorumu sen yap!", style: TextStyle(color: Colors.grey[400]))),
                              )
                            : ListView.builder(
                                shrinkWrap: true, 
                                physics: const NeverScrollableScrollPhysics(), 
                                itemCount: _yorumlar.length,
                                itemBuilder: (context, index) {
                                  var yorum = _yorumlar[index];
                                  String? resimUrl = yorum['resimUrl']; 

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 15),
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: kSoftGrey,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(yorum['musteriAdi'], style: const TextStyle(fontWeight: FontWeight.bold, color: kDarkCoffee)),
                                            RatingBarIndicator(
                                              rating: (yorum['puan'] as int).toDouble(),
                                              itemBuilder: (context, index) => const Icon(Icons.star_rounded, color: Colors.amber),
                                              itemCount: 5,
                                              itemSize: 16.0,
                                              direction: Axis.horizontal,
                                            ),
                                          ],
                                        ),
                                        if (yorum['yorum'] != null && yorum['yorum'].toString().isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Text(yorum['yorum'], style: TextStyle(color: kDarkCoffee.withOpacity(0.8), fontSize: 14)),
                                        ],

                                        if (resimUrl != null && resimUrl.isNotEmpty) ...[
                                          const SizedBox(height: 10),
                                          GestureDetector(
                                            onTap: () {
                                              String fullUrl = "${getBaseUrl().replaceAll('/api', '')}$resimUrl";
                                              _resmiBuyut(fullUrl);
                                            },
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: Container(
                                                height: 120, 
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: Colors.grey.shade300),
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: Image.network(
                                                  "${getBaseUrl().replaceAll('/api', '')}$resimUrl",
                                                  fit: BoxFit.cover, 
                                                  errorBuilder: (c, o, s) => const SizedBox(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],

                                        const SizedBox(height: 5),
                                        Text(
                                          yorum['tarih'].toString().substring(0, 10), 
                                          style: TextStyle(fontSize: 10, color: Colors.grey[500])
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),

                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 20, left: 20, right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: kDarkGreen,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [BoxShadow(color: kDarkGreen.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(15)),
                    child: Row(
                      children: [
                        _buildQtyBtn(Icons.remove, () { if (adet > 1) setState(() => adet--); }),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text("$adet", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                        _buildQtyBtn(Icons.add, () => setState(() => adet++)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        bool girisYapti = await _oturumVarMi();
                        if (!girisYapti) {
                          _girisYapUyarisiAc("sepete eklemek");
                          return; 
                        }

                        await SepetServisi.sepeteEkle(urun, eklenecekAdet: adet);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$adet adet ${urun.urunAdi} sepete eklendi!"), backgroundColor: kDarkCoffee, duration: const Duration(milliseconds: 800)));
                        }
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("Sepete Ekle", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (indirimVar) Text("${urun.urunSatisFiyati}₺", style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.5), decoration: TextDecoration.lineThrough, decorationColor: Colors.white.withOpacity(0.5))),
                              const SizedBox(width: 8),
                              Text("${urun.indirimliFiyat ?? urun.urunSatisFiyati} ₺", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }

  Widget _buildCircularButton({required IconData icon, required VoidCallback onTap, Color color = kDarkGreen}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 45, width: 45,
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }

  Widget _buildModernBadge(IconData icon, String text, Color accentColor) {
    return Container(
      width: 90, padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: kSoftGrey, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Icon(icon, size: 22, color: accentColor),
          const SizedBox(height: 6),
          Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kDarkCoffee)),
        ],
      ),
    );
  }
}