import 'package:flutter/material.dart';

import '../core/format_rupiah.dart';
import '../models/produk.dart';

/// #KartuProduk — Komponen satu baris/kartu barang di daftar stok.
/// Mirip Blade component `<x-produk-card :produk="$item" />` di Laravel atau
/// komponen `<ProdukTile produk={item} onEdit={...} onDelete={...} />` di React:
/// menerima callback `onUbah` dan `onHapus` dari halaman induknya.
class ProdukTile extends StatelessWidget {
  const ProdukTile({
    super.key,
    required this.produk,
    this.onUbah,
    this.onHapus,
  });

  final Produk produk;
  final VoidCallback? onUbah;
  final VoidCallback? onHapus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stokHabis = produk.stok <= 0;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          foregroundColor: theme.colorScheme.onPrimaryContainer,
          child: const Icon(Icons.coffee_outlined),
        ),
        title: Text(
          produk.nama,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(FormatRupiah.dari(produk.harga)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(
              label: Text(stokHabis ? 'Habis' : 'Stok: ${produk.stok}'),
              backgroundColor: stokHabis
                  ? theme.colorScheme.errorContainer
                  : theme.colorScheme.secondaryContainer,
              side: BorderSide.none,
            ),
            if (onUbah != null)
              IconButton(
                tooltip: 'Ubah barang',
                icon: const Icon(Icons.edit_outlined),
                onPressed: onUbah,
              ),
            if (onHapus != null)
              IconButton(
                tooltip: 'Hapus barang',
                icon: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.error,
                ),
                onPressed: onHapus,
              ),
          ],
        ),
      ),
    );
  }
}
