# PETA KODE — Kasir Mini

Dokumen ini adalah "denah" proyek. Setiap file dijaga tetap pendek, fokus pada
satu tugas, dan dilengkapi komentar `#Hashtag` serta analogi PHP/JavaScript.

## Rencana Langkah

| Langkah | Isi | Status |
| --- | --- | --- |
| 1 | Fondasi proyek: Android + web, struktur folder MVC, kerangka 2 tab, tema, tes dasar, CI | ✅ Selesai |
| 2 | Model `Produk` + `ProdukService` (data contoh di memori) | ✅ Selesai |
| 3 | Cubit stok: `ProdukState` + `ProdukCubit`, tampilkan daftar produk di Halaman Stok | ✅ Selesai |
| 4 | Form tambah / ubah / hapus produk memakai Cubit | ✅ Selesai |
| 5 | GetX kasir: keranjang, qty, diskon, total, kembalian | ✅ Selesai |
| 6 | Simpan data ke `shared_preferences` + stok berkurang setelah transaksi | ✅ Selesai |
| 7 | Rapikan UI, perbarui tes dasar, finalisasi dokumentasi | ✅ Selesai |

## Struktur Folder

```
lib/
├── main.dart                         # pintu masuk aplikasi
├── app.dart                          # akar aplikasi (BlocProvider + GetMaterialApp)
├── core/
│   ├── app_theme.dart                # tema Material 3 warna hijau toko
│   └── format_rupiah.dart            # pengubah angka ke teks "Rp 18.000"
├── models/
│   ├── produk.dart                   # cetakan data barang
│   └── item_keranjang.dart           # cetakan satu baris item di keranjang
├── services/
│   └── produk_service.dart           # simpan/ambil JSON di shared_preferences
├── cubit/
│   ├── produk_state.dart             # wadah state Halaman Stok
│   └── produk_cubit.dart             # pengatur CRUD & potong stok (Cubit)
├── getx/
│   └── kasir_controller.dart         # keranjang & hitung kembalian reaktif (.obs)
├── screens/
│   ├── home_screen.dart              # kerangka utama + bottom nav berlencana + reset
│   ├── stok_screen.dart              # halaman kelola stok barang
│   └── kasir_screen.dart             # halaman transaksi kasir responsif
└── widgets/
    ├── placeholder_view.dart         # tampilan saat daftar masih kosong
    ├── ringkasan_stok_banner.dart    # kartu ringkasan total jenis, unit, & stok habis
    ├── produk_tile.dart              # kartu satu produk beserta tombol ubah & hapus
    ├── produk_form_dialog.dart       # modal form input tambah / ubah barang
    └── keranjang_panel.dart          # panel keranjang, diskon, uang bayar, & kembalian
```

## Daftar Lengkap Seluruh File

### Inti & Konfigurasi (`lib/` & `lib/core/`)

| File | Fungsi singkat |
| --- | --- |
| `lib/main.dart` | Pintu masuk aplikasi: menyiapkan `ensureInitialized()` lalu memanggil `KasirMiniApp`. |
| `lib/app.dart` | Akar aplikasi: mendaftarkan `KasirController` (GetX), `ProdukCubit` (`BlocProvider`), dan `GetMaterialApp`. |
| `lib/core/app_theme.dart` | Pengaturan tema Material 3 dan skema warna hijau toko. |
| `lib/core/format_rupiah.dart` | Fungsi bantu memformat angka bulat menjadi mata uang `Rp 18.000`. |

### Model & Service (`lib/models/` & `lib/services/`)

| File | Fungsi singkat |
| --- | --- |
| `lib/models/produk.dart` | Cetakan data barang (`id`, `nama`, `harga`, `stok`) lengkap dengan `copyWith`, `toMap`, dan `fromMap`. |
| `lib/models/item_keranjang.dart` | Cetakan satu item belanja (`produk`, `qty`, dan getter `subtotal`). |
| `lib/services/produk_service.dart` | Penyimpanan permanen JSON ke `shared_preferences` (muat, tambah, ubah, hapus, potong stok batch, dan reset contoh). |

### State Management (`lib/cubit/` & `lib/getx/`)

| File | Fungsi singkat |
| --- | --- |
| `lib/cubit/produk_state.dart` | State immutable Halaman Stok berisi `daftarProduk` dan penanda `sedangMemuat`. |
| `lib/cubit/produk_cubit.dart` | Controller Cubit untuk memuat, menambah, mengubah, menghapus, mengurangi stok transaksi, dan mereset data contoh. |
| `lib/getx/kasir_controller.dart` | Controller reaktif GetX (`.obs`) untuk keranjang belanja, diskon `%`, uang pembeli, total tagihan, dan kembalian. |

### Halaman & Komponen UI (`lib/screens/` & `lib/widgets/`)

| File | Fungsi singkat |
| --- | --- |
| `lib/screens/home_screen.dart` | Kerangka utama dengan tombol **Reset Data Contoh** di AppBar dan lencana jumlah keranjang di menu bawah. |
| `lib/screens/stok_screen.dart` | Halaman daftar stok barang beserta banner ringkasan dan tombol apung **+ Tambah Barang**. |
| `lib/screens/kasir_screen.dart` | Halaman transaksi kasir responsif (1 kolom di HP, 2 kolom di Web) yang menghubungkan GetX dan Cubit. |
| `lib/widgets/ringkasan_stok_banner.dart` | Banner ringkasan jumlah jenis barang, total unit stok, dan indikator barang habis. |
| `lib/widgets/produk_tile.dart` | Komponen satu baris produk lengkap dengan chip sisa stok serta tombol ubah dan hapus. |
| `lib/widgets/produk_form_dialog.dart` | Modal form input validasi untuk menambah barang baru atau mengubah barang lama. |
| `lib/widgets/keranjang_panel.dart` | Panel daftar keranjang, input diskon & uang tunai, perhitungan kembalian real-time (`Obx`), dan tombol bayar. |
| `lib/widgets/placeholder_view.dart` | Komponen informasi saat halaman belum memiliki data barang. |

### Pengujian & Otomasi CI

| File | Fungsi singkat |
| --- | --- |
| `test/widget_test.dart` | Satu tes dasar sederhana: memastikan daftar stok (Cubit) muncul dan klik barang masuk ke keranjang (GetX). |
| `.github/workflows/flutter_ci.yml` | Konfigurasi GitHub Actions untuk menjalankan `flutter analyze` dan `flutter test` otomatis. |

## Cara Menjalankan

```bash
flutter pub get
flutter run -d chrome     # versi web
flutter run               # versi Android (HP/emulator)
flutter test              # tes dasar
```
