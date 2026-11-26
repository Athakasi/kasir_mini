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

  @override
  List<Object?> get props => [produk, qty];
}
