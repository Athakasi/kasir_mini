import 'package:equatable/equatable.dart';

/// #ModelProduk — Cetakan struktur data untuk satu barang di toko.
/// Mirip `class Produk` di PHP (Eloquent Model / DTO) atau objek `{ id, nama, harga, stok }`
/// di JavaScript: memastikan setiap barang punya atribut dan tipe data yang konsisten.
///
/// Kita memakai `Equatable` supaya dua objek `Produk` dengan isi yang sama
/// dianggap sama oleh Dart (mirip `JSON.stringify(a) === JSON.stringify(b)` di JS).
class Produk extends Equatable {
  const Produk({
    required this.id,
    required this.nama,
    required this.harga,
    required this.stok,
  });

  final String id;
  final String nama;
  final int harga;
  final int stok;

  /// #SalinDengan — Membuat objek `Produk` baru dengan sebagian nilai yang diubah.
  /// Mirip spread operator `{ ...produk, stok: 10 }` di JavaScript.
  /// Di Flutter (terutama Cubit), data sebaiknya tidak diubah langsung (immutable),
  /// melainkan diganti dengan salinan baru agar layar tahu kapan harus digambar ulang.
  Produk copyWith({
    String? id,
    String? nama,
    int? harga,
    int? stok,
  }) {
    return Produk(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      harga: harga ?? this.harga,
      stok: stok ?? this.stok,
    );
  }

  /// #KeMap — Mengubah objek `Produk` menjadi `Map` (pasangan key-value).
  /// Mirip `json_encode` / `$produk->toArray()` di PHP atau objek literal di JS,
  /// berguna saat nanti menyimpan data ke `shared_preferences` (Langkah 6).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'harga': harga,
      'stok': stok,
    };
  }

  /// #DariMap — Membuat objek `Produk` dari data `Map` (hasil baca JSON).
  /// Mirip `json_decode` di PHP atau `JSON.parse` di JavaScript.
  factory Produk.fromMap(Map<String, dynamic> map) {
    return Produk(
      id: map['id'] as String,
      nama: map['nama'] as String,
      harga: map['harga'] as int,
      stok: map['stok'] as int,
    );
  }

  @override
  List<Object?> get props => [id, nama, harga, stok];
}
