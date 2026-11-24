import 'package:flutter/material.dart';

import 'package:elora_school/theme/colors.dart';

class EloraAiPage extends StatefulWidget {
  const EloraAiPage({super.key});

  @override
  State<EloraAiPage> createState() => _EloraAiPageState();
}

class _EloraAiPageState extends State<EloraAiPage> {
  final TextEditingController _controller = TextEditingController();
  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      text: 'Halo! Saya ELORA AI. Saya bisa membantu menjelaskan presensi, SPP/tagihan, profil, dan jelajahi institusi.',
      isUser: false,
    ),
  ];

  final List<String> _quickPrompts = const [
    'Riwayat presensi saya',
    'Status tagihan SPP',
    'Cara membayar SPP',
    'Cari institusi terdekat',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send([String? prompt]) {
    final text = (prompt ?? _controller.text).trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _messages.add(_ChatMessage(text: _answer(text), isUser: false));
    });
    _controller.clear();
  }

  String _answer(String question) {
    final text = question.toLowerCase();
    if (text.contains('presensi') ||
        text.contains('hadir') ||
        text.contains('absen')) {
      return 'Untuk mengecek presensi, buka menu Presensi pada beranda atau gunakan tombol QR Presensi. Pastikan lokasi dan kamera diperbolehkan saat memindai.';
    }
    if (text.contains('tagihan') ||
        text.contains('spp') ||
        text.contains('bayar')) {
      return 'Status SPP tersedia di kartu Status SPP pada profil dan halaman Rincian Pembayaran. Gunakan tab Riwayat Bayar untuk kuitansi atau Tagihan Aktif untuk sisa pembayaran.';
    }
    if (text.contains('institusi') ||
        text.contains('sekolah') ||
        text.contains('lokasi')) {
      return 'Buka tab Jelajahi untuk melihat institusi berdasarkan lokasi perangkat. Pilih hasil institusi untuk melihat posisi dan rute menuju lokasi.';
    }
    if (text.contains('profil') ||
        text.contains('wali') ||
        text.contains('siswa')) {
      return 'Data siswa dan wali dapat dilihat pada halaman Profil. Pilih Data Akademik untuk melihat institusi dan status siswa.';
    }
    return 'Saya dapat membantu pertanyaan seputar presensi, SPP/tagihan, data siswa, dan institusi ELORA. Silakan pilih salah satu pertanyaan cepat di bawah.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: eloraBackground,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(18, 10, 18, 8),
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: const BoxDecoration(
                color: eloraPrimary,
                borderRadius: BorderRadius.all(Radius.circular(18)),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      color: eloraPrimary,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ELORA AI',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Asisten siswa ELORA',
                          style: TextStyle(color: Colors.white70, fontSize: 8),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.verified_rounded, color: Colors.white, size: 18),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return Align(
                    alignment: message.isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(context).width * 0.78,
                      ),
                      margin: const EdgeInsets.only(bottom: 9),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: message.isUser ? eloraPrimary : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(message.isUser ? 16 : 4),
                          bottomRight: Radius.circular(message.isUser ? 4 : 16),
                        ),
                        border: message.isUser
                            ? null
                            : Border.all(color: const Color(0xFFE1E9E7)),
                      ),
                      child: Text(
                        message.text,
                        style: TextStyle(
                          color: message.isUser ? Colors.white : eloraDark,
                          fontSize: 11,
                          height: 1.45,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              color: eloraBackground,
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 8),
              child: Column(
                children: [
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _quickPrompts.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 7),
                      itemBuilder: (context, index) => ActionChip(
                        onPressed: () => _send(_quickPrompts[index]),
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFFD9E7E4)),
                        label: Text(
                          _quickPrompts[index],
                          style: const TextStyle(
                            color: eloraPrimary,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _send(),
                          decoration: const InputDecoration(
                            hintText: 'Tulis pertanyaan...',
                            prefixIcon: Icon(Icons.chat_bubble_outline_rounded),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: FloatingActionButton(
                          onPressed: () => _send(),
                          backgroundColor: eloraPrimary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          child: const Icon(Icons.send_rounded, size: 19),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;

  const _ChatMessage({required this.text, required this.isUser});
}
