import 'package:flutter/material.dart';

import 'package:elora_school/theme/colors.dart';

import '../services/elora_ai_service.dart';

class EloraAiPage extends StatefulWidget {
  const EloraAiPage({super.key});

  @override
  State<EloraAiPage> createState() => _EloraAiPageState();
}

class _EloraAiPageState extends State<EloraAiPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      text: 'Halo! Saya ELORA AI. Tanyakan apa saja, saya akan berusaha membantu. Saya juga bisa menjelaskan informasi ELORA.',
      isUser: false,
    ),
  ];

  final List<String> _quickPrompts = const [
    'Riwayat presensi saya',
    'Cara scan QR presensi?',
    'Kenapa presensi belum tercatat?',
    'Status tagihan SPP',
    'Cara membayar SPP?',
    'Bagaimana melihat kuitansi?',
    'Data profil siswa',
    'Cara mengubah data profil?',
    'Cari institusi terdekat',
    'Bagaimana melihat rute institusi?',
    'Bantuan akun ELORA',
    'Cara menghubungi admin?',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send([String? prompt]) async {
    final text = (prompt ?? _controller.text).trim();
    if (text.isEmpty || _isTyping) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _messages.add(
        const _ChatMessage(
          text: 'ELORA AI sedang mengetik...',
          isUser: false,
          isTyping: true,
        ),
      );
      _isTyping = true;
    });
    _controller.clear();
    final responseIndex = _messages.length - 1;
    _scrollToBottom();
    final conversation = _messages
        .skip(1)
        .where((message) => !message.isTyping)
        .map(
          (message) => {
            'role': message.isUser ? 'user' : 'assistant',
            'content': message.text,
          },
        )
        .toList(growable: false);

    try {
      final answer = await EloraAiService.instance.reply(conversation);
      if (!mounted) return;
      setState(() {
        _messages[responseIndex] = _ChatMessage(text: answer, isUser: false);
        _isTyping = false;
      });
    } catch (error) {
      debugPrint('ELORA AI ERROR: $error');
      if (!mounted) return;
      setState(() {
        _messages[responseIndex] = const _ChatMessage(
          text: 'Maaf, ELORA AI belum dapat menjawab. Coba lagi sebentar, atau periksa koneksi dan konfigurasi Gemini.',
          isUser: false,
        );
        _isTyping = false;
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
      );
    });
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
              decoration: BoxDecoration(
                color: eloraPrimary,
                borderRadius: BorderRadius.all(Radius.circular(18)),
              ),
              child: Row(
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
                          'Asisten AI serbaguna',
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
                controller: _scrollController,
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
                        color: message.isUser ? eloraPrimary : eloraCard,
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
                        message.isTyping
                            ? 'ELORA AI sedang mengetik...'
                            : message.text,
                        style: TextStyle(
                          color: message.isUser ? Colors.white : eloraDark,
                          fontSize: 11,
                          height: 1.45,
                          fontStyle: message.isTyping
                              ? FontStyle.italic
                              : FontStyle.normal,
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
                        onPressed: _isTyping
                            ? null
                            : () => _send(_quickPrompts[index]),
                        backgroundColor: eloraCard,
                        side: const BorderSide(color: Color(0xFFD9E7E4)),
                        label: Text(
                          _quickPrompts[index],
                          style: TextStyle(
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
                          enabled: !_isTyping,
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
                          onPressed: _isTyping ? null : () => _send(),
                          backgroundColor: eloraPrimary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          child: Icon(Icons.send_rounded, size: 19),
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
  final bool isTyping;

  const _ChatMessage({
    required this.text,
    required this.isUser,
    this.isTyping = false,
  });
}
