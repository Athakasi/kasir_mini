import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/format_rupiah.dart';
import '../core/format_waktu.dart';
import '../models/transaksi.dart';
import '../services/struk_pdf_service.dart';

/// #DialogStruk — Jendela pop-up nota pembayaran bergaya struk minimarket.
/// Komponen ini reusable (dipakai ulang): dipanggil otomatis selesai bayar di
/// halaman Kasir, dan dipanggil lagi saat melihat detail di halaman Riwayat.
class StrukDialog extends StatelessWidget {
  const StrukDialog({
    super.key,
    required this.transaksi,
  });

  final Transaksi transaksi;

  /// #TampilkanStruk — Fungsi praktis untuk membuka pop-up struk di layar mana saja.
  static Future<void> tampilkan(BuildContext context, Transaksi transaksi) {
    return showDialog<void>(
      context: context,
      builder: (_) => StrukDialog(transaksi: transaksi),
    );
  }

  /// #SusunTeksStruk — Merangkai isi nota menjadi teks biasa agar mudah disalin
  /// ke clipboard (misalnya untuk dikirim lewat WhatsApp ke pembeli).
  String _susunTeksPolos() {
    final buf = StringBuffer()
      ..writeln('=== KASIR MINI ===')
      ..writeln('No   : ${transaksi.id}')
      ..writeln('Waktu: ${FormatWaktu.tanggalJam(transaksi.waktu)}')
      ..writeln('------------------');

    for (final item in transaksi.items) {
      buf
        ..writeln(item.produk.nama)
        ..writeln(
          '  ${item.qty} x ${FormatRupiah.dari(item.produk.harga)} = ${FormatRupiah.dari(item.subtotal)}',
        );
    }

    buf
      ..writeln('------------------')
      ..writeln('Subtotal : ${FormatRupiah.dari(transaksi.subtotal)}');
    if (transaksi.diskonPersen > 0) {
      buf.writeln(
        'Diskon ${transaksi.diskonPersen}%: -${FormatRupiah.dari(transaksi.nominalDiskon)}',
      );
    }
    buf
      ..writeln('TOTAL    : ${FormatRupiah.dari(transaksi.totalBayar)}')
      ..writeln('Tunai    : ${FormatRupiah.dari(transaksi.uangBayar)}')
      ..writeln('Kembali  : ${FormatRupiah.dari(transaksi.kembalian)}')
      ..write('Terima kasih telah berbelanja!');

    return buf.toString();
  }

  Future<void> _salinStruk(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: _susunTeksPolos()));
    messenger.showSnackBar(
      const SnackBar(content: Text('Teks struk disalin ke clipboard')),
    );
  }

  /// #AksiCetakPdf — Membuka dialog Print bawaan browser (Web) atau HP (Android).
  Future<void> _cetakStruk(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await StrukPdfService.cetak(transaksi);
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Gagal membuka layanan cetak perangkat')),
      );
    }
  }

  /// #AksiBagikanPdf — Mengunduh file `.pdf` di Web atau membagikan ke aplikasi lain di Android.
  Future<void> _bagikanPdf(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await StrukPdfService.bagikanAtauUnduh(transaksi);
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Gagal membagikan dokumen PDF')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      actionsOverflowButtonSpacing: 8,
      title: Column(
        children: [
          Icon(
            Icons.receipt_long,
            size: 36,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 8),
          const Text(
            'KASIR MINI',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          const SizedBox(height: 4),
          Text(
            '${transaksi.id} • ${FormatWaktu.tanggalJam(transaksi.waktu)}',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Divider(),
              ...transaksi.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.produk.nama,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${item.qty} × ${FormatRupiah.dari(item.produk.harga)}',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(FormatRupiah.dari(item.subtotal)),
                    ],
                  ),
                ),
              ),
              const Divider(height: 20),
              _BarisNota(
                label: 'Subtotal',
                nilai: FormatRupiah.dari(transaksi.subtotal),
              ),
              if (transaksi.diskonPersen > 0)
                _BarisNota(
                  label: 'Diskon (${transaksi.diskonPersen}%)',
                  nilai: '- ${FormatRupiah.dari(transaksi.nominalDiskon)}',
                ),
              _BarisNota(
                label: 'Total Bayar',
                nilai: FormatRupiah.dari(transaksi.totalBayar),
                tebal: true,
              ),
              const SizedBox(height: 4),
              _BarisNota(
                label: 'Tunai',
                nilai: FormatRupiah.dari(transaksi.uangBayar),
              ),
              _BarisNota(
                label: 'Kembalian',
                nilai: FormatRupiah.dari(transaksi.kembalian),
                tebal: true,
                sorotHijau: true,
              ),
              const SizedBox(height: 16),
              // #BarisTombolKirim — Deretan aksi ekspor struk (Salin Teks, PDF, Cetak).
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _salinStruk(context),
                    icon: const Icon(Icons.copy_outlined, size: 18),
                    label: const Text('Salin Teks'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _bagikanPdf(context),
                    icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                    label: const Text('PDF / Share'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () => _cetakStruk(context),
                    icon: const Icon(Icons.print_outlined, size: 18),
                    label: const Text('Cetak'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Terima kasih telah berbelanja!',
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Tutup'),
        ),
      ],
    );
  }
}

class _BarisNota extends StatelessWidget {
  const _BarisNota({
    required this.label,
    required this.nilai,
    this.tebal = false,
    this.sorotHijau = false,
  });

  final String label;
  final String nilai;
  final bool tebal;
  final bool sorotHijau;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gaya = tebal
        ? theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)
        : theme.textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(label, style: gaya)),
          const SizedBox(width: 8),
          Text(
            nilai,
            style: gaya?.copyWith(
              color: sorotHijau ? theme.colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }
}
