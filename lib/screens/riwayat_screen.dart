import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/format_rupiah.dart';
import '../core/format_waktu.dart';
import '../cubit/riwayat_cubit.dart';
import '../cubit/riwayat_state.dart';
import '../models/transaksi.dart';
import '../widgets/placeholder_view.dart';
import '../widgets/ringkasan_riwayat_banner.dart';
import '../widgets/struk_dialog.dart';

/// #HalamanRiwayat — Menampilkan daftar seluruh transaksi yang pernah selesai dibayar.
/// Mirip halaman `transactions/index.blade.php` di Laravel: merangkum total omzet
/// di atas, lalu menampilkan daftar nota yang bisa diklik untuk melihat struknya lagi.
class RiwayatScreen extends StatelessWidget {
  const RiwayatScreen({super.key});

  Future<void> _konfirmasiBersihkan(BuildContext context) async {
    final cubit = context.read<RiwayatCubit>();
    final messenger = ScaffoldMessenger.of(context);

    final yakin = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Hapus Semua Riwayat?'),
        content: const Text(
          'Seluruh catatan struk dan total omzet akan dikosongkan. Stok barang tidak berubah.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogCtx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );

    if (yakin != true) return;

    await cubit.hapusSemuaRiwayat();
    messenger.showSnackBar(
      const SnackBar(content: Text('Riwayat transaksi telah dibersihkan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RiwayatCubit, RiwayatState>(
      builder: (context, state) {
        if (state.sedangMemuat) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.daftarTransaksi.isEmpty) {
          return const PlaceholderView(
            icon: Icons.receipt_long_outlined,
            title: 'Belum ada riwayat transaksi',
            message:
                'Setiap pembayaran yang diselesaikan di tab Kasir akan otomatis tercatat di sini.',
          );
        }

        // #HeaderTetapRiwayat — Kartu Total Nota & Omzet diam di atas, daftar nota digulir di bawah.
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                RingkasanRiwayatBanner(
                  jumlahTransaksi: state.daftarTransaksi.length,
                  totalOmzet: state.totalOmzet,
                  onBersihkan: () => _konfirmasiBersihkan(context),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 4, bottom: 24),
                    itemCount: state.daftarTransaksi.length,
                    itemBuilder: (context, index) {
                      final trx = state.daftarTransaksi[index];
                      return _KartuRiwayat(transaksi: trx);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// #KartuSatuNota — Satu baris riwayat yang membuka ulang `StrukDialog` saat diketuk.
class _KartuRiwayat extends StatelessWidget {
  const _KartuRiwayat({required this.transaksi});

  final Transaksi transaksi;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: () => StrukDialog.tampilkan(context, transaksi),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          foregroundColor: theme.colorScheme.onPrimaryContainer,
          child: const Icon(Icons.receipt_outlined),
        ),
        title: Text(
          transaksi.id,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${FormatWaktu.tanggalJam(transaksi.waktu)} • ${transaksi.totalQty} barang',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              FormatRupiah.dari(transaksi.totalBayar),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
