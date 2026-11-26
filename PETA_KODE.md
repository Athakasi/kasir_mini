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
| 8 | Fitur Struk & Riwayat (Bagian 1): Model `Transaksi` + `TransaksiService` (`shared_preferences`) | ✅ Selesai |
| 9 | Fitur Struk & Riwayat (Bagian 2): `RiwayatCubit` + pop-up `StrukDialog` saat selesai bayar di Kasir | ✅ Selesai |
| 10 | Fitur Struk & Riwayat (Bagian 3): Tab ke-3 **Riwayat** di menu bawah + ringkasan omzet & buka ulang struk | ✅ Selesai |
| 11 | Fitur Cetak Universal (Bagian 1): Paket `pdf` + `printing` & `StrukPdfService` (kertas gulung 80mm) | ✅ Selesai |
| 12 | Fitur Cetak Universal (Bagian 2): Tombol **Cetak** & **Bagikan/Unduh PDF** di `StrukDialog` + dokumentasi | ✅ Selesai |

## Struktur Folder

```
lib/
├── main.dart                         # pintu masuk aplikasi
├── app.dart                          # akar aplikasi (BlocProvider + GetMaterialApp)
├── core/
│   ├── app_theme.dart                # tema Material 3 warna hijau toko
│   ├── format_rupiah.dart            # pengubah angka ke teks "Rp 18.000"
│   └── format_waktu.dart             # format tanggal/jam struk & pembuat nomor nota
├── models/
│   ├── produk.dart                   # cetakan data barang
│   ├── item_keranjang.dart           # cetakan satu baris item di keranjang
│   └── transaksi.dart                # cetakan satu lembar struk/nota transaksi
├── services/
│   ├── produk_service.dart           # simpan/ambil produk JSON di shared_preferences
│   ├── transaksi_service.dart        # simpan/ambil riwayat transaksi di shared_preferences
│   └── struk_pdf_service.dart        # penyusun dokumen PDF struk 80mm, cetak, & bagikan PDF
├── cubit/
│   ├── produk_state.dart             # wadah state Halaman Stok
│   ├── produk_cubit.dart             # pengatur CRUD & potong stok (Cubit)
│   ├── riwayat_state.dart            # wadah state riwayat transaksi & total omzet
│   └── riwayat_cubit.dart            # pengatur simpan & muat riwayat transaksi
├── getx/
│   └── kasir_controller.dart         # keranjang & hitung kembalian reaktif (.obs)
├── screens/
│   ├── home_screen.dart              # kerangka utama + bottom nav 3 tab berlencana + reset
│   ├── stok_screen.dart              # halaman kelola stok barang
│   ├── kasir_screen.dart             # halaman transaksi kasir responsif
│   └── riwayat_screen.dart           # halaman daftar nota & total omzet
└── widgets/
    ├── placeholder_view.dart         # tampilan saat daftar masih kosong
    ├── ringkasan_stok_banner.dart    # kartu ringkasan total jenis, unit, & stok habis
    ├── ringkasan_riwayat_banner.dart # kartu ringkasan total nota & total omzet
    ├── produk_tile.dart              # kartu satu produk beserta tombol ubah & hapus
    ├── produk_form_dialog.dart       # modal form input tambah / ubah barang
    ├── keranjang_panel.dart          # panel keranjang, diskon, uang bayar, & kembalian
    └── struk_dialog.dart             # modal nota/struk + salin teks, PDF/share, & cetak
```

## Daftar Lengkap Seluruh File

### Inti & Konfigurasi (`lib/` & `lib/core/`)

| File | Fungsi singkat |
| --- | --- |
| `lib/main.dart` | Pintu masuk aplikasi: menyiapkan `ensureInitialized()` lalu memanggil `KasirMiniApp`. |
| `lib/app.dart` | Akar aplikasi: mendaftarkan `KasirController` (GetX), `MultiBlocProvider` (`ProdukCubit` + `RiwayatCubit`), dan `GetMaterialApp`. |
| `lib/core/app_theme.dart` | Pengaturan tema Material 3 dan skema warna hijau toko. |
| `lib/core/format_rupiah.dart` | Fungsi bantu memformat angka bulat menjadi mata uang `Rp 18.000`. |
| `lib/core/format_waktu.dart` | Fungsi bantu memformat tanggal/jam struk (`26/11/2026 • 22:25`) dan nomor nota (`INV-...`). |

### Model & Service (`lib/models/` & `lib/services/`)

