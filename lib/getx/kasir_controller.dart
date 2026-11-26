import 'package:get/get.dart';

import '../models/item_keranjang.dart';
import '../models/produk.dart';

/// #ControllerKasir — Pengatur state reaktif GetX untuk Halaman Kasir.
///
/// Perbedaan utama dengan Cubit di Halaman Stok:
/// - Di **Cubit**, kita mengumpulkan semua data dalam 1 class `ProdukState`, lalu
///   memanggil `emit(...)` setiap ada perubahan.
/// - Di **GetX**, kita cukup menempelkan `.obs` (observable) pada variabel.
///   Mirip `ref([])` / `ref(0)` di Vue 3 atau Signals di SolidJS: begitu nilai
///   variabel `.obs` berubah, hanya widget `Obx(...)` yang membaca variabel itu
///   yang otomatis digambar ulang!
class KasirController extends GetxController {
  /// #DaftarKeranjang — List reaktif berisi barang yang sedang dibeli pembeli.
  /// Mirip `const keranjang = ref([])` di Vue 3.
  final RxList<ItemKeranjang> keranjang = <ItemKeranjang>[].obs;

  /// #DiskonPersen — Persentase diskon transaksi (0 sampai 100).
  final RxInt diskonPersen = 0.obs;

  /// #UangBayar — Nominal uang tunai yang diserahkan pembeli.
  final RxInt uangBayar = 0.obs;

  /// #SubtotalBelanja — Jumlah seluruh `harga * qty` sebelum dipotong diskon.
  /// Mirip `computed(() => ...)` di Vue atau `array_reduce` di PHP.
  int get subtotal =>
      keranjang.fold<int>(0, (total, item) => total + item.subtotal);

  /// #PotonganDiskon — Nilai Rupiah diskon dari persentase.
  int get nominalDiskon => (subtotal * diskonPersen.value) ~/ 100;

  /// #TotalAkhir — Tagihan bersih yang wajib dibayar pembeli.
  int get totalBayar => subtotal - nominalDiskon;

  /// #Kembalian — Selisih uang pembeli dikurangi total tagihan.
  /// Jika bernilai negatif berarti uang pembeli masih kurang.
  int get selisihBayar => uangBayar.value - totalBayar;

  /// #SiapBayar — Transaksi boleh diselesaikan jika keranjang terisi dan uang cukup.
  bool get bisaBayar => keranjang.isNotEmpty && selisihBayar >= 0;

  /// #JumlahDiKeranjang — Mengecek berapa `qty` suatu produk yang sudah masuk keranjang.
  int qtyProduk(String produkId) {
    final index = keranjang.indexWhere((i) => i.produk.id == produkId);
    return index == -1 ? 0 : keranjang[index].qty;
  }

  /// #TambahKeKeranjang — Memasukkan 1 barang ke keranjang selama stok mencukupi.
  /// Mengembalikan `true` jika berhasil, `false` jika melebihi sisa stok.
  bool tambahKeKeranjang(Produk produk) {
    if (produk.stok <= 0) return false;

    final index = keranjang.indexWhere((i) => i.produk.id == produk.id);
    if (index == -1) {
      keranjang.add(ItemKeranjang(produk: produk, qty: 1));
      return true;
    }

    final sekarang = keranjang[index];
    if (sekarang.qty >= produk.stok) return false;

    keranjang[index] = sekarang.copyWith(produk: produk, qty: sekarang.qty + 1);
    return true;
  }

  /// #KurangiQty — Mengurangi 1 jumlah beli; jika menyentuh 0 maka baris dihapus.
  void kurangiQty(String produkId) {
    final index = keranjang.indexWhere((i) => i.produk.id == produkId);
    if (index == -1) return;

    final sekarang = keranjang[index];
    if (sekarang.qty <= 1) {
      keranjang.removeAt(index);
    } else {
      keranjang[index] = sekarang.copyWith(qty: sekarang.qty - 1);
    }
  }

  /// #HapusItem — Membuang satu baris barang langsung dari keranjang.
  void hapusDariKeranjang(String produkId) {
    keranjang.removeWhere((i) => i.produk.id == produkId);
  }

  /// #AturDiskon — Mengubah persentase diskon dengan batas aman 0%–100%.
  void aturDiskon(String teks) {
    final angka = int.tryParse(teks) ?? 0;
    diskonPersen.value = angka.clamp(0, 100);
  }

  /// #AturUangBayar — Mengubah nominal uang yang diterima dari pembeli.
  void aturUangBayar(String teks) {
    final angka = int.tryParse(teks) ?? 0;
    uangBayar.value = angka < 0 ? 0 : angka;
  }

  /// #SinkronProduk — Menyesuaikan isi keranjang jika data barang di tab Stok
  /// baru saja diubah atau dihapus oleh pengguna.
  void sinkronkanDenganStok(List<Produk> daftarStok) {
    final petaStok = {for (final p in daftarStok) p.id: p};
    final hasil = <ItemKeranjang>[];

    for (final item in keranjang) {
      final terbaru = petaStok[item.produk.id];
      if (terbaru == null || terbaru.stok <= 0) continue;
      final qtyAman = item.qty > terbaru.stok ? terbaru.stok : item.qty;
      hasil.add(ItemKeranjang(produk: terbaru, qty: qtyAman));
    }

    keranjang.assignAll(hasil);
  }

  /// #ResetTransaksi — Mengosongkan keranjang, diskon, dan uang bayar untuk pembeli berikutnya.
  void kosongkanTransaksi() {
    keranjang.clear();
    diskonPersen.value = 0;
    uangBayar.value = 0;
  }
}
