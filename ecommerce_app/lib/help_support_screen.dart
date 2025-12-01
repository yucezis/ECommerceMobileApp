import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart'; // Paketi eklersen bunu aç
import 'chat_screen.dart';

const Color kBookPaper = Color(0xFFFEFAE0);
const Color kDarkGreen = Color(0xFF283618);
const Color kOliveGreen = Color(0xFF606C38);
const Color kDarkCoffee = Color(0xFF211508);
const Color kSoftGreen = Color(0xFFE9EDC9); 
class HelpSupportScreen extends StatefulWidget {

  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  final List<Map<String, String>> _allFaqList = [
    {
      "question": "Siparişim ne zaman kargoya verilir?",
      "answer": "Siparişleriniz genellikle 24 saat içinde hazırlanıp kargoya teslim edilir. Kampanya dönemlerinde bu süre 48 saati bulabilir."
    },
    {
      "question": "İade ve değişim koşulları nelerdir?",
      "answer": "Satın aldığınız kitapları, teslimat tarihinden itibaren 14 gün içinde hasarsız olması koşuluyla iade edebilirsiniz."
    },
    {
      "question": "Hangi ödeme yöntemleri geçerli?",
      "answer": "Kredi kartı, banka kartı ve kapıda ödeme seçeneklerimiz mevcuttur. Tüm kart bilgileriniz 3D Secure ile korunmaktadır."
    },
    {
      "question": "Kargo ücreti ne kadar?",
      "answer": "250 TL ve üzeri alışverişlerinizde kargo ücretsizdir. Altındaki siparişler için sabit kargo ücreti uygulanır."
    },
    {
      "question": "Hasarlı ürün gelirse ne yapmalıyım?",
      "answer": "Kargo paketinde hasar varsa tutanak tutturunuz. Ürün hasarlıysa fotoğrafını çekip destek@booknest.com adresine gönderebilirsiniz."
    },
    {
      "question": "Şifremi unuttum, ne yapmalıyım?",
      "answer": "Giriş ekranındaki 'Şifremi Unuttum' bağlantısına tıklayarak e-posta adresinize sıfırlama bağlantısı gönderebilirsiniz."
    },
  ];

  List<Map<String, String>> _filteredFaqList = [];

  @override
  void initState() {
    super.initState();
    _filteredFaqList = _allFaqList; 
  }

  void _filterSearchResults(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredFaqList = _allFaqList;
      });
      return;
    }

    setState(() {
      _filteredFaqList = _allFaqList
          .where((item) => item["question"]!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // URL Açma Fonksiyonu (Paket eklenirse burası aktif edilir)
  /*
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    await launchUrl(launchUri);
  }
  
  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(scheme: 'mailto', path: email);
    await launchUrl(launchUri);
  }
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBookPaper,
      appBar: AppBar(
        title: const Text("Yardım ve Destek"),
        backgroundColor: kDarkGreen,
        foregroundColor: kBookPaper,
        centerTitle: true,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const ChatScreen()),
  );
},
        backgroundColor: kDarkGreen,
        icon: const Icon(Icons.chat_bubble_outline, color: kBookPaper),
        label: const Text("Canlı Destek", style: TextStyle(color: kBookPaper, fontWeight: FontWeight.bold)),
      ),
      
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30, top: 10),
            decoration: const BoxDecoration(
              color: kDarkGreen,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Column(
              children: [
                const Text(
                  "Size nasıl yardımcı olabiliriz?",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kBookPaper),
                ),
                const SizedBox(height: 20),
                
                TextField(
                  controller: _searchController,
                  onChanged: _filterSearchResults,
                  style: const TextStyle(color: kDarkGreen),
                  decoration: InputDecoration(
                    hintText: "Sorunuzu arayın (Örn: Kargo, İade)",
                    hintStyle: TextStyle(color: kDarkGreen.withOpacity(0.6)),
                    prefixIcon: const Icon(Icons.search, color: kDarkGreen),
                    filled: true,
                    fillColor: kBookPaper,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _buildContactButton(
                  icon: Icons.phone_in_talk,
                  label: "Bizi Arayın",
                  color: Colors.blue.shade800,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Arama ekranına yönlendiriliyor...")));
                  },
                ),
                const SizedBox(width: 15),
                _buildContactButton(
                  icon: Icons.mail_outline,
                  label: "E-Posta",
                  color: Colors.orange.shade800,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mail uygulaması açılıyor...")));
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: _filteredFaqList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 60, color: Colors.grey.withOpacity(0.5)),
                        const SizedBox(height: 10),
                        const Text("Sonuç bulunamadı", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: _filteredFaqList.length,
                    itemBuilder: (context, index) {
                      return _buildFaqItem(_filteredFaqList[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(Map<String, String> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          backgroundColor: kSoftGreen.withOpacity(0.3), 
          collapsedBackgroundColor: Colors.white,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          leading: const CircleAvatar(
            backgroundColor: kBookPaper,
            radius: 18,
            child: Icon(Icons.question_mark_rounded, color: kOliveGreen, size: 20),
          ),
          title: Text(
            item["question"]!,
            style: const TextStyle(fontWeight: FontWeight.bold, color: kDarkGreen, fontSize: 15),
          ),
          children: [
            Text(
              item["answer"]!,
              style: TextStyle(color: Colors.grey[800], height: 1.5, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return Expanded(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(height: 10),
                Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}