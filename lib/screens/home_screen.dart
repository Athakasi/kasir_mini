import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../cubit/produk_cubit.dart';
import '../cubit/riwayat_cubit.dart';
import '../cubit/riwayat_state.dart';
import '../getx/kasir_controller.dart';
import 'kasir_screen.dart';
import 'riwayat_screen.dart';
import 'stok_screen.dart';

/// #RumahAplikasi — Kerangka utama dengan AppBar & menu bawah 3 tab (Stok, Kasir, Riwayat).
/// Mirip `layout.php` di PHP: isi halaman berganti-ganti, tetapi menu dan
/// kerangkanya tetap sama.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const List<String> _judul = [
    'Stok Barang',
    'Kasir',
    'Riwayat Transaksi',
  ];

  void _gantiTab(int index) {
    setState(() => _index = index);
  }

  /// #KonfirmasiReset — Mengembalikan 10 barang contoh awal jika pengguna ingin mulai ulang latihan.
  Future<void> _konfirmasiResetContoh(BuildContext context) async {
    final cubit = context.read<ProdukCubit>();
    final kasir = Get.find<KasirController>();
    final messenger = ScaffoldMessenger.of(context);

    final yakin = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Reset Data Contoh?'),
        content: const Text(
          'Daftar stok akan dikembalikan ke 10 barang awal dan keranjang dikosongkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (yakin != true) return;

    kasir.kosongkanTransaksi();
    await cubit.resetKeDataAwal();
    messenger.showSnackBar(
      const SnackBar(content: Text('Data contoh berhasil dikembalikan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kasir = Get.find<KasirController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_judul[_index]),
        actions: [
          IconButton(
            tooltip: 'Reset data contoh',
            icon: const Icon(Icons.restart_alt),
            onPressed: () => _konfirmasiResetContoh(context),
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: const [StokScreen(), KasirScreen(), RiwayatScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _gantiTab,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Stok',
          ),
          NavigationDestination(
            // #LencanaTabKasir — Angka jumlah item keranjang secara live memakai `Obx` (GetX).
            icon: _IkonKasirBerlencana(
              kasir: kasir,
              ikon: Icons.point_of_sale_outlined,
            ),
            selectedIcon: _IkonKasirBerlencana(
              kasir: kasir,
              ikon: Icons.point_of_sale,
            ),
            label: 'Kasir',
          ),
          const NavigationDestination(
            // #LencanaTabRiwayat — Angka jumlah nota tersimpan memakai `BlocBuilder` (Cubit).
            icon: _IkonRiwayatBerlencana(ikon: Icons.receipt_long_outlined),
            selectedIcon: _IkonRiwayatBerlencana(ikon: Icons.receipt_long),
            label: 'Riwayat',
          ),
        ],
      ),
    );
  }
}

class _IkonKasirBerlencana extends StatelessWidget {
  const _IkonKasirBerlencana({
    required this.kasir,
    required this.ikon,
  });

  final KasirController kasir;
  final IconData ikon;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final totalQty = kasir.keranjang.fold<int>(0, (s, i) => s + i.qty);
      return Badge(
        isLabelVisible: totalQty > 0,
        label: Text('$totalQty'),
        child: Icon(ikon),
      );
    });
  }
}

class _IkonRiwayatBerlencana extends StatelessWidget {
  const _IkonRiwayatBerlencana({required this.ikon});

  final IconData ikon;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RiwayatCubit, RiwayatState>(
      builder: (context, state) {
        final jumlahNota = state.daftarTransaksi.length;
        return Badge(
          isLabelVisible: jumlahNota > 0,
          label: Text('$jumlahNota'),
          child: Icon(ikon),
        );
      },
    );
  }
}
