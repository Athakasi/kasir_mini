import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../cubit/produk_cubit.dart';
import '../getx/kasir_controller.dart';
import 'kasir_screen.dart';
import 'stok_screen.dart';

/// #RumahAplikasi — Kerangka utama dengan AppBar & menu bawah (bottom navigation).
/// Mirip `layout.php` di PHP: isi halaman berganti-ganti, tetapi menu dan
/// kerangkanya tetap sama.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const List<String> _judul = ['Stok Barang', 'Kasir'];

  void _gantiTab(int index) {
    setState(() => _index = index);
  }

  /// #KonfirmasiReset — Mengembalikan 4 barang contoh awal jika pengguna ingin mulai ulang latihan.
  Future<void> _konfirmasiResetContoh(BuildContext context) async {
    final cubit = context.read<ProdukCubit>();
    final kasir = Get.find<KasirController>();
    final messenger = ScaffoldMessenger.of(context);

    final yakin = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Reset Data Contoh?'),
        content: const Text(
          'Daftar stok akan dikembalikan ke 4 barang awal dan keranjang dikosongkan.',
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
        children: const [StokScreen(), KasirScreen()],
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
            // #LencanaTabKasir — Menampilkan angka total item keranjang secara live memakai `Obx`.
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
