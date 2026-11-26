import 'package:flutter/widgets.dart';

import 'app.dart';

/// #TitikMasuk — Pintu utama aplikasi.
/// Mirip `index.php` di PHP: menyalakan engine Flutter terlebih dahulu dengan
/// `ensureInitialized()` agar plugin penyimpanan lokal (`shared_preferences`)
/// siap dipakai di Android maupun Web sebelum layar digambar.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KasirMiniApp());
}
