import 'package:equatable/equatable.dart';

import 'produk.dart';

/// #ModelItemKeranjang — Cetakan satu baris barang yang masuk ke keranjang belanja.
/// Mirip objek `{ produk: {...}, qty: 2 }` di keranjang belanja JavaScript/PHP Session:
/// menyimpan referensi barang beserta jumlah belinya (`qty`).
class ItemKeranjang extends Equatable {
  const ItemKeranjang({
    required this.produk,
    required this.qty,
  });

  final Produk produk;
  final int qty;

  /// #SubtotalItem — Harga satuan dikali jumlah beli.
  /// Mirip computed property `get subtotal()` di class JS/PHP.
  int get subtotal => produk.harga * qty;

  /// #SalinItem — Membuat salinan item dengan `produk` atau `qty` yang diperbarui.
  ItemKeranjang copyWith({
    Produk? produk,
    int? qty,
  }) {
    return ItemKeranjang(
      produk: produk ?? this.produk,
      qty: qty ?? this.qty,
    );
  }

  /// #KeMap — Mengubah 1 baris item belanja menjadi `Map` agar bisa disimpan ke dalam JSON struk.
  /// Menyimpan "snapshot" nama & harga produk saat transaksi terjadi (mirip tabel
  /// `transaction_items` di MySQL/Laravel) supaya riwayat struk lama tidak berubah
  /// walaupun harga barang di masa depan dinaikkan.
  Map<String, dynamic> toMap() {
    return {
      'produk': produk.toMap(),
      'qty': qty,
    };
  }

  /// #DariMap — Membentuk kembali `ItemKeranjang` dari data JSON struk yang tersimpan.
  factory ItemKeranjang.fromMap(Map<String, dynamic> map) {
    return ItemKeranjang(
      produk: Produk.fromMap(Map<String, dynamic>.from(map['produk'] as Map)),
      qty: map['qty'] as int,
    );
  }

  @override
  List<Object?> get props => [produk, qty];
}
