import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'urun_model.dart';

class FavoriServisi {
  
  // Favori Durumunu Değiştir (Ekle/Çıkar)
  static Future<bool> favoriDegistir(Urun urun) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favoriListesi = prefs.getStringList('favoriler') ?? [];

    // Ürün zaten favoride mi?
    String? bulunanUrunJson;
    for (var item in favoriListesi) {
      Map<String, dynamic> jsonUrun = jsonDecode(item);
      if (jsonUrun['urunId'] == urun.urunId) {
        bulunanUrunJson = item;
        break;
      }
    }

    if (bulunanUrunJson != null) {
      // Varsa Çıkar (Toggle mantığı)
      favoriListesi.remove(bulunanUrunJson);
      await prefs.setStringList('favoriler', favoriListesi);
      return false; // Artık favoride değil
    } else {
      // Yoksa Ekle
      favoriListesi.add(jsonEncode(urun.toJson()));
      await prefs.setStringList('favoriler', favoriListesi);
      return true; // Artık favoride
    }
  }

  // Bir ürünün favoride olup olmadığını kontrol et
  static Future<bool> favorideMi(int urunId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favoriListesi = prefs.getStringList('favoriler') ?? [];

    for (var item in favoriListesi) {
      Map<String, dynamic> jsonUrun = jsonDecode(item);
      if (jsonUrun['urunId'] == urunId) {
        return true;
      }
    }
    return false;
  }

  // Tüm Favorileri Getir
  static Future<List<Urun>> favorileriGetir() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favoriListesi = prefs.getStringList('favoriler') ?? [];

    return favoriListesi
        .map((item) => Urun.fromJson(jsonDecode(item)))
        .toList();
  }
}