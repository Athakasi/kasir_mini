import 'package:flutter_test/flutter_test.dart';
import 'package:kasir_mini/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// #TesDasar — Satu file tes sederhana & ringkas agar `flutter test` di GitHub Actions tetap hijau.
/// Memastikan ketiga tab (Stok, Kasir, Riwayat) beserta Cubit & GetX berjalan lancar.
void main() {
  testWidgets('Tiga tab utama tampil dan keranjang GetX merespons klik barang', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const KasirMiniApp());
    await tester.pumpAndSettle();

    expect(find.text('Jenis Barang'), findsOneWidget);
    expect(find.text('Kopi Susu Gula Aren'), findsOneWidget);

    await tester.tap(find.text('Kasir'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Kopi Susu Gula Aren'));
    await tester.pump();
    expect(find.text('1 dipilih'), findsOneWidget);

    await tester.tap(find.text('Riwayat'));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada riwayat transaksi'), findsOneWidget);
  });
}