| File | Fungsi singkat |
| --- | --- |
| `lib/models/produk.dart` | Cetakan data barang (`id`, `nama`, `harga`, `stok`) lengkap dengan `copyWith`, `toMap`, dan `fromMap`. |
| `lib/models/item_keranjang.dart` | Cetakan satu item belanja (`produk`, `qty`, `subtotal`, serta `toMap` & `fromMap` untuk snapshot struk). |
| `lib/models/transaksi.dart` | Cetakan satu lembar struk transaksi (nomor nota, waktu, daftar item, diskon, total, bayar, kembalian). |
| `lib/services/produk_service.dart` | Penyimpanan permanen JSON ke `shared_preferences` (muat, tambah, ubah, hapus, potong stok batch, dan reset contoh). |
| `lib/services/transaksi_service.dart` | Penyimpanan permanen daftar riwayat transaksi ke `shared_preferences` (ambil terbaru, simpan baru, dan hapus semua). |
| `lib/services/struk_pdf_service.dart` | Penyusun PDF nota ukuran kertas kasir gulung 80mm (`PdfPageFormat.roll80`) beserta fungsi cetak dan unduh/bagikan PDF. |

### State Management (`lib/cubit/` & `lib/getx/`)

| File | Fungsi singkat |
| --- | --- |
| `lib/cubit/produk_state.dart` | State immutable Halaman Stok berisi `daftarProduk` dan penanda `sedangMemuat`. |
| `lib/cubit/produk_cubit.dart` | Controller Cubit untuk memuat, menambah, mengubah, menghapus, mengurangi stok transaksi, dan mereset data contoh. |
| `lib/cubit/riwayat_state.dart` | State immutable daftar transaksi beserta perhitungan `totalOmzet`. |
| `lib/cubit/riwayat_cubit.dart` | Controller Cubit untuk memuat, mencatat transaksi baru, dan menghapus seluruh riwayat. |
| `lib/getx/kasir_controller.dart` | Controller reaktif GetX (`.obs`) untuk keranjang belanja, diskon `%`, uang pembeli, total tagihan, dan kembalian. |

### Halaman & Komponen UI (`lib/screens/` & `lib/widgets/`)

| File | Fungsi singkat |
| --- | --- |
| `lib/screens/home_screen.dart` | Kerangka utama 3 tab (`Stok`, `Kasir`, `Riwayat`) dengan lencana keranjang (`Obx`) & lencana nota (`BlocBuilder`). |
| `lib/screens/stok_screen.dart` | Halaman daftar stok barang beserta banner ringkasan dan tombol apung **+ Tambah Barang**. |
| `lib/screens/kasir_screen.dart` | Halaman transaksi kasir responsif yang menghubungkan GetX, pemotongan stok, pencatatan riwayat, dan pop-up struk. |
| `lib/screens/riwayat_screen.dart` | Halaman daftar riwayat transaksi yang merangkum omzet dan membuka ulang `StrukDialog` saat nota diketuk. |
| `lib/widgets/ringkasan_stok_banner.dart` | Banner ringkasan jumlah jenis barang, total unit stok, dan indikator barang habis. |
| `lib/widgets/ringkasan_riwayat_banner.dart` | Banner ringkasan jumlah nota, total omzet Rupiah, dan tombol bersihkan riwayat. |
| `lib/widgets/produk_tile.dart` | Komponen satu baris produk lengkap dengan chip sisa stok serta tombol ubah dan hapus. |
| `lib/widgets/produk_form_dialog.dart` | Modal form input validasi untuk menambah barang baru atau mengubah barang lama. |
| `lib/widgets/keranjang_panel.dart` | Panel daftar keranjang, input diskon & uang tunai, perhitungan kembalian real-time (`Obx`), dan tombol bayar. |
| `lib/widgets/struk_dialog.dart` | Jendela modal nota/struk belanja dengan opsi **Salin Teks**, **PDF / Share**, dan **Cetak** universal. |
| `lib/widgets/placeholder_view.dart` | Komponen informasi saat halaman belum memiliki data barang. |

### Pengujian & Otomasi CI

| File | Fungsi singkat |
| --- | --- |
| `test/widget_test.dart` | Satu tes dasar sederhana: memastikan 3 tab utama (`Stok`, `Kasir`, `Riwayat`) beserta Cubit & GetX berjalan lancar. |
| `.github/workflows/flutter_ci.yml` | Konfigurasi GitHub Actions untuk menjalankan `flutter analyze` dan `flutter test` otomatis. |

## Cara Menjalankan

```bash
flutter pub get
flutter run -d chrome     # versi web
flutter run               # versi Android (HP/emulator)
flutter test              # tes dasar
```
