import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const Color kDarkGreen = Color(0xFF283618);
const Color kBookPaper = Color(0xFFFEFAE0);
const Color kOliveGreen = Color(0xFF606C38);

class AdminChatScreen extends StatefulWidget {
  const AdminChatScreen({super.key});

  @override
  State<AdminChatScreen> createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<dynamic> _mesajlar = [];
  Timer? _timer;
  int? _musteriId;

  @override
  void initState() {
    super.initState();
    _baslat();
  }

  @override
  void dispose() {
    _timer?.cancel(); 
    super.dispose();
  }

  String getBaseUrl() {
    return "http://10.180.131.237:5126/api"; 
  }

  Future<void> _baslat() async {
    final prefs = await SharedPreferences.getInstance();
    _musteriId = prefs.getInt('musteriId');
    
    if (_musteriId != null) {
      _mesajlariCek(); 

      _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
        _mesajlariCek();
      });
    }
  }

  Future<void> _mesajlariCek() async {
    if (_musteriId == null) return;

    try {
      final response = await http.get(Uri.parse("${getBaseUrl()}/Mesajlar/Getir/$_musteriId"));
      if (response.statusCode == 200) {
        List<dynamic> yeniListe = jsonDecode(response.body);
        
        if (yeniListe.length != _mesajlar.length) {
          setState(() {
            _mesajlar = yeniListe;
          });
          _scrollToBottom();
        }
      }
    } catch (e) {
      print("Mesaj çekme hatası: $e");
    }
  }

  Future<void> _mesajGonder() async {
    if (_controller.text.isEmpty || _musteriId == null) return;

    String mesajMetni = _controller.text;
    _controller.clear();

    setState(() {
      _mesajlar.add({
        "icerik": mesajMetni,
        "gonderenAdminMi": false, 
        "tarih": DateTime.now().toString()
      });
    });
    _scrollToBottom();

    try {
      await http.post(
        Uri.parse("${getBaseUrl()}/Mesajlar/Gonder"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "MusteriId": _musteriId,
          "Icerik": mesajMetni,
          "GonderenAdminMi": false 
        }),
      );
    } catch (e) {
      print("Gönderme hatası: $e");
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
        title: const Text("Müşteri Temsilcisi"),
        backgroundColor: kDarkGreen,
        foregroundColor: kBookPaper,
      ),
      body: Column(
        children: [
          Expanded(
            child: _mesajlar.isEmpty
                ? const Center(child: Text("Müşteri temsilcilerimiz 09:00-17:00 arasında çalışmaktadır!"))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _mesajlar.length,
                    itemBuilder: (context, index) {
                      final msg = _mesajlar[index];
                      final bool isAdmin = msg['gonderenAdminMi'] == true;
                      
                      return Align(
                        alignment: isAdmin ? Alignment.centerLeft : Alignment.centerRight,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          padding: const EdgeInsets.all(12),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                          decoration: BoxDecoration(
                            color: isAdmin ? Colors.white : kOliveGreen,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(15),
                              topRight: const Radius.circular(15),
                              bottomLeft: isAdmin ? Radius.zero : const Radius.circular(15),
                              bottomRight: isAdmin ? const Radius.circular(15) : Radius.zero,
                            ),
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))]
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg['icerik'] ?? "",
                                style: TextStyle(color: isAdmin ? Colors.black87 : Colors.white, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isAdmin ? "Temsilci" : "Siz",
                                style: TextStyle(color: isAdmin ? Colors.grey : Colors.white70, fontSize: 10),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
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
                      hintText: "Mesajınızı yazın...",
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
                    onPressed: _mesajGonder,
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