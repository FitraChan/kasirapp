import 'dart:convert';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kasirapp/laporan/menuLaporan.dart';

import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:kasirapp/model/currencyFormatter.dart';
import 'package:kasirapp/network_utils/api.dart';
import 'package:kasirapp/screen/home.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../screen/menu1.dart';

//import 'package:firebase_messaging/firebase_messaging.dart';

class AllLaporanPerHari extends StatefulWidget {
  const AllLaporanPerHari({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _AllLaporanPerHariState createState() => _AllLaporanPerHariState();
}

class _AllLaporanPerHariState extends State<AllLaporanPerHari> {
  //  FirebaseMessaging messaging;

  bool _isLoading = true;
  KasirHelper? helper;
  var items = [];
  List? keuntungan;
  String? untung;
  var penjualan;

  var listPenjualan = [];

  var listProduk = [];

  var listPemasukan = [];

  var listPengeluaran = [];

  var listSaldo = [];

  String? laba;
  var labaBersih = [];
  String? labaBersihTot;

  String? saldoAkhir;
  DateTime? _selectedDate;

  String? uangKeluar;
  var pengeluaran = [];

  String? uangTerima;
  var penerimaan = [];
  String? allIncome;

  var allCourses = [];
  final oCcy = NumberFormat.decimalPattern();
  TextEditingController tanggalSkr = TextEditingController();

  var tang;

  var current;
  var currentString;

  @override
  void initState() {
    super.initState();

    helper = KasirHelper();

    fetchLaporan(tang, 0);
    fetchListLaporan(tang, 0);
    fetchListLaporanPemasukan(tang);
    fetchListLaporanPengeluaran(tang);
    fetchListSaldo(tang);
  }

  bool _isFirstLoadRunning = false;

  void fetchListLaporanPengeluaran(tang) async {
    setState(() {
      _isFirstLoadRunning = true;
    });

    try {
      String url;

      var date = DateTime.parse(DateTime.now().toString());

      var tanggalNow = DateFormat('yyyy-MM-dd').format(date);

      if (tang == null) {
        url = 'penerimaanPengeluaranLaporan/$tanggalNow';
      } else {
        url = 'penerimaanPengeluaranLaporan/' + tang;
      }

      final response = await Network().getData_get(url);
      if (response.statusCode == 200) {
        var data = [];
        var c = json.decode(response.body);
        data = c['pengeluaran'];
        setState(() {
          listPengeluaran = data;
        });
      } else {
        print(response.body);
        throw Exception('Failed to load album');
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        toastLength: Toast
            .LENGTH_SHORT, // Duration for which the toast should be visible
        gravity: ToastGravity.BOTTOM, // Position of the toast on the screen
        // Font size of the message
      );
    }

    setState(() {
      _isFirstLoadRunning = false;
    });
  }

  void fetchListLaporanPemasukan(tang) async {
    setState(() {
      _isFirstLoadRunning = true;
    });

    try {
      String url;

      var date = DateTime.parse(DateTime.now().toString());

      var tanggalNow = DateFormat('yyyy-MM-dd').format(date);

      if (tang == null) {
        url = 'penerimaanPengeluaranLaporan/$tanggalNow';
      } else {
        url = 'penerimaanPengeluaranLaporan/' + tang;
      }

      final response = await Network().getData_get(url);
      if (response.statusCode == 200) {
        var data = [];
        var c = json.decode(response.body);
        data = c['penerimaan'];
        setState(() {
          listPemasukan = data;
        });
      } else {
        print(response.body);
        throw Exception('Failed to load album');
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        toastLength: Toast
            .LENGTH_SHORT, // Duration for which the toast should be visible
        gravity: ToastGravity.BOTTOM, // Position of the toast on the screen
        // Font size of the message
      );
    }

    setState(() {
      _isFirstLoadRunning = false;
    });
  }

  void fetchListLaporan(tang, status) async {
    setState(() {
      _isFirstLoadRunning = true;
    });

    try {
      // const String _url = 'http://192.168.5.10/bprs_api/public/api/show_cuti';

      // String _url = 'list_laporan_today';

      String url;

      var date = DateTime.parse(DateTime.now().toString());

      var tanggalNow = DateFormat('yyyy-MM-dd').format(date);

      if (tang == null && status != 0) {
        url = 'list_laporan_today/$tanggalNow/$status';
      } else if (tang != null && status != 0) {
        url = 'list_laporan_today/$tanggalNow/$status';
      } else if (tang != null && status == 0) {
        url = '${'list_laporan_today/' + tang}/0';
      } else {
        url = 'list_laporan_today/$tanggalNow/0';
      }
      final response = await Network().getData_get(url);
      if (response.statusCode == 200) {
        setState(() {
          listPenjualan = json.decode(response.body);
        });
      } else {
        print(response.body);
        throw Exception('Failed to load album');
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        toastLength: Toast
            .LENGTH_SHORT, // Duration for which the toast should be visible
        gravity: ToastGravity.BOTTOM, // Position of the toast on the screen
        // Font size of the message
      );
    }

    setState(() {
      _isFirstLoadRunning = false;
    });
  }

  void fetchListSaldo(tang) async {
    setState(() {
      _isFirstLoadRunning = true;
    });

    try {
      // const String _url = 'http://192.168.5.10/bprs_api/public/api/show_cuti';

      // String _url = 'list_laporan_today';

      String url;

      var date = DateTime.parse(DateTime.now().toString());

      var tanggalNow = DateFormat('yyyy-MM-dd').format(date);

      if (tang != null) {
        url = '${'listSaldo/' + tang}';
      } else {
        url = 'listSaldo/$tanggalNow';
      }
      final response = await Network().getData_get(url);

      var c = json.decode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          listSaldo = c['saldo'];
        });
      } else {
        print(response.body);
        throw Exception('Failed to load album');
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        toastLength: Toast
            .LENGTH_SHORT, // Duration for which the toast should be visible
        gravity: ToastGravity.BOTTOM, // Position of the toast on the screen
        // Font size of the message
      );
    }

