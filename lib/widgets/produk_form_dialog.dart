import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/produk.dart';

/// #HasilFormProduk — Paket data kecil berisi nilai bersih hasil ketikan user di form.
/// Mirip objek `{ nama, harga, stok }` yang dikirim saat `onSubmit` di React.
class HasilFormProduk {
  const HasilFormProduk({
    required this.nama,
    required this.harga,
    required this.stok,
  });

  final String nama;
  final int harga;
  final int stok;
}

/// #DialogFormProduk — Jendela pop-up (modal) untuk menambah atau mengubah barang.
/// Mirip Bootstrap Modal berisi `<form>` di web: jika `produkAwal` kosong berarti
/// mode **Tambah**, jika terisi berarti mode **Ubah**.
class ProdukFormDialog extends StatefulWidget {
  const ProdukFormDialog({super.key, this.produkAwal});

  final Produk? produkAwal;

  /// #BukaDialog — Fungsi praktis untuk menampilkan modal dan menunggu hasilnya (`Future`).
  /// Mirip `await showModal()` di JavaScript: mengembalikan `HasilFormProduk`
  /// jika tombol Simpan ditekan, atau `null` jika Batal.
  static Future<HasilFormProduk?> tampilkan(
    BuildContext context, {
    Produk? produkAwal,
  }) {
    return showDialog<HasilFormProduk>(
      context: context,
      builder: (_) => ProdukFormDialog(produkAwal: produkAwal),
    );
  }

  @override
  State<ProdukFormDialog> createState() => _ProdukFormDialogState();
}

class _ProdukFormDialogState extends State<ProdukFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaCtrl;
  late final TextEditingController _hargaCtrl;
  late final TextEditingController _stokCtrl;

  bool get _modeUbah => widget.produkAwal != null;

  @override
  void initState() {
    super.initState();
    // #IsiAwalInput — `TextEditingController` mirip `document.getElementById('...').value`
    // atau `useRef` pada input di React: membaca dan mengisi teks di kotak input.
    final awal = widget.produkAwal;
    _namaCtrl = TextEditingController(text: awal?.nama ?? '');
    _hargaCtrl = TextEditingController(
      text: awal != null ? awal.harga.toString() : '',
    );
    _stokCtrl = TextEditingController(
      text: awal != null ? awal.stok.toString() : '',
    );
  }

  @override
  void dispose() {
    // #BersihMemori — Wajib menutup controller saat modal ditutup supaya tidak bocor memori.
    _namaCtrl.dispose();
    _hargaCtrl.dispose();
    _stokCtrl.dispose();
    super.dispose();
  }

  /// #SimpanForm — Mengecek validasi input; jika semua valid, kirim hasilnya lalu tutup modal.
  void _simpan() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    Navigator.of(context).pop(
      HasilFormProduk(
        nama: _namaCtrl.text.trim(),
        harga: int.parse(_hargaCtrl.text.trim()),
        stok: int.parse(_stokCtrl.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_modeUbah ? 'Ubah Barang' : 'Tambah Barang'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _namaCtrl,
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Nama Barang',
                    hintText: 'Contoh: Es Jeruk Peras',
                    border: OutlineInputBorder(),
                  ),
                  validator: (nilai) {
                    if (nilai == null || nilai.trim().isEmpty) {
                      return 'Nama barang wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _hargaCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Harga (Rp)',
                    hintText: 'Contoh: 12000',
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(),
                  ),
                  validator: (nilai) {
                    final angka = int.tryParse(nilai ?? '');
                    if (angka == null || angka <= 0) {
                      return 'Masukkan harga lebih dari 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _stokCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onFieldSubmitted: (_) => _simpan(),
                  decoration: const InputDecoration(
                    labelText: 'Jumlah Stok',
                    hintText: 'Contoh: 20',
                    border: OutlineInputBorder(),
                  ),
                  validator: (nilai) {
                    final angka = int.tryParse(nilai ?? '');
                    if (angka == null || angka < 0) {
                      return 'Masukkan stok 0 atau lebih';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: _simpan,
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
