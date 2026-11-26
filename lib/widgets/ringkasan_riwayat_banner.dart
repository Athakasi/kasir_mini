import 'package:flutter/material.dart';

import '../core/format_rupiah.dart';

/// #BannerRingkasanRiwayat — Kotak ringkasan laporan di atas Halaman Riwayat.
/// Mirip kartu laporan rekap harian di dashboard admin Laravel: merangkum
/// jumlah nota yang sudah terbit beserta total uang masuk (omzet).
class RingkasanRiwayatBanner extends StatelessWidget {
  const RingkasanRiwayatBanner({
    super.key,
    required this.jumlahTransaksi,
    required this.totalOmzet,
    required this.onBersihkan,
  });

  final int jumlahTransaksi;
  final int totalOmzet;
  final VoidCallback onBersihkan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer.withAlpha(140),
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Wrap(
          spacing: 20,
          runSpacing: 10,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _InfoAngka(
              ikon: Icons.receipt_long_outlined,
              label: 'Total Nota',
              nilai: '$jumlahTransaksi transaksi',
            ),
            _InfoAngka(
              ikon: Icons.payments_outlined,
              label: 'Total Omzet',
              nilai: FormatRupiah.dari(totalOmzet),
            ),
            TextButton.icon(
              onPressed: onBersihkan,
              icon: Icon(
                Icons.delete_sweep_outlined,
                size: 18,
                color: theme.colorScheme.error,
              ),
              label: Text(
                'Bersihkan',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoAngka extends StatelessWidget {
  const _InfoAngka({
    required this.ikon,
    required this.label,
    required this.nilai,
  });

  final IconData ikon;
  final String label;
  final String nilai;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final warna = theme.colorScheme.onPrimaryContainer;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(ikon, size: 20, color: warna),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              nilai,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: warna,
              ),
            ),
            Text(label, style: theme.textTheme.labelSmall),
          ],
        ),
      ],
    );
  }
}
