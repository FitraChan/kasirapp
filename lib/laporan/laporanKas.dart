import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kasirapp/laporan/menuLaporan.dart';
import 'package:kasirapp/model/rupiahCurrency.dart';
import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:kasirapp/model/currencyFormatter.dart';
import 'package:kasirapp/network_utils/api.dart';
import 'package:kasirapp/screen/home.dart';

class LaporanKas extends StatefulWidget {
  const LaporanKas({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _LaporanKasState createState() => _LaporanKasState();
}

class _LaporanKasState extends State<LaporanKas> {
  KasirHelper? helper;
  final currencyFormatter = CurrencyFormatter();
  bool _isLoading = true;
  Map<int, TextEditingController> kasControllers = {};
  Set<int> loadingIndexes = {};

  DateTime? selectedDate;
  final TextEditingController dateController = TextEditingController();
  var tang;

  @override
  void initState() {
    super.initState();
    helper = KasirHelper();

    _loadTransaksi();
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

      // loadData(); // reload API

      _loadTransaksi();
    }
  }

  List listKas = [];

  int _currentPage = 0;
  int _rowsPerPage = 15;

  final rupiahFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  void _loadTransaksi() async {
    try {
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

      //var url = 'showKas';
      Map data = {
        'tanggal_awal': tglAwal,
        'tanggal_akhir': tglAkhir,
      };

      final response = await Network().getData_post(data, 'showLaporanKas');
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List dataList = jsonResponse['data'];

        setState(() {
          listKas = dataList;

          // ✅ INIT CONTROLLER DI SINI

          _isLoading = false;
        });
      } else {
        print(response.body);
      }
    } catch (e) {
      print('Error loading transaksi: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List get paginatedData {
    final start = _currentPage * _rowsPerPage;
    final end = start + _rowsPerPage;
    return listKas.sublist(
      start,
      end > listKas.length ? listKas.length : end,
    );
  }

  String removeCurrencyFormat(String formattedValue) {
    // Hapus semua karakter yang bukan angka
    String cleanValue = formattedValue.replaceAll(RegExp(r'[^\d]'), '');

    return cleanValue;
  }

  @override
  void dispose() {
    // Dispose semua TextEditingController
    for (var controller in kasControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MenuLaporan()),
          );
          return Future.value(true);
        },
        child: Scaffold(
            backgroundColor: const Color(0xFFF5F6FA),
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.blue,
              title: const Text(
                'Laporan Kas',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
            ),
            body: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildContent()));
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterSection(),
          const SizedBox(height: 20),
          _buildTableSection(),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
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

  Widget _buildTableSection() {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        headingRowColor:
                            MaterialStateProperty.all(Colors.red[50]),
                        dataRowHeight: 60,
                        headingTextStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        columns: const [
                          DataColumn(label: Text('No')),
                          DataColumn(label: Text('Tanggal')),
                          DataColumn(label: Text('Keterangan')),
                          DataColumn(label: Text('Kas Masuk')),
                          DataColumn(label: Text('Kas Keluar')),
                          DataColumn(label: Text('Saldo')),
                        ],
                        rows: List.generate(
                          paginatedData.length,
                          (index) {
                            final item = paginatedData[index];
                            final realIndex =
                                _currentPage * _rowsPerPage + index;

                            return DataRow(
                              cells: [
                                DataCell(Text('${realIndex + 1}')),
                                DataCell(
                                  Text(
                                    item['tanggal'] != null
                                        ? DateFormat('dd-MM-yyyy').format(
                                            DateTime.parse(item['tanggal']))
                                        : '-',
                                  ),
                                ),
                                DataCell(Text('${item['keterangan'] ?? 0}')),
                                DataCell(
                                  Text(
                                    'Rp${currencyFormatter.format(item['kas_masuk'] ?? 0)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    'Rp${currencyFormatter.format(item['kas_keluar'] ?? 0)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    'Rp${currencyFormatter.format(item['saldo'] ?? 0)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                )
                              ],
                            );
                          },
                        ),
                      ),
                    )),
              ),
              const SizedBox(height: 10),
              _buildPagination(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          onPressed:
              _currentPage > 0 ? () => setState(() => _currentPage--) : null,
          icon: const Icon(Icons.chevron_left),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Page ${_currentPage + 1} / ${(listKas.length / _rowsPerPage).ceil()}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        IconButton(
          onPressed: (_currentPage + 1) * _rowsPerPage < listKas.length
              ? () => setState(() => _currentPage++)
              : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}
