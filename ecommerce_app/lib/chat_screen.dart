import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const Color kDarkGreen = Color(0xFF283618);
const Color kBookPaper = Color(0xFFFEFAE0);
const Color kOliveGreen = Color(0xFF606C38);

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _mesajlar = []; 
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  String getBaseUrl() {
    return "http://10.180.131.237:5126/api"; 
  }

  Future<void> _mesajGonder() async {
    if (_controller.text.isEmpty) return;

    String kullaniciMesaji = _controller.text;
    
    setState(() {
      _mesajlar.add({"rol": "user", "mesaj": kullaniciMesaji});
      _isLoading = true;
    });
    
    _controller.clear();
    _scrollToBottom();

    try {
      final prefs = await SharedPreferences.getInstance();
      final int musteriId = prefs.getInt('musteriId') ?? 0; 

      final response = await http.post(
        Uri.parse("${getBaseUrl()}/Chat/Sor"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "Mesaj": kullaniciMesaji,
          "MusteriId": musteriId 
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          _mesajlar.add({"rol": "bot", "mesaj": data['cevap']});
        });
      } else {
        setState(() {
          _mesajlar.add({"rol": "bot", "mesaj": "Bağlantı hatası: ${response.statusCode} - ${response.body}"});
        });
      }
    } catch (e) {
      setState(() {
        _mesajlar.add({"rol": "bot", "mesaj": "Hata oluştu: $e"});
      });
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBookPaper,
      appBar: AppBar(
        title: const Text("BookBot Asistan"),
        backgroundColor: kDarkGreen,
        foregroundColor: kBookPaper,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _mesajlar.length,
              itemBuilder: (context, index) {
                final msg = _mesajlar[index];
                final bool isUser = msg['rol'] == 'user';
                
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? kOliveGreen : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(15),
                        topRight: const Radius.circular(15),
                        bottomLeft: isUser ? const Radius.circular(15) : Radius.zero,
                        bottomRight: isUser ? Radius.zero : const Radius.circular(15),
                      ),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))]
                    ),
                    child: Text(
                      msg['mesaj']!,
                      style: TextStyle(color: isUser ? Colors.white : Colors.black87),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(color: kOliveGreen),
            ),
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Bir şeyler sorun...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: kDarkGreen,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: kBookPaper),
                    onPressed: _isLoading ? null : _mesajGonder,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}