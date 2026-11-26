# Kasir Mini

Aplikasi latihan Flutter (**Android & Web**) yang menggabungkan **Cubit (`flutter_bloc`)** dan **GetX (`get`)** dalam satu proyek berstruktur ala **MVC** yang rapi dan mudah dirawat.

## Fitur Utama

1. **Tab Stok Barang (Cubit)**
   - Ringkasan jumlah jenis barang, total unit fisik, dan peringatan stok habis.
   - Tambah, ubah, dan hapus barang lengkap dengan validasi form.
   - Tombol **Reset Data Contoh** di pojok kanan atas untuk mengembalikan 4 produk awal kapan saja.
2. **Tab Kasir (GetX Reaktif `.obs` + `Obx`)**
   - Ketuk produk untuk memasukkan ke keranjang (dilengkapi lencana jumlah item langsung di tab bawah).
   - Atur `qty`, persentase diskon (`%`), dan nominal uang pembeli — subtotal, potongan diskon, total bayar, serta kembalian otomatis dihitung seketika.
   - Tata letak responsif: 1 kolom di layar HP Android, 2 kolom berdampingan di layar Web lebar.
3. **Penyimpanan Permanen (`shared_preferences`)**
   - Semua perubahan produk dan pemotongan stok setelah transaksi otomatis tersimpan dalam format JSON (di `localStorage` pada Web dan `SharedPreferences` pada Android).

## Struktur Folder (MVC)

```
lib/
├── main.dart                         # pintu masuk aplikasi
├── app.dart                          # akar aplikasi (BlocProvider + GetMaterialApp)
├── core/                             # pengaturan global (tema & format Rupiah)
├── models/                           # cetakan struktur data (Produk, ItemKeranjang)
├── services/                         # penyimpanan JSON ke shared_preferences
├── cubit/                            # state management Cubit (Halaman Stok)
├── getx/                             # controller reaktif GetX (Halaman Kasir)
├── screens/                          # halaman tampilan utama
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
