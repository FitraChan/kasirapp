import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:intl/intl.dart';

KasirHelper? helper;

class ProdukNotifier extends StateNotifier<List<dynamic>> {
  ProdukNotifier() : super([]);

  var current;
  var currentString;

  Future<void> produk() async {
    helper = KasirHelper();

    final allProduk = await helper!.allProduk();
    state = allProduk;
  }
}

// Provider untuk jumlah transaksi
final produkProvider =
    StateNotifierProvider<ProdukNotifier, List<dynamic>>((ref) {
  return ProdukNotifier();
});
