import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/item_keranjang.dart';
import '../models/produk.dart';
import '../services/produk_service.dart';
import 'produk_state.dart';

/// #CubitProduk — Pengatur alur data ("Controller" di pola MVC) untuk Halaman Stok.
/// Semua fungsi sekarang `async` karena membaca & menulis ke `shared_preferences`
/// mirip fungsi `async/await` saat memanggil API / `localStorage` di JavaScript.
class ProdukCubit extends Cubit<ProdukState> {
  ProdukCubit(this._service) : super(const ProdukState());

  final ProdukService _service;

  /// #MuatProduk — Mengambil semua barang dari penyimpanan lokal lalu mengirimnya ke layar.
  Future<void> muatProduk() async {
    emit(state.copyWith(sedangMemuat: true));
    final daftar = await _service.ambilSemua();
    emit(ProdukState(daftarProduk: daftar, sedangMemuat: false));
  }

  /// #TambahProduk — Membuat `Produk` baru, menyimpannya ke lokal, lalu memancarkan state.
  Future<void> tambahProduk({
    required String nama,
    required int harga,
    required int stok,
  }) async {
    final produkBaru = Produk(
      id: 'p_${DateTime.now().microsecondsSinceEpoch}',
      nama: nama.trim(),
      harga: harga,
      stok: stok,
    );
    final daftar = await _service.tambah(produkBaru);
    emit(state.copyWith(daftarProduk: daftar));
  }

  /// #UbahProduk — Memperbarui produk di penyimpanan lokal lalu memancarkan daftar terbaru.
  Future<void> ubahProduk(Produk produkDiubah) async {
    final daftar = await _service.ubah(produkDiubah);
    emit(state.copyWith(daftarProduk: daftar));
  }

  /// #HapusProduk — Menghapus barang berdasarkan `id` di penyimpanan lokal.
  Future<void> hapusProduk(String id) async {
    final daftar = await _service.hapus(id);
    emit(state.copyWith(daftarProduk: daftar));
  }

  /// #PotongStokTransaksi — Dipanggil setelah transaksi Kasir (GetX) berhasil:
  /// mengurangi stok setiap barang yang dibeli lalu memperbarui seluruh layar!
  Future<void> kurangiStokSetelahTransaksi(
    List<ItemKeranjang> itemDibeli,
  ) async {
    if (itemDibeli.isEmpty) return;

    final terjualPerId = <String, int>{
      for (final item in itemDibeli) item.produk.id: item.qty,
    };

    final daftar = await _service.kurangiStokBatch(terjualPerId);
    emit(state.copyWith(daftarProduk: daftar));
  }

  /// #ResetContoh — Mengembalikan stok ke 10 data contoh awal lalu memperbarui layar.
  Future<void> resetKeDataAwal() async {
    final daftar = await _service.resetDataAwal();
    emit(state.copyWith(daftarProduk: daftar));
  }
}
