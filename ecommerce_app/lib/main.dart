import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'footer.dart';
import 'login_screen.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final int? musteriId = prefs.getInt('musteriId');
  
  final bool girisYapmisMi = musteriId != null;

  runApp(MyApp(
    // 👇 DEĞİŞİKLİK BURADA: 
    // const Footer() yerine Footer(key: Footer.footerKey) yazmalısın.
    // const kelimesini silmeyi unutma!
    baslangicEkrani: girisYapmisMi ? Footer(key: Footer.footerKey) : const LoginScreen()
  ));
}

class MyApp extends StatelessWidget {
  final Widget baslangicEkrani; 

  const MyApp({super.key, required this.baslangicEkrani});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BookNest',
      theme: ThemeData(
        primaryColor: const Color(0xFF6200EE),
        useMaterial3: true,
      ),
      home: baslangicEkrani, 
    );
  }
}