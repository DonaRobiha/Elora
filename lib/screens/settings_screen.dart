import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elora_school/theme/colors.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool dark = false;
  double textScale = 1.0;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    dark = p.getBool('dark_mode') ?? false;
    textScale = p.getDouble('text_scale') ?? 1.0;
    eloraTextScale.value = textScale;
    if (mounted) setState(() {});
  }

  Future<void> _toggle(bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('dark_mode', value);
    eloraThemeMode.value = value ? ThemeMode.dark : ThemeMode.light;
    setState(() => dark = value);
  }

  Future<void> _setTextScale(double value) async {
    final p = await SharedPreferences.getInstance();
    await p.setDouble('text_scale', value);
    eloraTextScale.value = value;
    setState(() => textScale = value);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    appBar: AppBar(
      title: Text('Personalisasi ELORA'),
      backgroundColor: Colors.transparent,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      elevation: 0,
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: eloraPrimary,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 28),
              SizedBox(height: 12),
              Text(
                'Buat ELORA sesuai gayamu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Atur tampilan aplikasi tanpa mengubah data akun.',
                style: TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Card(
          child: SwitchListTile(
            value: dark,
            onChanged: _toggle,
            secondary: Icon(
              dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: eloraPrimary,
            ),
            title: Text(
              'Mode gelap',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(
              dark ? 'Tampilan gelap aktif' : 'Tampilan terang aktif',
            ),
            activeThumbColor: eloraPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.format_size_rounded, color: eloraPrimary),
                    SizedBox(width: 10),
                    Text(
                      'Ukuran teks',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Slider(
                  value: textScale,
                  min: 0.85,
                  max: 1.25,
                  divisions: 4,
                  activeColor: eloraPrimary,
                  label: '${(textScale * 100).round()}%',
                  onChanged: _setTextScale,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Kecil',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      'Besar',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
