import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/produk.dart';

/// #LayananProduk — Pengelola penyimpanan data barang secara permanen.
/// Mirip `localStorage.setItem('daftar_produk_v1', JSON.stringify(daftar))` di
/// JavaScript atau menyimpan JSON ke file/session di PHP: saat aplikasi ditutup
/// maupun browser di-refresh, stok dan daftar barang tetap utuh!
class ProdukService {
  ProdukService();

  static const String _kunciSimpan = 'daftar_produk_v1';

  /// #DataContoh — 10 barang bawaan yang dipakai saat aplikasi pertama kali dibuka atau di-reset.
  static const List<Produk> _dataAwal = [
    Produk(id: 'p1', nama: 'Kopi Susu Gula Aren', harga: 18000, stok: 25),
    Produk(id: 'p2', nama: 'Teh Tarik Dingin', harga: 12000, stok: 30),
    Produk(id: 'p3', nama: 'Roti Bakar Cokelat', harga: 15000, stok: 15),
    Produk(id: 'p4', nama: 'Kentang Goreng', harga: 14000, stok: 20),
    Produk(id: 'p5', nama: 'Es Cokelat Klasik', harga: 16000, stok: 22),
    Produk(id: 'p6', nama: 'Matcha Latte Dingin', harga: 20000, stok: 18),
    Produk(id: 'p7', nama: 'Pisang Goreng Keju', harga: 13000, stok: 16),
    Produk(id: 'p8', nama: 'Mie Goreng Spesial', harga: 17000, stok: 20),
    Produk(id: 'p9', nama: 'Nasi Ayam Sambal Matah', harga: 22000, stok: 12),
    Produk(id: 'p10', nama: 'Air Mineral Dingin', harga: 5000, stok: 40),
  ];

  SharedPreferences? _prefs;
  List<Produk> _daftarProduk = [];
  bool _sudahDimuat = false;

  /// #SiapkanPenyimpanan — Membuka koneksi ke `shared_preferences` dan membaca JSON.
  Future<void> _pastikanSiap() async {
    if (_sudahDimuat) return;

    final prefs = _prefs ??= await SharedPreferences.getInstance();
    final jsonMentah = prefs.getString(_kunciSimpan);

    if (jsonMentah == null) {
      // Pertama kali dibuka: isi dengan 10 produk contoh lalu langsung simpan.
      _daftarProduk = List<Produk>.of(_dataAwal);
      await _simpanKeLokal();
    } else {
      final listMap = jsonDecode(jsonMentah) as List<dynamic>;
      _daftarProduk = listMap
          .map((item) => Produk.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList();
    }

    _sudahDimuat = true;
  }

  /// #SimpanKeLokal — Mengubah list `Produk` menjadi teks JSON lalu menulisnya ke perangkat.
  /// Mirip `localStorage.setItem(...)` + `JSON.stringify(...)` di JavaScript.
  Future<void> _simpanKeLokal() async {
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    final jsonTeks = jsonEncode(_daftarProduk.map((p) => p.toMap()).toList());
    await prefs.setString(_kunciSimpan, jsonTeks);
  }

  /// #AmbilSemua — Memuat seluruh produk dari penyimpanan lokal.
  Future<List<Produk>> ambilSemua() async {
    await _pastikanSiap();
    return List<Produk>.unmodifiable(_daftarProduk);
  }

  /// #TambahProduk — Menambah barang baru lalu menyimpannya ke `shared_preferences`.
  Future<List<Produk>> tambah(Produk produk) async {
    await _pastikanSiap();
    _daftarProduk.add(produk);
    await _simpanKeLokal();
    return List<Produk>.unmodifiable(_daftarProduk);
  }

  /// #UbahProduk — Memperbarui barang berdasarkan `id` lalu menyimpannya ke lokal.
  Future<List<Produk>> ubah(Produk produkBaru) async {
    await _pastikanSiap();
    final index = _daftarProduk.indexWhere((p) => p.id == produkBaru.id);
    if (index != -1) {
      _daftarProduk[index] = produkBaru;
      await _simpanKeLokal();
    }
    return List<Produk>.unmodifiable(_daftarProduk);
  }

  /// #HapusProduk — Menghapus barang berdasarkan `id` lalu menyimpannya ke lokal.
  Future<List<Produk>> hapus(String id) async {
    await _pastikanSiap();
    _daftarProduk.removeWhere((p) => p.id == id);
    await _simpanKeLokal();
    return List<Produk>.unmodifiable(_daftarProduk);
  }

  /// #KurangiStokTransaksi — Memotong stok beberapa barang sekaligus setelah kasir
  /// menyelesaikan pembayaran (`{ idProduk: jumlahTerjual }`).
  /// Mirip query `UPDATE produk SET stok = stok - qty WHERE id = ...` di PHP/SQL.
  Future<List<Produk>> kurangiStokBatch(Map<String, int> terjualPerId) async {
    await _pastikanSiap();

    for (var i = 0; i < _daftarProduk.length; i++) {
      final lama = _daftarProduk[i];
      final terjual = terjualPerId[lama.id] ?? 0;
      if (terjual <= 0) continue;

      final sisaBaru = lama.stok - terjual;
      _daftarProduk[i] = lama.copyWith(stok: sisaBaru < 0 ? 0 : sisaBaru);
    }

    await _simpanKeLokal();
    return List<Produk>.unmodifiable(_daftarProduk);
  }

  /// #ResetDataAwal — Mengembalikan daftar barang ke 10 produk contoh bawaan.
  /// Sangat berguna saat latihan/demo seperti perintah `php artisan migrate:fresh --seed`.
  Future<List<Produk>> resetDataAwal() async {
    _daftarProduk = List<Produk>.of(_dataAwal);
    _sudahDimuat = true;
    await _simpanKeLokal();
    return List<Produk>.unmodifiable(_daftarProduk);
  }
}
