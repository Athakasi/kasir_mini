import 'package:equatable/equatable.dart';

import '../models/transaksi.dart';

/// #StateRiwayat — Wadah keadaan daftar riwayat transaksi di toko.
/// Mirip variabel `$riwayat` dan `$totalOmzet` yang dikirim Controller ke View di Laravel.
class RiwayatState extends Equatable {
  const RiwayatState({
    this.daftarTransaksi = const [],
    this.sedangMemuat = false,
  });

  final List<Transaksi> daftarTransaksi;
  final bool sedangMemuat;

  /// #TotalOmzet — Penjumlahan seluruh `totalBayar` dari semua nota yang tercatat.
  /// Mirip `Transaction::sum('total_bayar')` di Laravel atau `.reduce()` di JS.
  int get totalOmzet =>
      daftarTransaksi.fold<int>(0, (sum, trx) => sum + trx.totalBayar);

  RiwayatState copyWith({
    List<Transaksi>? daftarTransaksi,
    bool? sedangMemuat,
  }) {
    return RiwayatState(
      daftarTransaksi: daftarTransaksi ?? this.daftarTransaksi,
      sedangMemuat: sedangMemuat ?? this.sedangMemuat,
    );
  }

  @override
  List<Object?> get props => [daftarTransaksi, sedangMemuat];
}
