import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/produk_cubit.dart';
import '../cubit/produk_state.dart';
import '../models/produk.dart';
import '../widgets/placeholder_view.dart';
import '../widgets/produk_form_dialog.dart';
import '../widgets/produk_tile.dart';
import '../widgets/ringkasan_stok_banner.dart';

/// #HalamanStok — Menampilkan daftar barang dan aksi tambah/ubah/hapus lewat `ProdukCubit`.
/// Mirip halaman `stok/index.blade.php` di Laravel: daftar ditampilkan di tengah,
/// sedangkan aksi dikirim ke Controller (`context.read<ProdukCubit>()`).
class StokScreen extends StatelessWidget {
  const StokScreen({super.key});

  /// #AksiTambah — Membuka modal form kosong; jika disimpan, kirim ke `ProdukCubit`.
  Future<void> _bukaFormTambah(BuildContext context) async {
    final cubit = context.read<ProdukCubit>();
    final messenger = ScaffoldMessenger.of(context);

    final hasil = await ProdukFormDialog.tampilkan(context);
    if (hasil == null) return;

    cubit.tambahProduk(
      nama: hasil.nama,
      harga: hasil.harga,
      stok: hasil.stok,
    );
    messenger.showSnackBar(
      SnackBar(content: Text('"${hasil.nama}" berhasil ditambahkan')),
    );
  }

  /// #AksiUbah — Membuka modal form berisi data lama; jika disimpan, perbarui lewat `ProdukCubit`.
  Future<void> _bukaFormUbah(BuildContext context, Produk produk) async {
    final cubit = context.read<ProdukCubit>();
    final messenger = ScaffoldMessenger.of(context);

    final hasil = await ProdukFormDialog.tampilkan(context, produkAwal: produk);
    if (hasil == null) return;

    cubit.ubahProduk(
      produk.copyWith(
        nama: hasil.nama,
        harga: hasil.harga,
        stok: hasil.stok,
      ),
    );
    messenger.showSnackBar(
      SnackBar(content: Text('"${hasil.nama}" berhasil diperbarui')),
    );
  }

  /// #KonfirmasiHapus — Menampilkan kotak tanya sebelum menghapus (mirip `confirm(...)` di JS).
  Future<void> _konfirmasiHapus(BuildContext context, Produk produk) async {
    final cubit = context.read<ProdukCubit>();
    final messenger = ScaffoldMessenger.of(context);

    final yakin = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Hapus Barang?'),
        content: Text('Yakin ingin menghapus "${produk.nama}" dari stok?'),
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
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (yakin != true) return;

    cubit.hapusProduk(produk.id);
    messenger.showSnackBar(
      SnackBar(content: Text('"${produk.nama}" telah dihapus')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // #TombolApung — `FloatingActionButton` adalah tombol aksi utama di pojok kanan bawah.
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _bukaFormTambah(context),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Barang'),
      ),
      body: BlocBuilder<ProdukCubit, ProdukState>(
        builder: (context, state) {
          if (state.sedangMemuat) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.daftarProduk.isEmpty) {
            return const PlaceholderView(
              icon: Icons.inventory_2_outlined,
              title: 'Stok masih kosong',
              message: 'Tekan tombol "+ Tambah Barang" di kanan bawah untuk mengisi stok.',
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView.builder(
                // Padding bawah ekstra supaya kartu paling bawah tidak tertutup tombol apung.
                // Item ke-0 adalah banner ringkasan stok, sisanya kartu produk.
                padding: const EdgeInsets.fromLTRB(0, 4, 0, 88),
                itemCount: state.daftarProduk.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return RingkasanStokBanner(
                      daftarProduk: state.daftarProduk,
                    );
                  }
                  final produk = state.daftarProduk[index - 1];
                  return ProdukTile(
                    produk: produk,
                    onUbah: () => _bukaFormUbah(context, produk),
                    onHapus: () => _konfirmasiHapus(context, produk),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
