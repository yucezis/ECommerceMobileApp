import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'urun_model.dart';

class SepetServisi {
  
  // Sepete Ürün Ekle
  static Future<void> sepeteEkle(Urun urun) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> sepetListesi = prefs.getStringList('sepet') ?? [];

    bool varMi = false;
    for (var item in sepetListesi) {
      Map<String, dynamic> jsonUrun = jsonDecode(item);
      if (jsonUrun['urunId'] == urun.urunId) {
        varMi = true;
        break;
      }
    }

    if (!varMi) {
      sepetListesi.add(jsonEncode(urun.toJson()));
      await prefs.setStringList('sepet', sepetListesi);
    }
  }

  static Future<List<Urun>> sepetiGetir() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> sepetListesi = prefs.getStringList('sepet') ?? [];

    return sepetListesi
        .map((item) => Urun.fromJson(jsonDecode(item)))
        .toList();
  }

  // Sepetten Ürün Sil
  static Future<void> sepettenSil(int urunId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> sepetListesi = prefs.getStringList('sepet') ?? [];

    sepetListesi.removeWhere((item) {
      Map<String, dynamic> jsonUrun = jsonDecode(item);
      return jsonUrun['urunId'] == urunId;
    });

    await prefs.setStringList('sepet', sepetListesi);
  }

  // Sepeti Temizle (Satın alımdan sonra)
  static Future<void> sepetiBosalt() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('sepet');
  }
}