import 'package:flutter/material.dart';

/// #TemaAplikasi — Kumpulan aturan warna dan gaya tampilan.
/// Mirip file `style.css` global: satu tempat untuk mengubah "wajah" aplikasi.
class AppTheme {
  const AppTheme._();

  /// #WarnaUtama — Warna dasar hijau toko yang dipakai seluruh aplikasi.
  static const Color seed = Color(0xFF2F6B4F);

  /// #TemaTerang — Tema Material 3 yang dipakai Android dan web.
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(seedColor: seed);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.primaryContainer,
      ),
    );
  }
}
