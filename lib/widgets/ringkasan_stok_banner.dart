import 'package:flutter/material.dart';

import '../models/produk.dart';

/// #BannerRingkasanStok — Kotak info singkat di bagian atas Halaman Stok.
/// Mirip kartu "Summary Dashboard" di halaman admin Laravel: merangkum total
/// jenis barang, total unit fisik, dan jumlah barang yang sudah habis.
class RingkasanStokBanner extends StatelessWidget {
  const RingkasanStokBanner({
    super.key,
    required this.daftarProduk,
  });

  final List<Produk> daftarProduk;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalJenis = daftarProduk.length;
    final totalUnit = daftarProduk.fold<int>(0, (sum, p) => sum + p.stok);
    final jumlahHabis = daftarProduk.where((p) => p.stok <= 0).length;

    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer.withAlpha(140),
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Wrap(
          spacing: 20,
          runSpacing: 8,
          alignment: WrapAlignment.spaceAround,
          children: [
            _KotakAngka(
              ikon: Icons.category_outlined,
              label: 'Jenis Barang',
              nilai: '$totalJenis',
            ),
            _KotakAngka(
              ikon: Icons.inventory_2_outlined,
              label: 'Total Unit',
              nilai: '$totalUnit',
            ),
            _KotakAngka(
              ikon: Icons.warning_amber_rounded,
              label: 'Stok Habis',
              nilai: '$jumlahHabis',
              sorotMerah: jumlahHabis > 0,
            ),
          ],
        ),
      ),
    );
  }
}

class _KotakAngka extends StatelessWidget {
  const _KotakAngka({
    required this.ikon,
    required this.label,
    required this.nilai,
    this.sorotMerah = false,
  });

  final IconData ikon;
  final String label;
  final String nilai;
  final bool sorotMerah;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final warna = sorotMerah
        ? theme.colorScheme.error
        : theme.colorScheme.onPrimaryContainer;

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
