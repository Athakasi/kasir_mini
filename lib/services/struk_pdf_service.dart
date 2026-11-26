import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../core/format_rupiah.dart';
import '../core/format_waktu.dart';
import '../models/transaksi.dart';

/// #LayananPdfStruk — Penyusun dokumen PDF struk belanja ukuran kertas gulung 80mm.
///
/// Analogi Web / PHP:
/// - Paket `pdf` (`pw.*`) mirip library **Dompdf / FPDF** di PHP: menyusun halaman
///   dokumen di memori lalu menghasilkan byte PDF (`Uint8List`).
/// - Paket `printing` mirip **`window.print()`** di JavaScript: mengirim byte PDF
///   tersebut ke jendela cetak bawaan browser (Web) atau Print Service HP (Android).
///
/// Kita memberi alias `as pw` (pdf widgets) supaya nama `pw.Text`, `pw.Column`,
/// dan `pw.Row` tidak tertukar dengan widget tampilan Flutter biasa.
class StrukPdfService {
  const StrukPdfService._();

  /// #BuatBytePdf — Menyusun tata letak kertas struk gulung 80mm dari data `Transaksi`.
  static Future<Uint8List> buatDokumenPdf(Transaksi transaksi) async {
    final doc = pw.Document(title: transaksi.id);

    // Ganti simbol bullet `•` menjadi `-` agar aman memakai font standar PDF tanpa internet.
    final waktuTeks = FormatWaktu.tanggalJam(
      transaksi.waktu,
    ).replaceAll('•', '-');

    // `PdfPageFormat.roll80` adalah ukuran standar kertas struk kasir lebar 80mm
    // dengan panjang mengikuti isi belanjaan secara otomatis.
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Text(
                'KASIR MINI',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'No: ${transaksi.id}',
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                waktuTeks,
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              ...transaksi.items.map(
                (item) => pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: [
                      pw.Text(
                        item.produk.nama,
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            '${item.qty} x ${FormatRupiah.dari(item.produk.harga)}',
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                          pw.Text(
                            FormatRupiah.dari(item.subtotal),
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              _barisPdf('Subtotal', FormatRupiah.dari(transaksi.subtotal)),
              if (transaksi.diskonPersen > 0)
                _barisPdf(
                  'Diskon (${transaksi.diskonPersen}%)',
                  '- ${FormatRupiah.dari(transaksi.nominalDiskon)}',
                ),
              _barisPdf(
                'TOTAL BAYAR',
                FormatRupiah.dari(transaksi.totalBayar),
                tebal: true,
              ),
              pw.SizedBox(height: 2),
              _barisPdf('Tunai', FormatRupiah.dari(transaksi.uangBayar)),
              _barisPdf(
                'Kembalian',
                FormatRupiah.dari(transaksi.kembalian),
                tebal: true,
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Terima kasih telah berbelanja!',
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 9),
              ),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  /// #CetakStruk — Membuka dialog Print bawaan browser (Web) atau Android Print Service.
  static Future<void> cetak(Transaksi transaksi) async {
    await Printing.layoutPdf(
      name: '${transaksi.id}.pdf',
      format: PdfPageFormat.roll80,
      onLayout: (_) => buatDokumenPdf(transaksi),
    );
  }

  /// #BagikanPdf — Mengunduh file `.pdf` di Web atau membuka menu Share (WhatsApp, dll) di Android.
  static Future<void> bagikanAtauUnduh(Transaksi transaksi) async {
    final bytes = await buatDokumenPdf(transaksi);
    await Printing.sharePdf(
      bytes: bytes,
      filename: '${transaksi.id}.pdf',
    );
  }

  static pw.Widget _barisPdf(
    String label,
    String nilai, {
    bool tebal = false,
  }) {
    final gaya = pw.TextStyle(
      fontSize: tebal ? 10 : 9,
      fontWeight: tebal ? pw.FontWeight.bold : pw.FontWeight.normal,
    );

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: gaya),
          pw.Text(nilai, style: gaya),
        ],
      ),
    );
  }
}
