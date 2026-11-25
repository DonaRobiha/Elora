import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../services/auth_service.dart';
import '../services/payment_service.dart';
import 'receipt_detail_screen.dart';

class PaymentPage extends StatefulWidget {
  final VoidCallback? onBack;

  const PaymentPage({super.key, this.onBack});
  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  List<Map<String, dynamic>> payments = [];
  bool loading = true;
  String? error;
  int selectedTab = 0;
  String studentName = 'Siswa ELORA';
  String studentId = '-';
  String institution = 'ELORA';
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profileFuture = _loadProfile();
    try {
      final d = await PaymentService.instance.myPayments();
      if (!mounted) return;
      setState(() {
        payments = d;
        loading = false;
      });
      final profile = await profileFuture;
      if (profile != null && mounted) {
        setState(() {
          studentName = (profile['nama'] ?? studentName).toString();
          studentId = (profile['student_id'] ?? studentId).toString();
          institution = (profile['institution'] ?? institution).toString();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString();
          loading = false;
        });
      }
    }
  }

  Future<Map<String, dynamic>?> _loadProfile() async {
    try {
      return await AuthService.instance.currentProfile();
    } catch (e) {
      debugPrint('PAYMENT PROFILE ERROR: $e');
      return null;
    }
  }

  double amount(dynamic v) => double.tryParse('$v') ?? 0;
  String rp(dynamic v) {
    final s = amount(v)
        .round()
        .toString()
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');
    return 'Rp $s';
  }

  bool paid(Map<String, dynamic> p) =>
      p['status'].toString().toLowerCase() == 'paid';
  String month(String period) {
    final parts = period.split('-');
    if (parts.length < 2) return period;
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final i = int.tryParse(parts[1]) ?? 1;
    return '${m[(i - 1).clamp(0, 11)]} ${parts[0]}';
  }

  @override
  Widget build(BuildContext c) {
    final total = payments
        .where((p) => !paid(p))
        .fold<double>(
          0,
          (a, p) => a + amount(p['amount']) - amount(p['paid_amount']),
        );
    return PopScope(
      canPop: widget.onBack == null,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) widget.onBack?.call();
      },
      child: Scaffold(
        backgroundColor: eloraBackground,
        body: SafeArea(
          child: Column(
            children: [
              _header(),
              Expanded(
                child: loading
                    ? Center(
                        child: CircularProgressIndicator(color: eloraPrimary),
                      )
                    : RefreshIndicator(
                        color: eloraPrimary,
                        onRefresh: _load,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
                          children: [
                            _summary(total),
                            const SizedBox(height: 14),
                            _tabs(),
                            const SizedBox(height: 12),
                            _history(),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  Widget _header() => Padding(
    padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
    child: Row(
      children: [
        IconButton(
          onPressed: widget.onBack != null || Navigator.of(context).canPop()
              ? _handleBack
              : null,
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 15,
            color: eloraDark,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rincian Pembayaran',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: eloraDark,
                ),
              ),
              Text(
                '$institution • Riwayat SPP',
                style: TextStyle(fontSize: 7, color: Colors.grey),
              ),
            ],
          ),
        ),
        Icon(Icons.download_outlined, size: 17, color: eloraDark),
        const SizedBox(width: 8),
        Icon(Icons.more_horiz_rounded, size: 18, color: eloraDark),
      ],
    ),
  );
  Widget _summary(double total) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: eloraPrimary,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'STATUS AKUN SISWA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .8,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF55D7B3),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                total == 0 ? 'Lunas • Bebas Tunggakan' : 'Perlu Pembayaran',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 7,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Total Tagihan Berjalan',
          style: TextStyle(color: Colors.white70, fontSize: 8),
        ),
        const SizedBox(height: 3),
        Text(
          rp(total),
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          total == 0
              ? '0 tagihan tertunda bulan ini'
              : 'Masih ada tagihan tertunda',
          style: TextStyle(color: Colors.white70, fontSize: 7),
        ),
        const SizedBox(height: 11),
        Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .11),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(child: _info('NAMA SISWA', studentName)),
              Expanded(child: _info('NISN', studentId)),
            ],
          ),
        ),
      ],
    ),
  );
  Widget _info(String a, String b) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        a,
        style: TextStyle(
          color: Colors.white54,
          fontSize: 6,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        b,
        style: TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.w900,
        ),
      ),
    ],
  );
  Widget _tabs() => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: eloraCard,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: const Color(0xFFE6ECEA)),
    ),
    child: Row(children: [_tab('Riwayat Bayar', 0), _tab('Tagihan Aktif', 1)]),
  );
  Widget _tab(String title, int tabIndex) {
    final active = selectedTab == tabIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = tabIndex),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: active ? eloraPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: active ? Colors.white : Colors.grey.shade500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _history() {
    if (error != null) {
      return Text(error!, style: TextStyle(color: Colors.red, fontSize: 9));
    }
    final visiblePayments = payments
        .where((payment) => selectedTab == 0 ? paid(payment) : !paid(payment))
        .toList();
    if (visiblePayments.isEmpty) return _empty();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          selectedTab == 0 ? 'Riwayat SPP Dibayar' : 'Tagihan Aktif',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: eloraDark,
          ),
        ),
        const SizedBox(height: 8),
        ...visiblePayments.map(_item),
      ],
    );
  }

  Widget _item(Map<String, dynamic> p) {
    final ok = paid(p);
    final period = month(p['period']?.toString() ?? '');
    return GestureDetector(
      onTap: ok
          ? () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReceiptDetailPage(
                  payment: {
                    ...p,
                    'nama': studentName,
                    'student_id': studentId,
                    'institution': institution,
                  },
                ),
              ),
            )
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: eloraCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5ECEA)),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: ok ? const Color(0xFFE6F8F1) : const Color(0xFFFFF2E5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                ok ? Icons.receipt_long_rounded : Icons.schedule_rounded,
                color: ok ? eloraPrimary : Colors.orange,
                size: 16,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${p['bill_type'] ?? 'SPP'} $period',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: eloraDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${ok ? 'Dibayar' : 'Belum dibayar'} • ${p['paid_at'] ?? '-'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 7, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rp(
                      ok
                          ? (p['paid_amount'] ?? p['amount'])
                          : (p['remaining_amount'] ?? p['amount']),
                    ),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: eloraDark,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: ok
                        ? const Color(0xFFE2F7EE)
                        : const Color(0xFFFFF0E1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    ok ? 'Lunas' : 'Belum Lunas',
                    style: TextStyle(
                      fontSize: 6,
                      fontWeight: FontWeight.w900,
                      color: ok ? eloraPrimary : Colors.orange,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  ok ? 'Buka Kwitansi' : 'Belum Lunas',
                  style: TextStyle(
                    fontSize: 7,
                    color: ok ? eloraPrimary : Colors.grey.shade500,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty() => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: eloraCard,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Center(
      child: Text(
        selectedTab == 0
            ? 'Belum ada pembayaran SPP yang tercatat.'
            : 'Belum ada tagihan aktif.',
        style: TextStyle(fontSize: 9, color: Colors.grey),
      ),
    ),
  );
}
