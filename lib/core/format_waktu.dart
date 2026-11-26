import 'package:intl/intl.dart';

/// #FormatWaktu — Pengubah objek `DateTime` menjadi teks tanggal, jam, dan nomor nota.
/// Mirip fungsi `date('d/m/Y • H:i', $timestamp)` di PHP atau `dayjs(waktu).format(...)` di JS.
class FormatWaktu {
  const FormatWaktu._();

  static final DateFormat _formatTanggalJam = DateFormat('dd/MM/yyyy • HH:mm');
  static final DateFormat _formatKodeNota = DateFormat('yyMMdd-HHmmss');

  /// #TeksLengkap — Contoh hasil: `26/11/2026 • 22:25`.
  static String tanggalJam(DateTime waktu) => _formatTanggalJam.format(waktu);

  /// #BuatNomorNota — Contoh hasil: `INV-261126-222510`.
  static String buatNomorNota(DateTime waktu) =>
      'INV-${_formatKodeNota.format(waktu)}';
}
