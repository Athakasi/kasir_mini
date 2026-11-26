import 'package:equatable/equatable.dart';

import 'item_keranjang.dart';

/// #ModelTransaksi — Cetakan data lengkap untuk satu lembar struk/nota pembayaran.
/// Mirip gabungan tabel `transactions` dan relasi `items` di Laravel (`Transaction::with('items')`),
/// atau objek nota JSON di aplikasi kasir JavaScript.
class Transaksi extends Equatable {
  const Transaksi({
    required this.id,
    required this.waktu,
    required this.items,
    required this.subtotal,
    required this.diskonPersen,
    required this.nominalDiskon,
    required this.totalBayar,
    required this.uangBayar,
    required this.kembalian,
  });

  /// Nomor nota unik (contoh: `INV-104215`).
  final String id;
  final DateTime waktu;
  final List<ItemKeranjang> items;
  final int subtotal;
  final int diskonPersen;
  final int nominalDiskon;
  final int totalBayar;
  final int uangBayar;
  final int kembalian;

  /// #TotalQty — Jumlah seluruh unit barang yang dibeli dalam satu nota ini.
  int get totalQty => items.fold<int>(0, (sum, item) => sum + item.qty);

  /// #KeMap — Mengubah objek `Transaksi` menjadi `Map` siap di-encode ke JSON.
  /// `waktu` disimpan sebagai teks standar ISO-8601 (mirip `new Date().toISOString()` di JS).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'waktu': waktu.toIso8601String(),
      'items': items.map((i) => i.toMap()).toList(),
      'subtotal': subtotal,
      'diskonPersen': diskonPersen,
      'nominalDiskon': nominalDiskon,
      'totalBayar': totalBayar,
      'uangBayar': uangBayar,
      'kembalian': kembalian,
    };
  }

  /// #DariMap — Membaca `Map` hasil `jsonDecode` kembali menjadi objek `Transaksi`.
  factory Transaksi.fromMap(Map<String, dynamic> map) {
    final listItems = (map['items'] as List<dynamic>)
        .map((e) => ItemKeranjang.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();

    return Transaksi(
      id: map['id'] as String,
      waktu: DateTime.parse(map['waktu'] as String),
      items: List<ItemKeranjang>.unmodifiable(listItems),
      subtotal: map['subtotal'] as int,
      diskonPersen: map['diskonPersen'] as int,
      nominalDiskon: map['nominalDiskon'] as int,
      totalBayar: map['totalBayar'] as int,
      uangBayar: map['uangBayar'] as int,
      kembalian: map['kembalian'] as int,
    );
  }

  @override
  List<Object?> get props => [
        id,
        waktu,
        items,
        subtotal,
        diskonPersen,
        nominalDiskon,
        totalBayar,
        uangBayar,
        kembalian,
      ];
}
