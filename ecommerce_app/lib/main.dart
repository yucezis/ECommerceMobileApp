import 'package:flutter/material.dart';
import 'footer.dart';void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Books',
      theme: ThemeData(
        primaryColor: const Color(0xFF6200EE),
        useMaterial3: true,
      ),
      
      home: const Footer(), 
    );
  }
}