import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../core/format_rupiah.dart';
import '../getx/kasir_controller.dart';

/// #PanelKeranjang — Komponen daftar belanja + hitung diskon, total, dan kembalian.
/// Mirip komponen reaktif di Vue 3 yang memakai `Obx(...)` (seperti `watchEffect`):
/// setiap kali qty, diskon, atau uang bayar diketik, angka total & kembalian
/// berubah detik itu juga tanpa perlu tombol "Hitung".
class KeranjangPanel extends StatefulWidget {
  const KeranjangPanel({
    super.key,
    required this.controller,
    required this.onSelesaiTransaksi,
  });

  final KasirController controller;
  final VoidCallback onSelesaiTransaksi;

  @override
  State<KeranjangPanel> createState() => _KeranjangPanelState();
}

class _KeranjangPanelState extends State<KeranjangPanel> {
  late final TextEditingController _diskonCtrl;
  late final TextEditingController _uangCtrl;

  KasirController get _kasir => widget.controller;

  @override
  void initState() {
    super.initState();
    _diskonCtrl = TextEditingController(
      text: _kasir.diskonPersen.value == 0
          ? ''
          : _kasir.diskonPersen.value.toString(),
    );
    _uangCtrl = TextEditingController(
      text: _kasir.uangBayar.value == 0
          ? ''
          : _kasir.uangBayar.value.toString(),
    );
  }

  @override
  void dispose() {
    _diskonCtrl.dispose();
    _uangCtrl.dispose();
    super.dispose();
  }

  void _resetInputDanKeranjang() {
    _diskonCtrl.clear();
    _uangCtrl.clear();
    _kasir.kosongkanTransaksi();
  }

  void _bayarSekarang() {
    widget.onSelesaiTransaksi();
    _diskonCtrl.clear();
    _uangCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        // #PendengarGetX — `Obx` memantau semua variabel `.obs` yang dibaca di dalamnya.
        child: Obx(() {
          final items = _kasir.keranjang;
          final selisih = _kasir.selisihBayar;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Keranjang (${items.length} jenis)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (items.isNotEmpty)
                    TextButton.icon(
                      onPressed: _resetInputDanKeranjang,
                      icon: const Icon(Icons.delete_sweep_outlined, size: 18),
                      label: const Text('Kosongkan'),
                    ),
                ],
              ),
              const Divider(),
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'Belum ada barang dipilih.\nKetuk barang pada daftar untuk memasukkan ke keranjang.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                ...items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.produk.nama,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${FormatRupiah.dari(item.produk.harga)} × ${item.qty} = ${FormatRupiah.dari(item.subtotal)}',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Kurangi qty',
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => _kasir.kurangiQty(item.produk.id),
                        ),
                        Text(
                          '${item.qty}',
                          style: theme.textTheme.titleMedium,
                        ),
                        IconButton(
                          tooltip: 'Tambah qty',
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: item.qty >= item.produk.stok
                              ? null
                              : () => _kasir.tambahKeKeranjang(item.produk),
                        ),
                        IconButton(
                          tooltip: 'Hapus baris',
                          icon: Icon(
                            Icons.close,
                            size: 20,
                            color: theme.colorScheme.error,
                          ),
                          onPressed: () =>
                              _kasir.hapusDariKeranjang(item.produk.id),
                        ),
                      ],
                    ),
                  ),
                ),
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _diskonCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Diskon (%)',
                        suffixText: '%',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      onChanged: _kasir.aturDiskon,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _uangCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Uang Pembeli',
                        prefixText: 'Rp ',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      onChanged: _kasir.aturUangBayar,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _BarisAngka(
                label: 'Subtotal',
                nilai: FormatRupiah.dari(_kasir.subtotal),
              ),
              if (_kasir.diskonPersen.value > 0)
                _BarisAngka(
                  label: 'Diskon (${_kasir.diskonPersen.value}%)',
                  nilai: '- ${FormatRupiah.dari(_kasir.nominalDiskon)}',
                ),
              const SizedBox(height: 4),
              _BarisAngka(
                label: 'Total Bayar',
                nilai: FormatRupiah.dari(_kasir.totalBayar),
                tebal: true,
              ),
              const SizedBox(height: 4),
              _BarisAngka(
                label: selisih >= 0 ? 'Kembalian' : 'Kurang Bayar',
                nilai: FormatRupiah.dari(selisih.abs()),
                warnaNilai: items.isEmpty
                    ? null
                    : (selisih >= 0
                          ? theme.colorScheme.primary
                          : theme.colorScheme.error),
                tebal: true,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _kasir.bisaBayar ? _bayarSekarang : null,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Selesaikan Transaksi'),
              ),
            ],
          );
        }),
      ),
    );
  }
}

/// #BarisRingkasan — Potongan kecil 1 baris kiri-kanan (contoh: `Total Bayar .... Rp 30.000`).
class _BarisAngka extends StatelessWidget {
  const _BarisAngka({
    required this.label,
    required this.nilai,
    this.tebal = false,
    this.warnaNilai,
  });

  final String label;
  final String nilai;
  final bool tebal;
  final Color? warnaNilai;

  @override
  Widget build(BuildContext context) {
    final gaya = tebal
        ? Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
        : Theme.of(context).textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(label, style: gaya)),
          const SizedBox(width: 8),
          Text(nilai, style: gaya?.copyWith(color: warnaNilai)),
        ],
      ),
    );
  }
}
