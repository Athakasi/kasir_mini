import 'package:equatable/equatable.dart';

import '../models/produk.dart';

/// #StateProduk — Wadah "keadaan" (state) halaman Stok pada satu waktu.
/// Mirip variabel `$data` yang dikirim Controller ke View di Laravel (`view('stok', $data)`)
/// atau objek `state` di Redux / React (`{ daftarProduk: [...], sedangMemuat: false }`).
///
/// Setiap kali `ProdukState` diganti yang baru, layar yang mendengarkan Cubit
/// otomatis menggambar ulang dirinya sesuai isi terbaru.
class ProdukState extends Equatable {
  const ProdukState({
    this.daftarProduk = const [],
    this.sedangMemuat = false,
  });

  final List<Produk> daftarProduk;
  final bool sedangMemuat;

  /// #SalinState — Membuat state baru dengan mengubah sebagian isinya saja.
  /// Mirip `{ ...state, daftarProduk: baru }` di JavaScript.
  ProdukState copyWith({
    List<Produk>? daftarProduk,
    bool? sedangMemuat,
  }) {
    return ProdukState(
      daftarProduk: daftarProduk ?? this.daftarProduk,
      sedangMemuat: sedangMemuat ?? this.sedangMemuat,
    );
  }

  @override
  List<Object?> get props => [daftarProduk, sedangMemuat];
}
