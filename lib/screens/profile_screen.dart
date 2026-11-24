import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:elora_school/theme/colors.dart';
import 'package:elora_school/services/auth_service.dart';
import 'package:elora_school/services/payment_service.dart';
import 'package:elora_school/screens/login_screen.dart';
import 'package:elora_school/screens/attendance_scan_screen.dart';
import 'package:elora_school/screens/payment_screen.dart';
import 'package:elora_school/screens/settings_screen.dart';
import 'package:elora_school/screens/notification_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? profile;
  bool loading = true;
  String? photo;
  Map<String, String>? wali;
  final LocalAuthentication _localAuth = LocalAuthentication();
  double sppOutstanding = 0;
  int activeBills = 0;
  String? paymentError;
  bool biometricAvailable = false;
  bool biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _load();
    _checkBiometricAvailability();
  }

  Future<void> _loadWali() async {
    final p = await SharedPreferences.getInstance();
    final nama = p.getString('wali_nama');
    final hp = p.getString('wali_hp');
    final hubungan = p.getString('wali_hubungan');
    if (nama != null && hp != null && mounted) {
      setState(
        () => wali = {
          'nama': nama,
          'hp': hp,
          'hubungan': hubungan ?? 'Wali Murid',
        },
      );
    }
  }

  Future<void> _load() async {
    await _loadWali();
    try {
      final p = await AuthService.instance.currentProfile();
      var total = 0.0;
      var count = 0;
      String? billError;
      try {
        final payments = await PaymentService.instance.myPayments();
        for (final payment in payments) {
          if (payment['status'].toString().toLowerCase() == 'paid') continue;
          final amount = double.tryParse('${payment['amount']}') ?? 0;
          final paid = double.tryParse('${payment['paid_amount'] ?? 0}') ?? 0;
          total += (amount - paid).clamp(0, amount).toDouble();
          count++;
        }
      } catch (e) {
        billError = e.toString();
        debugPrint('PROFILE PAYMENT ERROR: $e');
      }
      if (!mounted) return;
      setState(() {
        profile = p;
        photo = p['avatar_url']?.toString();
        sppOutstanding = total;
        activeBills = count;
        paymentError = billError;
        loading = false;
      });
    } catch (e) {
      debugPrint('PROFILE LOAD ERROR: $e');
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final supported = await _localAuth.isDeviceSupported();
      final enabled = await AuthService.instance.hasBiometricCredentials();
      if (!mounted) return;
      setState(() {
        biometricAvailable = canCheck || supported;
        biometricEnabled = enabled;
      });
    } catch (e) {
      debugPrint('PROFILE BIOMETRIC CHECK ERROR: $e');
    }
  }

  String v(String key, [String fallback = 'Belum diisi']) {
    final x = profile?[key]?.toString().trim();
    return x == null || x.isEmpty ? fallback : x;
  }

  void _open(Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  String _rupiah(double amount) {
    final value = amount.round().toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
    return 'Rp $value';
  }

  Widget _profileHeader() => Container(
    padding: const EdgeInsets.fromLTRB(13, 10, 12, 10),
    decoration: BoxDecoration(
      color: eloraPrimary,
      borderRadius: BorderRadius.circular(17),
    ),
    child: Row(
      children: [
        Container(
          width: 31,
          height: 31,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .14),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.school_rounded,
            color: Colors.white,
            size: 17,
          ),
        ),
        const SizedBox(width: 9),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ELORA CAMPUS • SISWA',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 7,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .7,
                ),
              ),
              Text(
                'Profil',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Notifikasi',
          onPressed: () => _open(const NotificationPage()),
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: Colors.white,
            size: 19,
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: eloraBackground,
        body: Center(child: CircularProgressIndicator(color: eloraPrimary)),
      );
    }
    return Scaffold(
      backgroundColor: eloraBackground,
      body: SafeArea(
        child: RefreshIndicator(
          color: eloraPrimary,
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
            children: [
              _profileHeader(),
              const SizedBox(height: 12),
              _profileCard(),
              const SizedBox(height: 12),
              _sppCard(),
              const SizedBox(height: 14),
              _section('DATA AKADEMIK & SISWA', [
                _menu(
                  Icons.school_outlined,
                  'Data Akademik',
                  'Informasi institusi dan status siswa',
                  () => _academicDialog(),
                ),
                _menu(
                  Icons.badge_outlined,
                  'Data Siswa & Wali Murid',
                  wali == null
                      ? 'Lengkapi data pribadi dan wali siswa'
                      : 'Lihat data pribadi dan wali siswa',
                  () => _personalDialog(),
                ),
              ]),
              const SizedBox(height: 14),
              _section('REFERENSI & KEAMANAN', [
                _biometricTile(),
                _menu(
                  Icons.dark_mode_outlined,
                  'Personalisasi ELORA',
                  'Tema aplikasi dan ukuran teks',
                  () => _open(const SettingsPage()),
                ),
              ]),
              const SizedBox(height: 18),
              _logout(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileCard() => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF056E69), Color(0xFF034F4C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(23),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'KARTU PELAJAR DIGITAL',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .8,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .16),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'ELORA PASS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 7,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 13),
        Row(
          children: [
            GestureDetector(
              onTap: _photoSource,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 29,
                    backgroundColor: Colors.white24,
                    backgroundImage: photo != null && photo!.startsWith('http')
                        ? NetworkImage(photo!)
                        : null,
                    child: photo == null
                        ? const Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                            size: 30,
                          )
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 19,
                      height: 19,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: eloraPrimary,
                        size: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    v('nama', 'Siswa ELORA'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'NISN ${v('student_id', '-')}',
                    style: const TextStyle(color: Colors.white70, fontSize: 8),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    v('institution', 'SMP ELORA Bantul'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 8),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .13),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.qr_code_2_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'KARTU SISWA',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 6,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(
              Icons.verified_user_rounded,
              color: Color(0xFF9AF1D5),
              size: 13,
            ),
            const SizedBox(width: 5),
            const Expanded(
              child: Text(
                'Kartu pelajar aktif',
                style: TextStyle(color: Colors.white70, fontSize: 8),
              ),
            ),
            SizedBox(
              height: 30,
              child: FilledButton.icon(
                onPressed: () => _open(const AttendanceScanPage()),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: eloraPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                icon: const Icon(Icons.qr_code_scanner_rounded, size: 13),
                label: const Text(
                  'Presensi',
                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _sppCard() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Theme.of(context).dividerColor),
    ),
    child: Row(
      children: [
        Container(
          width: 39,
          height: 39,
          decoration: BoxDecoration(
            color: eloraPrimary.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.receipt_long_rounded,
            color: eloraPrimary,
            size: 19,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Status SPP',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                paymentError == null
                    ? activeBills == 0
                          ? 'Lunas • Tidak ada tagihan aktif'
                          : '$activeBills tagihan belum lunas'
                    : 'Status pembayaran tidak dapat dimuat',
                style: TextStyle(
                  fontSize: 8,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Text(
          paymentError == null ? _rupiah(sppOutstanding) : '—',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: eloraPrimary,
          ),
        ),
        const SizedBox(width: 3),
        IconButton(
          tooltip: 'Rincian pembayaran',
          onPressed: () => _open(const PaymentPage()),
          icon: const Icon(
            Icons.chevron_right_rounded,
            color: eloraPrimary,
            size: 19,
          ),
        ),
      ],
    ),
  );

  Widget _section(String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: Colors.grey.shade500,
          letterSpacing: 1,
        ),
      ),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          children: List.generate(
            children.length,
            (i) => Column(
              children: [
                children[i],
                if (i < children.length - 1)
                  Divider(
                    height: 1,
                    indent: 60,
                    color: Theme.of(context).dividerColor,
                  ),
              ],
            ),
          ),
        ),
      ),
    ],
  );

  Widget _menu(IconData icon, String title, String sub, VoidCallback onTap) =>
      ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        onTap: onTap,
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFE5F3F1),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: eloraPrimary, size: 19),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          sub,
          style: TextStyle(fontSize: 8, color: Colors.grey.shade500),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          size: 18,
          color: Colors.black38,
        ),
      );

  Widget _logout() => SizedBox(
    height: 46,
    width: double.infinity,
    child: OutlinedButton.icon(
      onPressed: () => _logoutDialog(),
      icon: const Icon(Icons.logout_rounded, size: 17),
      label: const Text(
        'Keluar dari Akun',
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red.shade600,
        side: BorderSide(color: Colors.red.shade200),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );

  void _academicDialog() => showModalBottomSheet(
    context: context,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data Akademik',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 15),
            _row('Institusi', v('institution', 'SMP ELORA Bantul')),
            _row('Peran', v('role', 'Siswa')),
            _row('NIS/NISN', v('student_id', '-')),
            _row(
              'Status',
              v('is_active', 'Aktif') == 'true' ? 'Aktif' : v('is_active'),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _biometricTile() => SwitchListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
    secondary: Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFFE5F3F1),
        borderRadius: BorderRadius.circular(11),
      ),
      child: const Icon(
        Icons.fingerprint_rounded,
        color: eloraPrimary,
        size: 21,
      ),
    ),
    title: Text(
      'Kunci Biometrik',
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    ),
    subtitle: Text(
      biometricAvailable
          ? biometricEnabled
                ? 'Aktif untuk masuk cepat'
                : 'Belum aktif pada perangkat ini'
          : 'Biometrik tidak tersedia',
      style: TextStyle(fontSize: 8, color: Colors.grey.shade500),
    ),
    value: biometricEnabled,
    activeThumbColor: eloraPrimary,
    onChanged: !biometricAvailable
        ? null
        : (value) async {
            if (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Aktifkan biometrik melalui pilihan pada halaman login.',
                  ),
                ),
              );
              return;
            }
            await AuthService.instance.clearBiometricCredentials();
            if (!mounted) return;
            setState(() => biometricEnabled = false);
          },
  );

  void _personalDialog() => showModalBottomSheet(
    context: context,
    showDragHandle: true,
    backgroundColor: Colors.white,
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data Pribadi',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: eloraDark,
              ),
            ),
            const SizedBox(height: 15),
            _row('Nama', v('nama', 'Dona Robiha')),
            _row('NISN', v('student_id', '124240026')),
            _row('Sekolah', v('institution', 'SMP ELORA Bantul')),
            _row('Peran', v('role', 'Siswa')),
            _row('Email', v('email', 'Belum tersedia')),
          ],
        ),
      ),
    ),
  );

  Widget _row(String a, String b) => Padding(
    padding: const EdgeInsets.only(bottom: 13),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 85,
          child: Text(
            a,
            style: TextStyle(fontSize: 9, color: Colors.grey.shade500),
          ),
        ),
        Expanded(
          child: Text(
            b,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: eloraDark,
            ),
          ),
        ),
      ],
    ),
  );

  void _waliForm() {
    final nama = TextEditingController(text: wali?['nama'] ?? '');
    final hp = TextEditingController(text: wali?['hp'] ?? '');
    final hubungan = TextEditingController(text: wali?['hubungan'] ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          8,
          20,
          MediaQuery.of(ctx).viewInsets.bottom + 25,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Wali Murid',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: eloraDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                wali == null
                    ? 'Isi data wali murid terlebih dahulu.'
                    : 'Perbarui data wali murid.',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: nama,
                decoration: const InputDecoration(labelText: 'Nama wali'),
              ),
              const SizedBox(height: 11),
              TextField(
                controller: hp,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Nomor HP'),
              ),
              const SizedBox(height: 11),
              TextField(
                controller: hubungan,
                decoration: const InputDecoration(labelText: 'Hubungan'),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: FilledButton(
                  onPressed: () async {
                    if (nama.text.trim().isEmpty || hp.text.trim().isEmpty) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                          content: Text('Nama dan nomor HP wajib diisi.'),
                        ),
                      );
                      return;
                    }
                    final saved = {
                      'nama': nama.text.trim(),
                      'hp': hp.text.trim(),
                      'hubungan': hubungan.text.trim().isEmpty
                          ? 'Wali Murid'
                          : hubungan.text.trim(),
                    };
                    try {
                      final preferences = await SharedPreferences.getInstance();
                      await preferences.setString('wali_nama', saved['nama']!);
                      await preferences.setString('wali_hp', saved['hp']!);
                      await preferences.setString(
                        'wali_hubungan',
                        saved['hubungan']!,
                      );
                    } catch (e) {
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text('Data wali gagal disimpan: $e'),
                          ),
                        );
                      }
                      return;
                    }
                    setState(() => wali = saved);
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                  },
                  child: const Text('Simpan Data Wali'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _photoSource() => showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt_rounded, color: eloraPrimary),
            title: const Text('Ambil Foto'),
            onTap: () {
              Navigator.pop(ctx);
              _pick(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.photo_library_rounded,
              color: eloraPrimary,
            ),
            title: const Text('Pilih dari Galeri'),
            onTap: () {
              Navigator.pop(ctx);
              _pick(ImageSource.gallery);
            },
          ),
        ],
      ),
    ),
  );
  Future<void> _pick(ImageSource source) async {
    try {
      final x = await ImagePicker().pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (x == null) return;
      final ext = x.name.toLowerCase().endsWith('.png') ? 'png' : 'jpg';
      final url = await AuthService.instance.uploadAvatar(
        await x.readAsBytes(),
        ext,
      );
      if (mounted) setState(() => photo = url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memperbarui foto.')),
        );
      }
    }
  }

  void _logoutDialog() => showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Keluar dari akun?'),
      content: const Text('Sesi akan diakhiri pada perangkat ini.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(ctx);
            await AuthService.instance.signOut();
            if (!mounted) return;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (_) => false,
            );
          },
          child: const Text('Keluar', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}
