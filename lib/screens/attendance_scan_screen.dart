import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:elora_school/theme/colors.dart';

class AttendanceScanPage extends StatefulWidget {
  const AttendanceScanPage({super.key});
  @override
  State<AttendanceScanPage> createState() => _AttendanceScanPageState();
}

class _AttendanceScanPageState extends State<AttendanceScanPage> {
  final MobileScannerController controller = MobileScannerController();
  bool scanned = false;
  String? code;
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: eloraBackground,
    appBar: AppBar(
      title: Text('Presensi'),
      backgroundColor: eloraBackground,
      foregroundColor: eloraDark,
      elevation: 0,
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
      children: [
        Text(
          'Scan QR Presensi',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w900,
            color: eloraDark,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Arahkan kamera ke QR presensi dari guru/sekolah.',
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 18),
        ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: SizedBox(
            height: 350,
            child: Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(
                  controller: controller,
                  onDetect: (capture) {
                    if (scanned) return;
                    final raw = capture.barcodes.isNotEmpty
                        ? capture.barcodes.first.rawValue
                        : null;
                    if (raw == null || raw.isEmpty) return;
                    setState(() {
                      scanned = true;
                      code = raw;
                    });
                    controller.stop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('QR presensi berhasil dipindai.'),
                      ),
                    );
                  },
                ),
                Center(
                  child: Container(
                    width: 245,
                    height: 245,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 3),
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
                const Positioned(
                  top: 48,
                  left: 0,
                  right: 0,
                  child: Text(
                    'ELORA • SCAN AREA',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 24,
                  right: 24,
                  child: Text(
                    scanned
                        ? 'QR terbaca: ${code ?? ''}'
                        : 'Arahkan QR ke kotak',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => controller.toggleTorch(),
                icon: Icon(Icons.flash_on_rounded, size: 17),
                label: Text('Lampu'),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => controller.switchCamera(),
                icon: Icon(Icons.cameraswitch_rounded, size: 17),
                label: Text('Kamera'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (scanned)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE5F3F1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: eloraPrimary),
                SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Presensi tercatat',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: eloraDark,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'QR valid • status hadir dicatat',
                        style: TextStyle(fontSize: 9, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        if (scanned) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 45,
            child: FilledButton(
              onPressed: () {
                setState(() => scanned = false);
                controller.start();
              },
              child: Text('Scan Lagi'),
            ),
          ),
        ],
        const SizedBox(height: 18),
        Text(
          'Tips',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: eloraDark,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'Pastikan izin kamera aktif, pencahayaan cukup, dan QR berada di dalam kotak pemindaian.',
          style: TextStyle(fontSize: 10, height: 1.5, color: Colors.black54),
        ),
      ],
    ),
  );
}
