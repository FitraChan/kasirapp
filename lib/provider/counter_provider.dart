import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:intl/intl.dart';

KasirHelper? helper;

class DynamicListNotifier extends StateNotifier<List<dynamic>> {
  DynamicListNotifier() : super([]);

  var current;
  var currentString;

  Future<void> fetchJumlahTransaksi() async {
    helper = KasirHelper();
    // Misalkan helper!.showJumlahTransaksi adalah fungsi asinkron yang mengambil data

    current = DateTime.parse(DateTime.now().toString());
    currentString = DateFormat('yyyy-MM-dd HH:mm:ss').format(current);

    final items = await helper!.showJumlahTransaksi(currentString);
    state = items; // Update state dengan data baru
  }
}

// Provider untuk jumlah transaksi
final dynamicListProvider =
    StateNotifierProvider<DynamicListNotifier, List<dynamic>>((ref) {
  return DynamicListNotifier();
});
