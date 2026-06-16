import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kasirapp/model/mutasiStokModel.dart';
import 'package:kasirapp/model/rupiahCurrency.dart';
import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:kasirapp/model/currencyFormatter.dart';
import 'package:kasirapp/network_utils/api.dart';
import 'package:kasirapp/screen/home.dart';

class MutasiStok extends StatefulWidget {
  const MutasiStok({super.key});

  @override
  State<MutasiStok> createState() => _MutasiStokState();
}

class _MutasiStokState extends State<MutasiStok> {
  List<MutasiStokModel> list = [];
  double totalMasuk = 0;
  double totalKeluar = 0;
  double saldoAkhir = 0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  DateTime? tanggalAwal;
  DateTime? tanggalAkhir;

  bool isLoading = false;

  Future<void> pilihTanggal() async {
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: tanggalAwal != null && tanggalAkhir != null
          ? DateTimeRange(start: tanggalAwal!, end: tanggalAkhir!)
          : null,
    );

    if (result != null) {
      setState(() {
        tanggalAwal = result.start;
        tanggalAkhir = result.end;
      });

      loadData(); // reload API
    }
  }

  Future<void> loadData() async {
    //   if (tanggalAwal == null || tanggalAkhir == null) return;
    String tglAwal;
    String tglAkhir;

    setState(() => isLoading = true);
    if (tanggalAwal == null || tanggalAkhir == null) {
      tglAwal = null.toString();
      tglAkhir = null.toString();
    } else {
      tglAwal = DateFormat('yyyy-MM-dd').format(tanggalAwal!);
      tglAkhir = DateFormat('yyyy-MM-dd').format(tanggalAkhir!);
    }

    Map data = {
      'tanggal_awal': tglAwal,
      'tanggal_akhir': tglAkhir,
    };

    final response = await Network().getData_post(data, 'showMutasiStok');

    print('Mutasi Kas Response: ${response.body}');

    final body = jsonDecode(response.body);

    setState(() {
      list = (body['data'] as List)
          .map((e) => MutasiStokModel.fromJson(e))
          .toList();

      // totalMasuk = response['total_masuk'].toDouble();
      // totalKeluar = response['total_keluar'].toDouble();
      // saldoAkhir = response['saldo_akhir'].toDouble();

      isLoading = false;
    });
  }

  Widget buildDateFilter() {
    return GestureDetector(
      onTap: pilihTanggal,
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              blurRadius: 6,
              color: Colors.grey.shade300,
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_month, color: Colors.blue),
                const SizedBox(width: 10),
                Text(
                  tanggalAwal == null
                      ? "Pilih Tanggal"
                      : "${DateFormat('dd MMM yyyy').format(tanggalAwal!)} - ${DateFormat('dd MMM yyyy').format(tanggalAkhir!)}",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Mutasi Stok"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          buildDateFilter(),
          if (isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            // 🔵 SUMMARY CARD
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8,
                    color: Colors.grey.shade300,
                  )
                ],
              ),
            ),

          // 🔵 LIST
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 8,
                  )
                ],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor:
                      MaterialStateProperty.all(Colors.grey.shade100),
                  columnSpacing: 24,
                  columns: const [
                    DataColumn(label: Text("No")),
                    DataColumn(label: Text("Tanggal")),
                    DataColumn(label: Text("Produk")),
                    DataColumn(label: Text("PK")),
                    DataColumn(label: Text("Stok Masuk")),
                    DataColumn(label: Text("Stok Keluar")),
                    DataColumn(label: Text("Stok Sekarang")),
                  ],
                  rows: List.generate(list.length, (index) {
                    final item = list[index];
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            "${index + 1}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataCell(Text(
                          DateFormat('dd-MM-yyyy')
                              .format(DateTime.parse(item.tanggal)),
                        )),
                        DataCell(Text(item.namaBarang)),
                        DataCell(Text(item.namaPk)),
                        DataCell(
                          Text(
                            item.stokMasuk > 0 ? "+${item.stokMasuk}" : "-",
                            style: TextStyle(
                              color: item.stokMasuk > 0
                                  ? Colors.green
                                  : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            item.stokKeluar > 0 ? "-${item.stokKeluar}" : "-",
                            style: TextStyle(
                              color: item.stokKeluar > 0
                                  ? Colors.red
                                  : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            item.stokSesudah.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSummaryRow(String title, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            value.toStringAsFixed(0),
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
