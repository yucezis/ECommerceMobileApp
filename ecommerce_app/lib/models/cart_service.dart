import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'urun_model.dart';

class SepetServisi {
  
  static Future<void> sepeteEkle(Urun urun, {int eklenecekAdet = 1}) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> sepetListesi = prefs.getStringList('sepet') ?? [];

    // Mevcut listeyi Urun objelerine çevir
    List<Urun> mevcutUrunler = sepetListesi
        .map((item) => Urun.fromJson(jsonDecode(item)))
        .toList();

    // Ürün zaten sepette var mı kontrol et
    int index = mevcutUrunler.indexWhere((element) => element.urunId == urun.urunId);

    if (index != -1) {
      // VARSA: Mevcut adedin üzerine ekle
      mevcutUrunler[index].sepetAdedi += eklenecekAdet;
    } else {
      // YOKSA: Yeni ürün olarak ekle ve adedini ayarla
      urun.sepetAdedi = eklenecekAdet;
      mevcutUrunler.add(urun);
    }

    // Listeyi tekrar JSON string'e çevirip kaydet
    List<String> yeniListeString = mevcutUrunler
        .map((item) => jsonEncode(item.toJson()))
        .toList();

    await prefs.setStringList('sepet', yeniListeString);
  }

  static Future<List<Urun>> sepetiGetir() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> sepetListesi = prefs.getStringList('sepet') ?? [];

    return sepetListesi
        .map((item) => Urun.fromJson(jsonDecode(item)))
        .toList();
  }

  static Future<void> adetAzalt(int urunId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> sepetListesi = prefs.getStringList('sepet') ?? [];

    List<Urun> mevcutUrunler = sepetListesi
        .map((item) => Urun.fromJson(jsonDecode(item)))
        .toList();

    int index = mevcutUrunler.indexWhere((element) => element.urunId == urunId);

    if (index != -1) {
      if (mevcutUrunler[index].sepetAdedi > 1) {
        mevcutUrunler[index].sepetAdedi--; 
      } else {
        mevcutUrunler.removeAt(index); 
      }
    }

    List<String> yeniListeString = mevcutUrunler
        .map((item) => jsonEncode(item.toJson()))
        .toList();

    await prefs.setStringList('sepet', yeniListeString);
  }

  static Future<void> sepettenSil(int urunId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> sepetListesi = prefs.getStringList('sepet') ?? [];

    List<Urun> mevcutUrunler = sepetListesi
        .map((item) => Urun.fromJson(jsonDecode(item)))
        .toList();

    mevcutUrunler.removeWhere((item) => item.urunId == urunId);

    List<String> yeniListeString = mevcutUrunler
        .map((item) => jsonEncode(item.toJson()))
        .toList();

    await prefs.setStringList('sepet', yeniListeString);
  }

  static Future<void> sepetiBosalt() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('sepet');
  }
}