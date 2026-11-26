import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/format_waktu.dart';
import '../models/item_keranjang.dart';
import '../models/transaksi.dart';
import '../services/transaksi_service.dart';
import 'riwayat_state.dart';

/// #CubitRiwayat — Pengatur alur pencatatan dan pembacaan nota transaksi.
/// Mirip `TransactionController` di Laravel: menerima data dari halaman Kasir,
/// membuat objek `Transaksi`, menyimpannya lewat `TransaksiService`, lalu
/// memancarkan daftar riwayat terbaru ke seluruh layar.
class RiwayatCubit extends Cubit<RiwayatState> {
  RiwayatCubit(this._service) : super(const RiwayatState());

  final TransaksiService _service;

  /// #MuatRiwayat — Membaca seluruh daftar transaksi tersimpan saat aplikasi dibuka.
  Future<void> muatRiwayat() async {
    emit(state.copyWith(sedangMemuat: true));
    final daftar = await _service.ambilSemua();
    emit(RiwayatState(daftarTransaksi: daftar, sedangMemuat: false));
  }

  /// #CatatTransaksi — Membuat satu struk baru, menyimpannya ke lokal, lalu
  /// mengembalikan objek `Transaksi` tersebut agar langsung bisa ditampilkan di modal struk.
  Future<Transaksi> catatTransaksi({
    required List<ItemKeranjang> items,
    required int subtotal,
    required int diskonPersen,
    required int nominalDiskon,
    required int totalBayar,
    required int uangBayar,
    required int kembalian,
  }) async {
    final sekarang = DateTime.now();
    final notaBaru = Transaksi(
      id: FormatWaktu.buatNomorNota(sekarang),
      waktu: sekarang,
      items: List<ItemKeranjang>.unmodifiable(items),
      subtotal: subtotal,
      diskonPersen: diskonPersen,
      nominalDiskon: nominalDiskon,
      totalBayar: totalBayar,
      uangBayar: uangBayar,
      kembalian: kembalian,
    );

    final daftar = await _service.simpanBaru(notaBaru);
    emit(state.copyWith(daftarTransaksi: daftar));
    return notaBaru;
  }

  /// #HapusSemuaRiwayat — Mengosongkan semua catatan transaksi dari penyimpanan.
  Future<void> hapusSemuaRiwayat() async {
    final daftar = await _service.hapusSemua();
    emit(state.copyWith(daftarTransaksi: daftar));
  }
}
