import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:kasirapp/model/currencyFormatter.dart';
import 'package:kasirapp/network_utils/api.dart';
import 'package:kasirapp/screen/customInput.dart';

class BayarDialog extends StatefulWidget {
  final String kodeHutang;
  final double sisa;
  final VoidCallback onSuccess;

  const BayarDialog({
    super.key,
    required this.kodeHutang,
    required this.sisa,
    required this.onSuccess,
  });

  @override
  State<BayarDialog> createState() => _BayarDialogState();
}

class _BayarDialogState extends State<BayarDialog> {
  final controller = TextEditingController();
  KasirHelper? helper;
  final currencyFormatter = CurrencyFormatter();

  void initState() {
    super.initState();
    helper = KasirHelper();
  }

  String removeCurrencyFormat(String formattedValue) {
    // Hapus semua karakter yang bukan angka
    String cleanValue = formattedValue.replaceAll(RegExp(r'[^\d]'), '');

    return cleanValue;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Bayar Hutang"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomInput.angka(
              "Jumlah Bayar", Icons.price_change_rounded, controller),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Batal"),
        ),
        ElevatedButton(
          onPressed: () async {
            //  final jumlah = double.tryParse(controller.text) ?? 0;

            String jumlahFormattedValue = removeCurrencyFormat(controller.text);

            final jumlah = double.tryParse(jumlahFormattedValue) ?? 0;

            if (jumlah <= 0) return;

            if (jumlah > widget.sisa) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Melebihi sisa hutang")),
              );
              return;
            }

            try {
              await helper!.bayarHutang(
                kodeHutang: widget.kodeHutang,
                jumlahBayar: jumlah,
              );

              if (!mounted) return;

              Navigator.pop(context); // 🔥 tutup dulu dialog

              widget.onSuccess(); // update parent

              // async setelah dialog ditutup (AMAN karena tidak pakai setState di dialog)
              sendBayarHutang(
                kodeHutang: widget.kodeHutang,
                jumlahBayar: jumlah,
              );
            } catch (e) {
              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.toString())),
              );
            }
          },
          child: const Text("Bayar"),
        ),
      ],
    );
  }

  bool _isLoading = false;

  Future<void> sendBayarHutang({
    required String kodeHutang,
    required double jumlahBayar,
  }) async {
    try {
      Map<String, String> body = {
        'kode_hutang': kodeHutang,
        'jumlah_bayar': jumlahBayar.toString(),
      };

      String url = 'bayarHutangSupplier'; // endpoint Laravel

      final response = await Network().getData_post(body, url);

      if (response.statusCode == 200) {
        print('✅ Pembayaran hutang berhasil sync ke MySQL');
        await helper!
            .sync(kodeHutang, 'kode_hutang', 'tb_bayar_hutang_supplier');
      } else {
        print('❌ Error: ${response.body}');
        throw Exception('Gagal sync pembayaran hutang');
      }
    } catch (e) {
      EasyLoading.showError(e.toString());
    }
  }
}
