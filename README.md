# Kasir Mini

Aplikasi latihan Flutter (**Android & Web**) yang menggabungkan **Cubit (`flutter_bloc`)** dan **GetX (`get`)** dalam satu proyek berstruktur ala **MVC** yang rapi dan mudah dirawat.

## Fitur Utama (3 Tab)

1. **Tab Stok Barang (Cubit)**
   - Ringkasan jumlah jenis barang, total unit fisik, dan peringatan stok habis.
   - Tambah, ubah, dan hapus barang lengkap dengan validasi form.
   - Tombol **Reset Data Contoh** di pojok kanan atas untuk mengembalikan 10 produk awal kapan saja.
2. **Tab Kasir (GetX Reaktif `.obs` + `Obx`)**
   - Ketuk produk untuk memasukkan ke keranjang (dilengkapi lencana jumlah item langsung di tab bawah).
   - Atur `qty`, persentase diskon (`%`), dan nominal uang pembeli — subtotal, potongan diskon, total bayar, serta kembalian otomatis dihitung seketika.
   - Selesai bayar langsung memunculkan **pop-up Struk Belanja** dengan 3 opsi ekspor universal: **Salin Teks**, **PDF / Share** (`Printing.sharePdf`), dan **Cetak** (`Printing.layoutPdf` ukuran kertas struk 80mm).
   - Tata letak responsif: 1 kolom di layar HP Android, 2 kolom berdampingan di layar Web lebar.
3. **Tab Riwayat Transaksi (Cubit)**
   - Menampilkan kartu ringkasan **Total Nota & Total Omzet** beserta lencana jumlah transaksi di tab bawah.
   - Ketuk baris transaksi mana saja untuk membuka ulang **Struk Belanja**-nya, atau bersihkan seluruh riwayat.
4. **Penyimpanan Permanen (`shared_preferences`)**
   - Daftar stok maupun riwayat nota tersimpan permanen dalam format JSON (di `localStorage` pada Web dan `SharedPreferences` pada Android).

## Struktur Folder (MVC)

```
lib/
├── main.dart                         # pintu masuk aplikasi
├── app.dart                          # akar aplikasi (MultiBlocProvider + GetMaterialApp)
├── core/                             # pengaturan global (tema, format Rupiah & waktu)
├── models/                           # cetakan struktur data (Produk, ItemKeranjang, Transaksi)
├── services/                         # penyimpanan JSON ke shared_preferences
├── cubit/                            # state management Cubit (Stok & Riwayat)
├── getx/                             # controller reaktif GetX (Kasir)
├── screens/                          # halaman tampilan utama (3 tab)
└── widgets/                          # komponen UI kecil yang dipakai ulang
```

Penjelasan lengkap fungsi setiap file ada di [PETA_KODE.md](PETA_KODE.md).

## Cara Menjalankan

```bash
flutter pub get
flutter run -d chrome     # jalankan versi Web
flutter run               # jalankan di HP / Emulator Android
flutter analyze           # periksa kerapian kode
flutter test              # jalankan tes dasar
```
