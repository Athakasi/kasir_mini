import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../core/format_rupiah.dart';
import '../cubit/produk_cubit.dart';
import '../cubit/produk_state.dart';
import '../getx/kasir_controller.dart';
import '../models/produk.dart';
import '../widgets/keranjang_panel.dart';
import '../widgets/placeholder_view.dart';

/// #HalamanKasir — Tempat memilih barang dan menghitung pembayaran secara reaktif.
///
/// Di halaman ini Anda bisa melihat **Cubit dan GetX bekerja sama**:
/// 1. Daftar katalog barang diambil dari **`ProdukCubit`** (`BlocConsumer`).
/// 2. Keranjang belanja, qty, diskon, total, dan kembalian dihitung instan oleh
///    **`KasirController` (GetX)** memakai `.obs` + `Obx`.
class KasirScreen extends StatelessWidget {
  const KasirScreen({super.key});

  void _pilihBarang(
    BuildContext context,
    KasirController kasir,
    Produk produk,
  ) {
    final berhasil = kasir.tambahKeKeranjang(produk);
    if (!berhasil) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stok "${produk.nama}" tidak mencukupi')),
      );
    }
  }

  Future<void> _selesaikanTransaksi(
    BuildContext context,
    KasirController kasir,
  ) async {
    final cubit = context.read<ProdukCubit>();
    final messenger = ScaffoldMessenger.of(context);

    // Salin isi keranjang sebelum direset supaya bisa dikirim ke ProdukCubit.
    final itemDibeli = kasir.keranjang.toList();
    final total = FormatRupiah.dari(kasir.totalBayar);
    final kembali = FormatRupiah.dari(kasir.selisihBayar);

    kasir.kosongkanTransaksi();
    await cubit.kurangiStokSetelahTransaksi(itemDibeli);

    messenger.showSnackBar(
      SnackBar(
        content: Text('Transaksi $total berhasil! Kembalian: $kembali'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // #AmbilControllerGetX — `Get.find` mengambil instance `KasirController` yang
    // sudah dipasang lewat `Get.put` di `app.dart` (mirip `app(KasirController::class)` di Laravel).
    final kasir = Get.find<KasirController>();

    return BlocConsumer<ProdukCubit, ProdukState>(
      // #SinkronOtomatis — Jika barang di tab Stok diubah/dihapus, sesuaikan isi keranjang.
      listener: (_, state) => kasir.sinkronkanDenganStok(state.daftarProduk),
      builder: (context, state) {
        if (state.daftarProduk.isEmpty) {
          return const PlaceholderView(
            icon: Icons.point_of_sale_outlined,
            title: 'Belum ada barang untuk dijual',
            message: 'Tambahkan barang terlebih dahulu melalui tab Stok.',
          );
        }

        // #TataLetakResponsif — `LayoutBuilder` mengecek lebar layar:
        // Di Web / Tablet (>= 800px) tampil 2 kolom berdampingan (katalog kiri, keranjang kanan).
        // Di HP Android (< 800px) tampil 1 kolom memanjang ke bawah agar nyaman digulir.
        return LayoutBuilder(
          builder: (context, ukuran) {
            final layarLebar = ukuran.maxWidth >= 900;

            if (layarLebar) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: ListView(
                      padding: const EdgeInsets.all(12),
                      children: _daftarKartuKatalog(
                        context,
                        kasir,
                        state.daftarProduk,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: SingleChildScrollView(
                      child: KeranjangPanel(
                        controller: kasir,
                        onSelesaiTransaksi: () =>
                            _selesaikanTransaksi(context, kasir),
                      ),
                    ),
                  ),
                ],
              );
            }

            return ListView(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: _daftarKartuKatalog(
                      context,
                      kasir,
                      state.daftarProduk,
                    ),
                  ),
                ),
                KeranjangPanel(
                  controller: kasir,
                  onSelesaiTransaksi: () =>
                      _selesaikanTransaksi(context, kasir),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// #DaftarKatalog — Mengubah list `Produk` menjadi deretan kartu yang siap diketuk kasir.
  List<Widget> _daftarKartuKatalog(
    BuildContext context,
    KasirController kasir,
    List<Produk> daftar,
  ) {
    final theme = Theme.of(context);

    return daftar.map((produk) {
      final habis = produk.stok <= 0;

      return Card(
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          enabled: !habis,
          onTap: habis ? null : () => _pilihBarang(context, kasir, produk),
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.secondaryContainer,
            child: const Icon(Icons.add_shopping_cart),
          ),
          title: Text(
            produk.nama,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '${FormatRupiah.dari(produk.harga)} • Stok: ${produk.stok}',
          ),
          // #LencanaQty — Hanya lencana kecil ini yang dibungkus `Obx` agar hemat render.
          trailing: Obx(() {
            final qty = kasir.qtyProduk(produk.id);
            if (qty == 0) {
              return Icon(
                habis ? Icons.block : Icons.add_circle_outline,
                color: habis
                    ? theme.colorScheme.outline
                    : theme.colorScheme.primary,
              );
            }
            return Badge(
              label: Text('$qty dipilih'),
              backgroundColor: theme.colorScheme.primary,
            );
          }),
        ),
      );
    }).toList();
  }
}
