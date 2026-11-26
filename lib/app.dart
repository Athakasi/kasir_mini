import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import 'core/app_theme.dart';
import 'cubit/produk_cubit.dart';
import 'cubit/riwayat_cubit.dart';
import 'getx/kasir_controller.dart';
import 'screens/home_screen.dart';
import 'services/produk_service.dart';
import 'services/transaksi_service.dart';

/// #AkarAplikasi — Bungkus utama seluruh aplikasi.
/// Mirip `App.vue` / root component di React: mengatur judul, tema, provider
/// data global, dan halaman pertama yang tampil.
class KasirMiniApp extends StatelessWidget {
  const KasirMiniApp({super.key});

  @override
  Widget build(BuildContext context) {
    // #PasangGetX — `Get.isRegistered` memastikan controller hanya didaftarkan
    // sekali ke memori GetX (mirip Singleton Service di Laravel).
    if (!Get.isRegistered<KasirController>()) {
      Get.put(KasirController());
    }

    // #MultiProviderCubit — Saat kita punya lebih dari 1 Cubit, `MultiBlocProvider`
    // menggabungkannya dengan rapi tanpa tumpukan kurung bersarang (mirip mendaftarkan
    // beberapa provider sekaligus di `AppServiceProvider` Laravel).
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ProdukCubit(ProdukService())..muatProduk()),
        BlocProvider(
          create: (_) => RiwayatCubit(TransaksiService())..muatRiwayat(),
        ),
      ],
      child: GetMaterialApp(
        title: 'Kasir Mini',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const HomeScreen(),
      ),
    );
  }
}
