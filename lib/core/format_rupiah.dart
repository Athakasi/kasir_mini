import 'package:intl/intl.dart';

/// #FormatRupiah — Pengubah angka biasa (`18000`) menjadi teks Rupiah (`Rp 18.000`).
/// Mirip `'Rp ' . number_format($angka, 0, ',', '.')` di PHP atau
/// `Intl.NumberFormat('id-ID')` di JavaScript.
class FormatRupiah {
  const FormatRupiah._();

  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  /// #DariAngka — Mengembalikan string Rupiah rapi tanpa angka desimal di belakang.
  static String dari(int nominal) => _formatter.format(nominal);
}
