import 'package:flutter_test/flutter_test.dart';
import 'package:kasir_mini/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// #TesDasar — Satu file tes sederhana & ringkas agar `flutter test` di GitHub Actions tetap hijau.
/// Memastikan ringkasan stok (Cubit) muncul dan barang bisa dimasukkan ke keranjang (GetX).
void main() {
  testWidgets('Stok Cubit tampil dan keranjang GetX merespons klik barang', (
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

    expect(find.text('Keranjang (1 jenis)'), findsOneWidget);
  });
}
