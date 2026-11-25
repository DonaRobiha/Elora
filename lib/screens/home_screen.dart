import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/auth_service.dart';
import '../services/payment_service.dart';
import '../services/notification_data_service.dart';
import '../controllers/notification_controller.dart';
import '../theme/colors.dart';
import 'explore_screen.dart';
import 'profile_screen.dart';
import 'payment_screen.dart';
import 'time_screen.dart';
import 'currency_screen.dart';
import 'tic_tac_toe_screen.dart';
import 'attendance_scan_screen.dart';
import 'settings_screen.dart';
import 'notification_screen.dart';
import 'elora_ai_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;
  String name = 'Dona';
  String institution = 'SMP ELORA Bantul';
  String nis = '124240026';
  String? avatarUrl;
  String unpaid = '—';
  String nextDueDate = 'Memuat...';
  int activeBills = 0;
  List<Map<String, dynamic>> notices = [];
  String? accountError;
  String? notificationError;
  bool loading = true;
  @override
  void initState() {
    super.initState();
    Get.put(NotificationController(), permanent: true);
    _load();
  }

  Future<void> _load() async {
    try {
      final p = await AuthService.instance.currentProfile();
      final pays = await PaymentService.instance.myPayments();
      List<Map<String, dynamic>> ns = [];
      String? fetchedNotificationError;
      try {
        ns = await NotificationDataService.instance.list();
      } catch (e) {
        debugPrint('HOME NOTIFICATION ERROR: $e');
        fetchedNotificationError = e.toString();
      }

      double total = 0;
      final openPayments = <Map<String, dynamic>>[];
      for (final x in pays) {
        if (x['status'].toString().toLowerCase() != 'paid') {
          final a = double.tryParse('${x['amount']}') ?? 0;
          final b = double.tryParse('${x['paid_amount'] ?? 0}') ?? 0;
          total += (a - b).clamp(0, a).toDouble();
          openPayments.add(x);
        }
      }
      openPayments.sort((a, b) {
        final aDate = DateTime.tryParse(a['due_date']?.toString() ?? '');
        final bDate = DateTime.tryParse(b['due_date']?.toString() ?? '');
        if (aDate == null) return bDate == null ? 0 : 1;
        if (bDate == null) return -1;
        return aDate.compareTo(bDate);
      });

      final accountNotices = ns.where((n) => n['target'] == 'user').toList();
      final paymentNotices = pays.take(2).map((payment) {
        final period = _period(payment['period']?.toString() ?? '');
        final isPaid = payment['status'].toString().toLowerCase() == 'paid';
        final paidAmount =
            double.tryParse('${payment['paid_amount'] ?? 0}') ?? 0;
        final remaining =
            double.tryParse('${payment['remaining_amount'] ?? 0}') ?? 0;
        return <String, dynamic>{
          'title': '${payment['bill_type'] ?? 'SPP'} $period',
          'message': isPaid
              ? 'Pembayaran ${_rp(paidAmount)} sudah tercatat di akunmu.'
              : paidAmount > 0
              ? 'Pembayaran sebagian tercatat. Sisa tagihan ${_rp(remaining)}.'
              : 'Tagihan ini belum dibayar. Buka SPP/Tagihan untuk rinciannya.',
          'type': 'payment',
          'created_at':
              payment['paid_at'] ??
              payment['updated_at'] ??
              payment['created_at'],
        };
      });
      final accountActivity = [...accountNotices, ...paymentNotices];
      accountActivity.sort((a, b) {
        final aDate = DateTime.tryParse(a['created_at']?.toString() ?? '');
        final bDate = DateTime.tryParse(b['created_at']?.toString() ?? '');
        if (aDate == null) return bDate == null ? 0 : 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });

      if (!mounted) return;
      setState(() {
        name = (p['nama'] ?? 'Dona').toString().split(' ').first;
        institution = (p['institution'] ?? 'SMP ELORA Bantul').toString();
        nis = (p['student_id'] ?? '124240026').toString();
        avatarUrl = p['avatar_url']?.toString();
        unpaid = _rp(total);
        activeBills = openPayments.length;
        nextDueDate = openPayments.isEmpty
            ? 'Tidak ada tagihan aktif'
            : _formatDate(openPayments.first['due_date']);
        notices = accountActivity.take(2).toList();
        accountError = null;
        notificationError = fetchedNotificationError;
        loading = false;
      });
    } catch (e) {
      debugPrint('HOME DATA ERROR: $e');
      if (mounted) {
        setState(() {
          loading = false;
          accountError = e.toString();
          unpaid = '—';
          nextDueDate = 'Tidak tersedia';
          activeBills = 0;
        });
      }
    }
  }

  String _period(String value) {
    final parts = value.split('-');
    if (parts.length != 2) return value;
    const months = [
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
    final month = int.tryParse(parts[1]);
    if (month == null || month < 1 || month > 12) return value;
    return '${months[month - 1]} ${parts[0]}';
  }

  String _formatDate(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '');
    if (date == null) return 'Tanggal belum tersedia';
    const months = [
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _rp(double n) {
    final s = n.round().toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => '.',
    );
    return 'Rp $s';
  }

  void open(Widget p) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => p));
  @override
  Widget build(BuildContext c) {
    final pages = [
      _home(),
      const ExplorePage(),
      const EloraAiPage(),
      PaymentPage(onBack: () => setState(() => index = 0)),
      const ProfilePage(),
    ];
    return Scaffold(
      backgroundColor: eloraBackground,
      body: SafeArea(
        child: IndexedStack(index: index, children: pages),
      ),
      bottomNavigationBar: _nav(),
    );
  }

  Widget _nav() => Container(
    margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: eloraCard,
      borderRadius: BorderRadius.circular(28),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .12),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Row(
      children: [
        _navItem(0, Icons.grid_view_rounded, 'Beranda'),
        _navItem(1, Icons.map_outlined, 'Jelajahi'),
        _navItem(2, Icons.auto_awesome_rounded, 'ELORA AI'),
        _navItem(3, Icons.receipt_long_outlined, 'Riwayat SPP'),
        _navItem(4, Icons.person_outline_rounded, 'Profil'),
      ],
    ),
  );
  Widget _navItem(int i, IconData icon, String label) => Expanded(
    child: Tooltip(
      message: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => setState(() => index = i),
        child: SizedBox(
          height: 39,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: index == i ? eloraPrimary : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 17,
                color: index == i ? Colors.white : Colors.grey.shade500,
              ),
            ),
          ),
        ),
      ),
    ),
  );
  Widget _home() => RefreshIndicator(
    color: eloraPrimary,
    onRefresh: _load,
    child: ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        _top(),
        const SizedBox(height: 12),
        _statusCard(),
        const SizedBox(height: 12),
        _quick(),
        const SizedBox(height: 18),
        _news(),
      ],
    ),
  );
  Widget _top() => Container(
    padding: const EdgeInsets.fromLTRB(14, 13, 12, 15),
    decoration: BoxDecoration(
      color: eloraPrimary,
      borderRadius: BorderRadius.circular(19),
    ),
    child: Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .14),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.school_rounded, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ELORA CAMPUS • SISWA',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 7,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              Text(
                'Beranda',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        _circle(
          Icons.notifications_none_rounded,
          () => open(const NotificationPage()),
          showUnread: true,
        ),
        const SizedBox(width: 6),
        _circle(Icons.person_outline_rounded, () => setState(() => index = 4)),
      ],
    ),
  );
  Widget _circle(IconData i, VoidCallback f, {bool showUnread = false}) =>
      GestureDetector(
        onTap: f,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .13),
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(i, color: Colors.white, size: 16),
              if (showUnread)
                Positioned(
                  top: 5,
                  right: 5,
                  child: Obx(
                    () =>
                        Get.find<NotificationController>()
                            .hasUnreadNotification
                            .value
                        ? Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Color(0xFFFF6B6B),
                              shape: BoxShape.circle,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
            ],
          ),
        ),
      );
  Widget _statusCard() => Container(
    padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
    decoration: BoxDecoration(
      color: eloraCard,
      borderRadius: BorderRadius.circular(19),
      border: Border.all(color: const Color(0xFFE2EAE8)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .035),
          blurRadius: 14,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4FA),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${institution.toUpperCase()} • SISWA',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: eloraPrimary,
              fontSize: 7,
              fontWeight: FontWeight.w800,
              letterSpacing: .4,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                '${_greet()}, $name 👋',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: eloraDark,
                ),
              ),
            ),
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFE5F3F1),
              backgroundImage:
                  avatarUrl != null && avatarUrl!.startsWith('http')
                  ? NetworkImage(avatarUrl!)
                  : null,
              child: avatarUrl == null || !avatarUrl!.startsWith('http')
                  ? Icon(Icons.person_rounded, color: eloraPrimary, size: 18)
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          'NISN $nis • Status siswa aktif',
          style: TextStyle(fontSize: 8, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 11),
        _homeChoices(),
        const SizedBox(height: 13),
        Row(
          children: [
            Expanded(
              child: Text(
                'Total Tagihan Berjalan',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: eloraDark,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: loading || accountError != null
                    ? const Color(0xFFE9ECEF)
                    : unpaid == 'Rp 0'
                    ? const Color(0xFFE1F8EF)
                    : const Color(0xFFFFF1DF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                loading
                    ? 'MEMUAT'
                    : accountError != null
                    ? 'TIDAK TERSEDIA'
                    : unpaid == 'Rp 0'
                    ? 'LUNAS'
                    : 'PERLU DIBAYAR',
                style: TextStyle(
                  fontSize: 7,
                  color: loading || accountError != null
                      ? Colors.grey.shade700
                      : unpaid == 'Rp 0'
                      ? eloraPrimary
                      : Colors.deepOrange,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          loading
              ? 'Memuat...'
              : accountError == null
              ? unpaid
              : '—',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            color: eloraDark,
          ),
        ),
        Text(
          loading
              ? 'Memuat ringkasan pembayaran akunmu.'
              : accountError != null
              ? 'Ringkasan gagal dimuat. Tarik layar untuk mencoba lagi.'
              : unpaid == 'Rp 0'
              ? 'Semua tagihan SPP sudah diselesaikan.'
              : 'Masih ada tagihan yang perlu diperhatikan.',
          style: TextStyle(fontSize: 8, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 11),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F5FF),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Row(
            children: [
              Expanded(
                child: _mini(
                  'JATUH TEMPO TERDEKAT',
                  loading ? 'Memuat...' : nextDueDate,
                ),
              ),
              Expanded(
                child: _mini(
                  'TAGIHAN AKTIF',
                  loading ? 'Memuat...' : '$activeBills tagihan',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 40,
          child: FilledButton.icon(
            onPressed: () => setState(() => index = 3),
            style: FilledButton.styleFrom(
              backgroundColor: eloraPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(Icons.receipt_long_rounded, size: 15),
            label: Text(
              'Lihat Rincian Pembayaran',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _homeChoices() => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: const Color(0xFFE4EAFE),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        _homeChoice(
          'SPP/Tagihan',
          Icons.receipt_long_rounded,
          () => setState(() => index = 3),
          selected: true,
        ),
        _homeChoice(
          'Presensi',
          Icons.qr_code_scanner_rounded,
          () => open(const AttendanceScanPage()),
        ),
      ],
    ),
  );

  Widget _homeChoice(
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool selected = false,
  }) => Expanded(
    child: Material(
      color: selected ? eloraPrimary : Colors.transparent,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 13, color: selected ? Colors.white : eloraDark),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    color: selected ? Colors.white : eloraDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  Widget _mini(String a, String b) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        a,
        style: TextStyle(
          fontSize: 6,
          color: Colors.grey.shade500,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        b,
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w800,
          color: eloraDark,
        ),
      ),
    ],
  );
  Widget _quick() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Menu Cepat',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w900,
          color: eloraDark,
        ),
      ),
      Text(
        'Layanan dan administrasi siswa terintegrasi.',
        style: TextStyle(fontSize: 8, color: Colors.grey.shade600),
      ),
      const SizedBox(height: 9),
      SizedBox(
        height: 91,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _quickItem(
              Icons.qr_code_scanner_rounded,
              'Presensi',
              () => open(const AttendanceScanPage()),
            ),
            _quickItem(
              Icons.receipt_long_rounded,
              'Riwayat SPP',
              () => setState(() => index = 3),
            ),
            _quickItem(
              Icons.currency_exchange_rounded,
              'Konversi',
              () => open(const CurrencyPage()),
            ),
            _quickItem(
              Icons.grid_3x3_rounded,
              'Mini Game',
              () => open(const TicTacToeScreen()),
            ),
            _quickItem(
              Icons.access_time_rounded,
              'Waktu',
              () => open(const TimePage()),
            ),
            _quickItem(
              Icons.dark_mode_rounded,
              'Personalisasi',
              () => open(const SettingsPage()),
            ),
            _quickItem(
              Icons.school_outlined,
              'Institusi',
              () => setState(() => index = 1),
            ),
          ],
        ),
      ),
    ],
  );
  Widget _quickItem(IconData i, String title, VoidCallback f) =>
      GestureDetector(
        onTap: f,
        child: Container(
          width: 82,
          margin: const EdgeInsets.only(right: 9),
          padding: const EdgeInsets.fromLTRB(7, 9, 7, 8),
          decoration: BoxDecoration(
            color: eloraCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE4ECEA)),
          ),
          child: Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5F2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(i, color: eloraPrimary, size: 16),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                  color: eloraDark,
                ),
              ),
            ],
          ),
        ),
      );
  Widget _news() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              'Aktivitas Akun & Pengumuman',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: eloraDark,
              ),
            ),
          ),
          TextButton(
            onPressed: () => open(const NotificationPage()),
            child: Text(
              'Semua ›',
              style: TextStyle(fontSize: 8, color: eloraPrimary),
            ),
          ),
        ],
      ),
      const SizedBox(height: 2),
      Text(
        'Riwayat tagihan dan pesan khusus untuk akun siswa.',
        style: TextStyle(fontSize: 8, color: Colors.grey.shade600),
      ),
      const SizedBox(height: 8),
      ...notices.map(
        (n) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: eloraCard,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFE7ECEB)),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F7F2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  n['type'] == 'payment'
                      ? Icons.payments_outlined
                      : Icons.notifications_none_rounded,
                  color: eloraPrimary,
                  size: 16,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n['title']?.toString() ?? 'Aktivitas akun siswa',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: eloraDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      n['message']?.toString() ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 7,
                        height: 1.35,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatDate(n['created_at']),
                style: TextStyle(fontSize: 6, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ),
      if (notices.isEmpty)
        Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: eloraCard,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFE7ECEB)),
          ),
          child: Text(
            notificationError == null
                ? 'Belum ada aktivitas pembayaran atau pengumuman khusus untuk akun ini.'
                : 'Pengumuman akun gagal dimuat. Tarik layar untuk mencoba lagi.',
            style: TextStyle(fontSize: 9, color: Colors.grey),
          ),
        ),
    ],
  );
  String _greet() {
    final h = DateTime.now().hour;
    return h < 11
        ? 'Selamat pagi'
        : h < 15
        ? 'Selamat siang'
        : h < 18
        ? 'Selamat sore'
        : 'Selamat malam';
  }
}