    setState(() {
      _isFirstLoadRunning = false;
    });
  }

  void fetchLaporan(tang, status) async {
    //  String _url = 'http://192.168.5.10/bprs_api/public/api/profil';
    String url;

    var date = DateTime.parse(DateTime.now().toString());

    var tanggalNow = DateFormat('yyyy-MM-dd').format(date);

    if (tang == null && status != 0) {
      url = 'laporan_today/$tanggalNow/$status';
    } else if (tang != null && status != 0) {
      url = '${'laporan_today/' + tang}/$status';
    } else if (tang != null && status == 0) {
      url = '${'laporan_today/' + tang}/0';
    } else {
      url = 'laporan_today/$tanggalNow/0';
    }

    // print(url);

    final response = await Network().getData_get(url);
    //  print(response.body);
    var c = json.decode(response.body);
    if (response.statusCode == 200) {
      // var b = json.decode(response.body);
      // var b = c['absen'];
      setState(() {
        penjualan = c['result_omset_format'].toString();
        untung = c['result_laba_format'].toString();
        uangTerima = c['result_masuk_format'].toString();
        uangKeluar = c['result_keluar_format'].toString();
        labaBersihTot = c['laba_bersih_tot_format'].toString();
        allIncome = c['all_income_format'].toString();

        saldoAkhir = c['saldo_akhir_format'].toString();
        _isLoading = false;
      });
    } else {
      print(response.body);
      throw Exception('Failed to load album');
    }
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
            appBar: AppBar(
              elevation: 0,
              centerTitle: true,
              backgroundColor: Colors.red.shade700,
              title: const Text(
                'Laporan Harian',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              leading: IconButton(
                icon: const Icon(
                  Icons.home,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const Home(title: "")),
                    (route) => false,
                  );
                },
              ),
            ),
            drawer: const Menu(),
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      keuangan(),
                      const SizedBox(
                        height: 4,
                      ),
                      sectionHeader("DAFTAR PENJUALAN"),
                      _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : _createDataTable(),
                      const SizedBox(
                        height: 4,
                      ),
                      sectionHeader("PEMASUKAN"),
                      _createDataTablePemasukan(),
                      const SizedBox(
                        height: 4,
                      ),
                      sectionHeader("PENGELUARAN"),
                      _createDataTablePengeluaran(),
                      const SizedBox(
                        height: 4,
                      ),
                    ]))));
  }

  Widget summaryCard(String title, String value, Color color) {
    return Container(
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  final currencyFormatter = CurrencyFormatter();

  Widget sectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red.shade700,
          ),
        ),
      ),
    );
  }

  Map<String, double> _hitungTotalPenjualan() {
    double totalQty = 0;
    double totalOmset = 0;
    double totalLaba = 0;

    for (var item in listPenjualan) {
      totalQty += double.tryParse(item['qty'].toString()) ?? 0;
      totalOmset += double.tryParse(item['total'].toString()) ?? 0;
      totalLaba += double.tryParse(item['laba_kotor'].toString()) ?? 0;
    }

    return {
      'qty': totalQty,
      'omset': totalOmset,
      'laba': totalLaba,
    };
  }

  Widget _createDataTable() {
    double lebar = MediaQuery.of(context).size.width;

    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(
            Colors.red.shade700,
          ),
          dataRowColor: MaterialStateProperty.all(
            Colors.white,
          ),
          border: TableBorder(
            top: BorderSide(color: Colors.grey.shade600, width: 1.5),
            bottom: BorderSide(color: Colors.grey.shade600, width: 1.5),
            left: BorderSide(color: Colors.grey.shade600, width: 1.5),
            right: BorderSide(color: Colors.grey.shade600, width: 1.5),
            horizontalInside: BorderSide(color: Colors.grey.shade300, width: 1),
            verticalInside: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          columnSpacing: 10,
          columns: _createColumns(),
          rows: () {
            final total = _hitungTotalPenjualan();

            final rows = listPenjualan.asMap().entries.map((entry) {
              int index = entry.key;
              var fruit = entry.value;

              var date = DateTime.parse(fruit['created_at'].toString());
              var tanggalNow = DateFormat('HH:mm:ss').format(date);

              return DataRow(
                cells: [
                  DataCell(SizedBox(width: 25, child: Text('${index + 1}'))),
                  DataCell(SizedBox(
                      width: 150,
                      child: Text(fruit['nama_barang'].toString()))),
                  DataCell(SizedBox(width: 50, child: Text(tanggalNow))),
                  DataCell(SizedBox(
                      width: 25, child: Text(fruit['qty'].toString()))),
                  DataCell(SizedBox(
                      width: 100,
                      child: Text(currencyFormatter
                          .format(double.tryParse(fruit['harga_jual']) ?? 0)))),
                  DataCell(SizedBox(
                      width: 100,
                      child: Text(currencyFormatter
                          .format(double.tryParse(fruit['total']) ?? 0)))),
                  DataCell(SizedBox(
                      width: lebar,
                      child: Text(currencyFormatter
                          .format(double.tryParse(fruit['laba_kotor']) ?? 0)))),
                ],
              );
            }).toList();

            // 🔥 Baris TOTAL
            rows.add(
              DataRow(
                color: MaterialStateProperty.all(Colors.grey.shade200),
                cells: [
                  const DataCell(Text('')),
                  const DataCell(
                    Text(
                      'TOTAL',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const DataCell(Text('')),
                  DataCell(
                    Text(
                      total['qty']!.toStringAsFixed(0),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const DataCell(Text('')),
                  DataCell(
                    Text(
                      currencyFormatter.format(total['omset']),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      currencyFormatter.format(total['laba']),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            );

            return rows;
          }(),
        ));
  }

  var nama;
  var kodeBar;
  var stok;
  var hargaJual;
  var hargaBeli;
  var idKategori;

  var lastProduk = [];

  void cekMysql(kodeBar) async {
    helper!.getProduk(kodeBar).then((prod) {
      //setState(() {
      lastProduk = prod;
      nama = lastProduk.first['nama_barang'].toString();
      kodeBar = lastProduk.first['kode'].toString();
      stok = lastProduk.first['stok'].toString();
      hargaJual = lastProduk.first['harga_jual'].toString();
      hargaBeli = lastProduk.first['harga_beli'].toString();
      idKategori = lastProduk.first['id_kategori'].toString();
      //});
    });

    insertMysql(nama, kodeBar, stok, hargaJual, hargaBeli, idKategori);
  }

  void insertMysql(
      nama, kodeBar, stok, hargaJual, hargaBeli, idKategori) async {
    Map data = {
      'nama_barang': nama,
      'kode': kodeBar,
      'stok': stok,
      'harga_jual': hargaJual,
      'harga_beli': hargaBeli,
      'id_kategori': idKategori,
    };

    String url;

    url = 'add_produk_mobile';

    // final response = await htpp.post(Uri.parse(url), body: data);
    final response = await Network().getData_post(data, url);
    // var c = json.decode(response.body);

    if (response.statusCode == 200) {
      print('sukses');
    } else {
      print(response.body);
      throw Exception('Failed to load album');
    }
  }

  List<DataColumn> _createColumns() {
    return [
      DataColumn(
        label: Container(
          // margin: EdgeInsets.only(left: 1),
          child: const Text('No',
              //textAlign: TextAlign.left,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              )),
        ),
      ),
      const DataColumn(
          label: Text('Nama Produk',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ))),
      const DataColumn(
          label: Text('Waktu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ))),
      const DataColumn(
          label: Text('JML',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ))),
      const DataColumn(
          label: Text('Harga Jual / Unit',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ))),
      const DataColumn(
          label: Text('Nilai',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ))),
      const DataColumn(
          label: Text('Laba Kotor',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ))),
    ];
  }

  var tanggals;

  List<DropdownItem> level = [
    DropdownItem('1', 'Tunai'),
    DropdownItem('2', 'E-Wallet'),
  ];

  DropdownItem? selectedItem;
  Container keuangan() {
    var tanggalNow = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final format = DateFormat("yyyy-MM-dd");

    tanggalSkr ??= TextEditingController(
        text: _selectedDate != null ? tanggals : tanggalNow);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ===== FILTER CARD =====
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  /// DATE PICKER
                  DateTimeField(
                    format: format,
                    controller: tanggalSkr,
                    decoration: InputDecoration(
                      labelText: "Pilih Tanggal",
                      prefixIcon: const Icon(Icons.date_range),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onShowPicker: (context, currentValue) async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        firstDate: DateTime(1900),
                        initialDate: currentValue ?? DateTime.now(),
                        lastDate: DateTime(2100),
                      );

                      if (pickedDate != null) {
                        setState(() {
                          _selectedDate = pickedDate;
                          tanggals =
                              DateFormat('yyyy-MM-dd').format(pickedDate);

                          fetchLaporan(tanggals, selectedItem?.id ?? 0);
                          fetchListLaporan(tanggals, selectedItem?.id ?? 0);
                          fetchListLaporanPemasukan(tanggals);
                          fetchListLaporanPengeluaran(tanggals);
                        });
                      }
                      return pickedDate;
                    },
                  ),

                  const SizedBox(height: 16),

                  /// DROPDOWN
                  DropdownButtonFormField<DropdownItem>(
                    value: selectedItem,
                    decoration: InputDecoration(
                      labelText: "Status Bayar",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: level.map((item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(item.statusBayar),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedItem = newValue;
                        fetchLaporan(tanggals, selectedItem?.id ?? 0);
                        fetchListLaporan(tanggals, selectedItem?.id ?? 0);
                        fetchListLaporanPemasukan(tanggals);
                        fetchListLaporanPengeluaran(tanggals);
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// ===== SUMMARY SECTION =====
          Text(
            "Ringkasan Keuangan",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(child: summaryCard("LABA", untung ?? "0", Colors.green)),
              Expanded(
                  child: summaryCard("OMSET", penjualan ?? "0", Colors.blue)),
            ],
          ),

          Row(
            children: [
              Expanded(
                  child:
                      summaryCard("PEMASUKAN", uangTerima ?? "0", Colors.teal)),
              Expanded(
                  child: summaryCard(
                      "PENGELUARAN", uangKeluar ?? "0", Colors.red)),
            ],
          ),

          const SizedBox(height: 10),

          summaryCard(
            "ESTIMASI LABA BERSIH",
            labaBersihTot ?? "0",
            Colors.deepPurple,
          ),
        ],
      ),
    );
  }

  List<DataColumn> _createColumnsPemasukan() {
    return [
      DataColumn(
        label: Container(
          // margin: EdgeInsets.only(left: 1),
          child: const Text('No',
              //textAlign: TextAlign.left,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              )),
        ),
      ),
      const DataColumn(
          label: Text('Keterangan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ))),
      const DataColumn(
          label: Text('Nilai',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ))),
    ];
  }

  double _totalPemasukan() {
    double total = 0;

    for (var item in listPemasukan) {
      total += double.tryParse(item['nilai'].toString()) ?? 0;
    }

    return total;
  }

  DataTable _createDataTablePemasukan() {
    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    // final currencyFormatter = CurrencyFormatter();

    double lebar = MediaQuery.of(context).size.width;
    return DataTable(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 2, 57, 102),
      ),
      dataRowColor: MaterialStateColor.resolveWith(
        (states) {
          return Colors.white;
        },
      ),
      border: TableBorder.all(
        width: 1.0,
      ),
      columnSpacing: 10,
      columns: _createColumnsPemasukan(),
      rows: () {
        double total = _totalPemasukan();

        final rows = listPemasukan.asMap().entries.map((entry) {
          int index = entry.key;
          var fruit = entry.value;

          return DataRow(
            cells: [
              DataCell(
                SizedBox(width: 10, child: Text('${index + 1}')),
              ),
              DataCell(
                SizedBox(
                    width: 150, child: Text(fruit['keterangan'].toString())),
              ),
              DataCell(
                SizedBox(
                  width: lebar,
                  child: Text(
                    currencyFormatter.format(
                      double.tryParse(fruit['nilai']) ?? 0,
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList();

        // BARIS TOTAL
        rows.add(
          DataRow(
            color: MaterialStateProperty.all(Colors.green.shade50),
            cells: [
              const DataCell(Text('')),
              const DataCell(
                Text(
                  'TOTAL',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(
                Text(
                  currencyFormatter.format(total),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
        );

        return rows;
      }(),
    );
  }

  double _totalPengeluaran() {
    double total = 0;

    for (var item in listPengeluaran) {
      total += double.tryParse(item['nilai'].toString()) ?? 0;
    }

    return total;
  }

  DataTable _createDataTablePengeluaran() {
    // final currencyFormatter = CurrencyFormatter();
    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    double lebar = MediaQuery.of(context).size.width;
    return DataTable(
      headingRowColor: MaterialStateProperty.all(
        Colors.red.shade700,
      ),
      dataRowColor: MaterialStateProperty.all(
        Colors.white,
      ),
      border: TableBorder(
        top: BorderSide(color: Colors.grey.shade600, width: 1.5),
        bottom: BorderSide(color: Colors.grey.shade600, width: 1.5),
        left: BorderSide(color: Colors.grey.shade600, width: 1.5),
        right: BorderSide(color: Colors.grey.shade600, width: 1.5),
        horizontalInside: BorderSide(color: Colors.grey.shade300, width: 1),
        verticalInside: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      columnSpacing: 10,
      columns: _createColumnsPemasukan(),
      rows: () {
        double total = _totalPengeluaran();

        final rows = listPengeluaran.asMap().entries.map((entry) {
          int index = entry.key;
          var fruit = entry.value;

          return DataRow(
            cells: [
              DataCell(
                SizedBox(width: 10, child: Text('${index + 1}')),
              ),
              DataCell(
                SizedBox(
                    width: 150, child: Text(fruit['keterangan'].toString())),
              ),
              DataCell(
                SizedBox(
                  width: lebar,
                  child: Text(
                    currencyFormatter.format(
                      double.tryParse(fruit['nilai']) ?? 0,
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList();

        // 🔥 Baris TOTAL
        rows.add(
          DataRow(
            color: MaterialStateProperty.all(Colors.red.shade50),
            cells: [
              const DataCell(Text('')),
              const DataCell(
                Text(
                  'TOTAL',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(
                Text(
                  currencyFormatter.format(total),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        );

        return rows;
      }(),
    );
  }

  Container headerSaldo() {
    return Container(
      width: double.infinity,
      height: 40,
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 2, 57, 102),
        //  border: Border.all(color: Colors.white)
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "SALDO",
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    tanggalSkr.dispose();

    // diskon.dispose();
    //priceAfterDiscount.dispose();
    super.dispose();
  }
}

class DropdownItem {
  final String id;
  final String statusBayar;

  DropdownItem(this.id, this.statusBayar);
}
