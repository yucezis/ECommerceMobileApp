import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'models/urun_model.dart';
import 'models/favorite_service.dart';
import 'login_screen.dart'; 

const Color kBookPaper = Color(0xFFFEFAE0);
const Color kBackgroundAccent = Color(0xFFFAEDCD);
const Color kDarkGreen = Color(0xFF283618);
const Color kOliveGreen = Color(0xFF606C38);
const Color kDarkCoffee = Color(0xFF211508);
const Color kSoftGrey = Color(0xFFF5F5F5);

class FavoriteButton extends StatefulWidget {
  final Urun urun;
  final Color? iconColor;
  final double size;

  const FavoriteButton({
    super.key, 
    required this.urun, 
    this.iconColor,
    this.size = 24,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _kontrolEt();
  }

  Future<bool> _oturumVarMi() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('musteriId'); 
  }

  void _girisYapUyarisiAc() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Giriş Yapmalısınız"),
        content: const Text("Ürünü favorilere eklemek için lütfen giriş yapın."),
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

  void _kontrolEt() async {
    if (!await _oturumVarMi()) {
      return;
    }

    bool durum = await FavoriServisi.favorideMi(widget.urun.urunId);
    if (mounted) {
      setState(() {
        _isFavorite = durum;
      });
    }
  }

  void _handleTap() async {
    bool girisYapti = await _oturumVarMi();
    
    if (!girisYapti) {
      _girisYapUyarisiAc(); 
      return; 
    }

    _toggleFavorite();
  }

  void _toggleFavorite() async {
    bool yeniDurum = await FavoriServisi.favoriDegistir(widget.urun);
    
    setState(() {
      _isFavorite = yeniDurum;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars(); 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            yeniDurum 
                ? "${widget.urun.urunAdi} favorilere eklendi!" 
                : "${widget.urun.urunAdi} favorilerden çıkarıldı.",
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: kDarkCoffee,
          duration: const Duration(milliseconds: 800),
          behavior: SnackBarBehavior.fixed, 
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _handleTap, 
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)
          ]
        ),
        child: Icon(
          _isFavorite ? Icons.favorite : Icons.favorite_border, 
          color: _isFavorite ? Colors.red : (widget.iconColor ?? Colors.grey),
          size: widget.size,
        ),
      ),
    );
  }
}