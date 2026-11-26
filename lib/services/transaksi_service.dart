import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/transaksi.dart';

/// #LayananTransaksi — Pengelola penyimpanan riwayat nota/struk ke `shared_preferences`.
/// Mirip `TransactionRepository` di Laravel atau penyimpanan `localStorage.getItem('daftar_transaksi_v1')`
/// di JavaScript: memisahkan urusan baca-tulis JSON dari tampilan layar.
class TransaksiService {
  TransaksiService();

  static const String _kunciSimpan = 'daftar_transaksi_v1';

  SharedPreferences? _prefs;
  List<Transaksi> _daftarTransaksi = [];
  bool _sudahDimuat = false;

  /// #PastikanSiap — Membaca data JSON riwayat transaksi saat pertama kali dibutuhkan.
  Future<void> _pastikanSiap() async {
    if (_sudahDimuat) return;

    final prefs = _prefs ??= await SharedPreferences.getInstance();
    final jsonMentah = prefs.getString(_kunciSimpan);

    if (jsonMentah != null && jsonMentah.isNotEmpty) {
      final listMap = jsonDecode(jsonMentah) as List<dynamic>;
      _daftarTransaksi = listMap
          .map((e) => Transaksi.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    _sudahDimuat = true;
  }

  /// #SimpanKeLokal — Mengubah seluruh riwayat transaksi menjadi teks JSON lalu menyimpannya.
  Future<void> _simpanKeLokal() async {
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    final jsonTeks = jsonEncode(
      _daftarTransaksi.map((t) => t.toMap()).toList(),
    );
    await prefs.setString(_kunciSimpan, jsonTeks);
  }

  /// #AmbilSemua — Mengembalikan daftar riwayat transaksi (urutan terbaru di paling atas).
  /// Mirip `Transaction::latest()->get()` di Laravel.
  Future<List<Transaksi>> ambilSemua() async {
    await _pastikanSiap();
    return List<Transaksi>.unmodifiable(_daftarTransaksi);
  }

  /// #SimpanTransaksi — Menaruh nota baru di urutan paling atas (`insert(0, ...)`).
  /// Mirip `array_unshift($riwayat, $nota)` di PHP atau `riwayat.unshift(nota)` di JS.
  Future<List<Transaksi>> simpanBaru(Transaksi transaksi) async {
    await _pastikanSiap();
    _daftarTransaksi.insert(0, transaksi);
    await _simpanKeLokal();
    return List<Transaksi>.unmodifiable(_daftarTransaksi);
  }

  /// #BersihkanRiwayat — Menghapus seluruh catatan riwayat transaksi dari penyimpanan lokal.
  Future<List<Transaksi>> hapusSemua() async {
    _daftarTransaksi = [];
    _sudahDimuat = true;
    await _simpanKeLokal();
    return const [];
  }
}
