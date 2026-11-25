import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:elora_school/theme/colors.dart';

class ReceiptDetailPage extends StatelessWidget {
  final Map<String, dynamic> payment;

  const ReceiptDetailPage({super.key, required this.payment});

  String _rupiah(dynamic value) {
    final amount = (double.tryParse('$value') ?? 0).round().toString();
    return 'Rp ${amount.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')}';
  }

  String _periodLabel(dynamic value) {
    final parts = (value?.toString() ?? '').split('-');
    if (parts.length != 2) return value?.toString() ?? 'SPP';
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final month = int.tryParse(parts[1]);
    if (month == null || month < 1 || month > 12) {
      return value.toString();
    }
    return '${months[month - 1]} ${parts[0]}';
  }

  String _paidAt(dynamic value) {
    final parsed = DateTime.tryParse(value?.toString() ?? '');
    if (parsed == null) return 'Tanggal pembayaran tidak tersedia';
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
    final date = parsed.toLocal();
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day ${months[date.month - 1]} ${date.year} • $hour:$minute WIB';
  }

  Future<Uint8List> _createPdf() async {
    final pdf = pw.Document();
    final period = _periodLabel(payment['period']);
    final paid = double.tryParse('${payment['paid_amount'] ?? 0}') ?? 0;
    final billed = double.tryParse('${payment['amount'] ?? 0}') ?? 0;
    final verifiedAmount = paid > 0 ? paid : billed;
    final title = payment['bill_type']?.toString() ?? 'SPP';
    final invoice = payment['id']?.toString() ?? '-';

    pw.Widget line(String label, String value) => pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Row(
        children: [
          pw.Expanded(child: pw.Text(label)),
          pw.Expanded(child: pw.Text(value, textAlign: pw.TextAlign.right)),
        ],
      ),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(18),
              color: PdfColors.teal700,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'BUKTI PEMBAYARAN RESMI',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'SI-ELORA CAMPUS',
                    style: const pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text('No. Invoice: INV/ELORA/$invoice'),
            pw.SizedBox(height: 4),
            pw.Text(_paidAt(payment['paid_at'])),
            pw.SizedBox(height: 24),
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text('TOTAL TERVERIFIKASI'),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    _rupiah(verifiedAmount),
                    style: pw.TextStyle(
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text('$title • $period'),
                ],
              ),
            ),
            pw.SizedBox(height: 24),
            line('Siswa', '${payment['nama'] ?? 'Siswa ELORA'}'),
            line('NISN', '${payment['student_id'] ?? '-'}'),
            line('Sekolah', '${payment['institution'] ?? 'ELORA'}'),
            line('Periode', period),
            line('Jenis tagihan', title),
            line('Biaya SPP', _rupiah(payment['amount'] ?? verifiedAmount)),
            line('Total dibayar', _rupiah(verifiedAmount)),
            line('Metode transaksi', 'Pembayaran tercatat'),
            line('Status', 'LUNAS'),
            pw.SizedBox(height: 20),
            pw.Text(
              'Pembayaran ini tercatat pada riwayat tagihan ELORA.',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ],
        ),
      ),
    );
    return pdf.save();
  }

  Future<void> _downloadPdf(BuildContext context) async {
    final bytes = await _createPdf();
    await Printing.layoutPdf(
      name: 'ELORA-Kwitansi-${payment['id'] ?? 'Pembayaran'}',
      onLayout: (_) async => bytes,
    );
  }

  Future<void> _copyReceiptLink(BuildContext context) async {
    final link = 'https://elora.app/kwitansi/${payment['id'] ?? 'pembayaran'}';
    await Clipboard.setData(ClipboardData(text: link));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tautan kuitansi telah disalin')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final period = _periodLabel(payment['period']);
    final paid = double.tryParse('${payment['paid_amount'] ?? 0}') ?? 0;
    final billed = double.tryParse('${payment['amount'] ?? 0}') ?? 0;
    final verifiedAmount = paid > 0 ? paid : billed;
    final title = payment['bill_type']?.toString() ?? 'SPP';
    final invoice = payment['id']?.toString() ?? '-';
    final paidAt = _paidAt(payment['paid_at']);

    return Scaffold(
      backgroundColor: const Color(0xFF0A1A1F),
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: eloraBackground,
              borderRadius: BorderRadius.circular(24),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.receipt_long_rounded, color: eloraPrimary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Detail Kwitansi Pembayaran',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: eloraDark,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: eloraPrimary,
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.school_rounded, color: Colors.white),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SI-ELORA CAMPUS',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'BUKTI BAYAR RESMI',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '• LUNAS •',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'No. Invoice: INV/ELORA/$invoice',
                    style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
                  ),
                  Text(
                    paidAt,
                    style: TextStyle(fontSize: 8, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'TOTAL TERVERIFIKASI',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _rupiah(verifiedAmount),
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.w900,
                            color: eloraDark,
                          ),
                        ),
                        Text(
                          '$title • $period',
                          style: TextStyle(
                            fontSize: 8,
                            color: eloraPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        _line('Siswa', '${payment['nama'] ?? 'Siswa ELORA'}'),
                        _line('NISN', '${payment['student_id'] ?? '-'}'),
                        _line(
                          'Sekolah',
                          '${payment['institution'] ?? 'ELORA'}',
                        ),
                        _line('Periode', period),
                        _line('Jenis tagihan', title),
                        _line(
                          'Biaya SPP',
                          _rupiah(payment['amount'] ?? verifiedAmount),
                        ),
                        _line('Total dibayar', _rupiah(verifiedAmount)),
                        _line('Metode transaksi', 'Pembayaran tercatat'),
                        _line('Status', 'LUNAS'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.verified_user_rounded,
                          size: 32,
                          color: eloraPrimary,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Pembayaran ini tercatat pada riwayat tagihan ELORA.',
                            style: TextStyle(
                              fontSize: 9,
                              height: 1.4,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: FilledButton.icon(
                      onPressed: () => _downloadPdf(context),
                      icon: Icon(Icons.download_rounded),
                      label: Text('Unduh PDF'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: OutlinedButton.icon(
                      onPressed: () => _copyReceiptLink(context),
                      icon: Icon(Icons.share_rounded),
                      label: Text('Bagikan Kuitansi'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: eloraPrimary,
                        side: const BorderSide(color: eloraPrimary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _line(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 9, color: Colors.black45),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: eloraDark,
            ),
          ),
        ),
      ],
    ),
  );
}
