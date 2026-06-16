import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:kasirapp/laporan/menuLaporan.dart';

import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:month_year_picker/month_year_picker.dart';

import 'package:kasirapp/model/currencyFormatter.dart';
import 'package:kasirapp/network_utils/api.dart';
import 'package:kasirapp/screen/home.dart';

import '../screen/menu1.dart';

//import 'package:firebase_messaging/firebase_messaging.dart';

class AllLaporanPerBulan extends StatefulWidget {
  const AllLaporanPerBulan({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _AllLaporanPerBulanState createState() => _AllLaporanPerBulanState();
}

class _AllLaporanPerBulanState extends State<AllLaporanPerBulan> {
  //  FirebaseMessaging messaging;
  final currencyFormatter = CurrencyFormatter();
  bool _isLoading = true;
  KasirHelper? helper;
  var items = [];
  var keuntungan = [];
  String? untung;
  var penjualan;

  var listPenjualan = [];

  String? laba;
  var labaBersih = [];
  String? labaBersihTot;

  String? uangKeluar;
  var pengeluaran = [];

  String? uangTerima;
  var penerimaan = [];
  String? allIncome;

  var allCourses = [];
  final oCcy = NumberFormat.decimalPattern();

  List<DropdownItem> level = [
    DropdownItem('1', 'Tunai'),
    DropdownItem('2', 'E-Wallet'),
  ];

  DropdownItem? selectedItem;

  var bulan;

  @override
  void initState() {
    super.initState();

    helper = KasirHelper();

    fetchLaporan(bulan, 0);
    fetchListLaporan(bulan, 0);
    fetchListLaporanPemasukan(bulan);
    fetchListLaporanPengeluaran(bulan);
    fetchListProdukTerlaris(bulan);

    // helper!.totPenjualanBulanIni(bulan).then((courses) {
    //   setState(() {
    //     // allCourses = courses;
    //     items = courses;

    //     if (items.isNotEmpty) {
    //       penjualan = items.first['tot_harga'];
    //     } else {
    //       penjualan = 0;
    //     }
    //     //_isLoading = false;
    //   });
    // });

    // helper!.listPenjualanBulanIni(bulan).then((courses) {
    //   setState(() {
    //     listPenjualan = courses;
    //   });
    // });

    // helper!.listKeuntunganBulanIni(bulan).then((courses) {
    //   //setState(() {
    //   keuntungan = courses;
    //   untung = keuntungan.first['total'] ?? 0;
    //   // untung = 0;
    //   //});
    // });

    // helper!.totPenerimaanBulanIni(bulan).then((courses) {
    //   setState(() {
    //     penerimaan = courses;
    //     uangTerima = penerimaan.first['tot'] ?? 0;
    //   });
    // });

    // helper!.totPengeluaranBulanIni(bulan).then((courses) {
    //   setState(() {
    //     pengeluaran = courses;
    //     uangKeluar = pengeluaran.first['tot'] ?? 0;

    //     //labaBersihTot = untung - uangKeluar;
    //   });

    //   labaBersihTot = untung + uangTerima - uangKeluar;

    //   allIncome = untung + uangTerima;
    // });
  }

  var listPemasukan = [];

  var listPengeluaran = [];

  var listProdukTerlaris = [];

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
        url = 'penerimaanPengeluaranLaporanBulanan/$tanggalNow';
      } else {
        url = 'penerimaanPengeluaranLaporanBulanan/' + tang;
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

  void fetchListProdukTerlaris(tang) async {
    setState(() {
      _isFirstLoadRunning = true;
    });

    try {
      String url;

      if (tang == null) {
        var date = DateTime.parse(DateTime.now().toString());

        var tanggalNow = DateFormat('MM').format(date);

        url = 'produkTerlaris/$tanggalNow';
      } else {
        var date = DateTime.parse(tang);

        var tanggalNow = DateFormat('MM').format(date);
        url = 'produkTerlaris/' + tanggalNow;
      }

      final response = await Network().getData_get(url);
      if (response.statusCode == 200) {
        var data = [];
        var c = json.decode(response.body);

        data = c['data'];

        setState(() {
          listProdukTerlaris = data;
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
        url = 'penerimaanPengeluaranLaporanBulanan/$tanggalNow';
      } else {
        url = 'penerimaanPengeluaranLaporanBulanan/' + tang;
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
    setState(() {});
    var response;

    try {
      // const String _url = 'http://192.168.5.10/bprs_api/public/api/show_cuti';

      // String _url = 'list_laporan_today';

      String url;

      var date = DateTime.parse(DateTime.now().toString());
      var tanggalNow = DateFormat('yyyy-MM-dd').format(date);

      // if (tang == null) {
      //   url = 'list_laporan_bulanan/$tanggalNow';
      // } else {
      //   url = 'list_laporan_bulanan/' + tang;
      // }

      if (tang == null && status != 0) {
        url = 'list_laporan_bulanan/$tanggalNow/$status';
      } else if (tang != null && status != 0) {
        url = 'list_laporan_bulanan/$tanggalNow/$status';
      } else if (tang != null && status == 0) {
        url = '${'list_laporan_bulanan/' + tang}/0';
      } else {
        url = 'list_laporan_bulanan/$tanggalNow/0';
      }
      response = await Network().getData_get(url);
      if (response.statusCode == 200) {
        setState(() {
          listPenjualan = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load album');
      }
    } catch (e) {
      print(response.body);
      print('Something went wrong cuy');
    }

    setState(() {});
  }

  void fetchLaporan(tang, status) async {
    //  String _url = 'http://192.168.5.10/bprs_api/public/api/profil';
    String url;

    var date = DateTime.parse(DateTime.now().toString());

    var tanggalNow = DateFormat('yyyy-MM-dd').format(date);

    // if (tang == null) {
    //   url = 'laporan_bulanan/$tanggalNow';
    // } else {
    //   url = 'laporan_bulanan/' + tang;
    // }

    if (tang == null && status != 0) {
      url = 'laporan_bulanan/$tanggalNow/$status';
    } else if (tang != null && status != 0) {
      url = '${'laporan_bulanan/' + tang}/$status';
    } else if (tang != null && status == 0) {
      url = '${'laporan_bulanan/' + tang}/0';
    } else {
      url = 'laporan_bulanan/$tanggalNow/0';
    }

    final response = await Network().getData_get(url);
    //  print(response.body);
    var c = json.decode(response.body);
    if (response.statusCode == 200) {
      // var b = json.decode(response.body);
      // var b = c['absen'];
      setState(() {
        penjualan = currencyFormatter.format(c['result_omset'].toString());
        untung = currencyFormatter.format(c['result_laba'].toString());
        uangTerima = currencyFormatter.format(c['result_masuk'].toString());
        uangKeluar = currencyFormatter.format(c['result_keluar'].toString());
        labaBersihTot =
            currencyFormatter.format(c['laba_bersih_tot'].toString());
        allIncome = currencyFormatter.format(c['all_income'].toString());
        _isLoading = false;
      });
    } else {
      print(response.body);
      throw Exception('Failed to load album');
    }
  }

  // void refreshListPenjualan(bulan) async {
  //   //  widget.tanggal = tgl;
  //   helper!.listPenjualanBulanIni(bulan).then((courses) {
  //     setState(() {
  //       listPenjualan = courses;
  //     });
  //   });
  // }

  // void refreshOmset(bulan) async {
  //   //  widget.tanggal = tgl;
  //   helper!.totPenjualanBulanIni(bulan).then((courses) {
  //     //  setState(() {
  //     items = courses;

  //     if (items.isNotEmpty) {
  //       penjualan = items.first['tot_harga'];
  //     } else {
  //       penjualan = 0;
  //     }

  //     //_isLoading = false;
  //     // });
  //   });
  // }

  // void refreshLaba(bulan) async {
  //   //  widget.tanggal = tgl;
  //   helper!.listKeuntunganBulanIni(bulan).then((courses) {
  //     //setState(() {
  //     keuntungan = courses;
  //     untung = keuntungan.first['total'] ?? 0;
  //     //});
  //   });
  // }

  // void refreshPengeluaran(bulan) async {
  //   //  widget.tanggal = tgl;
  //   helper!.totPengeluaranBulanIni(bulan).then((courses) {
  //     setState(() {
  //       pengeluaran = courses;
  //       uangKeluar = pengeluaran.first['tot'] ?? 0;

  //       //labaBersihTot = untung - uangKeluar;
  //       labaBersihTot = untung + uangTerima - uangKeluar;

  //       allIncome = untung + uangTerima;
  //     });
  //   });
  // }

  // void refreshPenerimaan(bulan) async {
  //   //  widget.tanggal = tgl;
  //   helper!.totPenerimaanBulanIni(bulan).then((courses) {
  //     setState(() {
  //       penerimaan = courses;
  //       uangTerima = penerimaan.first['tot'] ?? 0;
  //     });
  //   });
  // }

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
              //Menambahkan TitleBar
              title: const Text(
                'Laporan Bulanan',
                style: TextStyle(color: Colors.white),
              ),

              //Mengubah Warna Background
              backgroundColor: Colors.red[900],
              //Menambahkan Leading menu
              leading: IconButton(
                icon: const Icon(Icons.home, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Home(
                              title: '',
                            )),
                  );
                },
              ),
              //Menambahkan Beberapa Action Button
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
            drawer: const Menu(),
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  keuangan(),
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
                  sectionHeader("PRODUK TERLARIS"),
                  _createDataTableProdukTerlaris()
                ]))));
  }

  Widget keuangan() {
    var tanggalNow = DateFormat('yMMMM').format(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ===== HEADER FILTER =====
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _onPressed(context: context),
                    icon: const Icon(Icons.calendar_month),
                    label: const Text(
                      "Pilih Bulan",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    tanggals ?? tanggalNow,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  )
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          /// ===== DROPDOWN =====
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
                fetchLaporan(bulan, selectedItem?.id ?? 0);
                fetchListLaporan(bulan, selectedItem?.id ?? 0);
                fetchListLaporanPemasukan(bulan);
                fetchListLaporanPengeluaran(bulan);
                fetchListProdukTerlaris(bulan);
              });
            },
          ),

          const SizedBox(height: 20),

          /// ===== SUMMARY GRID =====
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            children: [
              summaryCard("LABA", untung.toString(), Colors.green),
              summaryCard("OMSET", penjualan.toString(), Colors.blue),
              summaryCard("PEMASUKAN", uangTerima.toString(), Colors.teal),
              summaryCard("PENGELUARAN", uangKeluar.toString(), Colors.red),
              summaryCard(
                  "LABA BERSIH", labaBersihTot.toString(), Colors.deepPurple),
              summaryCard("TOTAL INCOME", allIncome.toString(), Colors.orange),
            ],
          ),

          const SizedBox(height: 20),

          sectionHeader("TRANSAKSI PENJUALAN"),
        ],
      ),
    );
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
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold),
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

  Widget sectionHeader(String title) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.indigo.shade800,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _createDataTable() {
    double lebar = MediaQuery.of(context).size.width;

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
        columnSpacing: 20,
        horizontalMargin: 16,
        columns: _createColumns(),
        rows: _createRows(),
      ),
    );
  }

  List<DataColumn> _createColumns() {
    return [
      const DataColumn(
          label: Text('Tanggal',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ))),
      const DataColumn(
          label: Text('Omset',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ))),
      const DataColumn(
          label: Text('Laba',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ))),
    ];
  }

  Map<String, double> _hitungTotal() {
    double totalOmset = 0;
    double totalLaba = 0;

    for (var item in listPenjualan) {
      totalOmset += double.tryParse(item['omset'].toString()) ?? 0;
      totalLaba += double.tryParse(item['laba'].toString()) ?? 0;
    }

    return {
      'omset': totalOmset,
      'laba': totalLaba,
    };
  }

  List<DataRow> _createRows() {
    double screenWidth = MediaQuery.of(context).size.width;
    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final rows = listPenjualan.map((item) {
      return DataRow(cells: [
        DataCell(SizedBox(width: 80, child: Text(item['tanggal']))),
        DataCell(SizedBox(
            width: 110,
            child: Text(currencyFormatter
                .format(int.tryParse(item['omset'].toString()) ?? 0)))),
        DataCell(SizedBox(
            width: screenWidth,
            child: Text(currencyFormatter
                .format(double.tryParse(item['laba'].toString()) ?? 0))))
      ]);
    }).toList();

    // 🔥 Hitung total
    final total = _hitungTotal();

    // 🔥 Tambahkan baris total
    rows.add(
      DataRow(
        color: MaterialStateProperty.all(Colors.grey.shade200),
        cells: [
          const DataCell(
            Text(
              "TOTAL",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
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
  }

  DateTime? _selected;
  var tanggals;
  Future<void> _onPressed({
    required BuildContext context,
    String? locale,
  }) async {
    final localeObj = locale != null ? Locale(locale) : null;
    final selected = await showMonthYearPicker(
      context: context,
      initialDate: _selected ?? DateTime.now(),
      firstDate: DateTime(2019),
      lastDate: DateTime.now(),
      locale: localeObj,
    );

    if (selected != null) {
      setState(() {
        _selected = selected;

        var dates = DateTime.parse(_selected.toString());

        tanggals = DateFormat('yMMMM').format(dates);
        bulan = DateFormat('yyyy-MM-dd').format(dates);

        print(bulan);

        fetchLaporan(bulan, 0);

        fetchListLaporan(bulan, 0);
        fetchListLaporanPemasukan(bulan);
        fetchListLaporanPengeluaran(bulan);

        fetchListProdukTerlaris(bulan);
      });
    }
  }

  Container headerProdukTerlaris() {
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
            "PRODUK TERLARIS",
            style: TextStyle(color: Colors.white),
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
          label: Text('Tanggal',
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

  var current;
  var currentString;

  double _hitungTotalPemasukan() {
    double total = 0;

    for (var item in listPemasukan) {
      total += double.tryParse(item['nilai'].toString()) ?? 0;
    }

    return total;
  }

  DataTable _createDataTablePemasukan() {
    // final currencyFormatter = CurrencyFormatter();
    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
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
        double total = _hitungTotalPemasukan();

        final rows = listPemasukan.asMap().entries.map((entry) {
          int index = entry.key;
          var fruit = entry.value;

          final tanggal = fruit['created_at'] ?? DateTime.now().toString();
          DateTime current = DateTime.parse(tanggal);
          String currentString = DateFormat('dd-MM-yyyy').format(current);

          return DataRow(
            cells: [
              DataCell(SizedBox(width: 10, child: Text('${index + 1}'))),
              DataCell(SizedBox(width: 150, child: Text(currentString))),
              DataCell(
                SizedBox(
                  width: lebar,
                  child: Text(
                    currencyFormatter.format(
                      int.tryParse(fruit['nilai']),
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList();

        // 🔥 Tambahkan baris TOTAL
        rows.add(
          DataRow(
            color: MaterialStateProperty.all(Colors.grey.shade200),
            cells: [
              const DataCell(
                Text(
                  '',
                ),
              ),
              const DataCell(
                Text(
                  'TOTAL',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(
                Text(
                  currencyFormatter
                      .format(double.tryParse(total.toString()) ?? 0),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
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

  double _hitungTotalPengeluaran() {
    double total = 0;

    for (var item in listPengeluaran) {
      total += double.tryParse(item['nilai'].toString()) ?? 0;
    }

    return total;
  }

  DataTable _createDataTablePengeluaran() {
    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
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
        double total = _hitungTotalPengeluaran();

        final rows = listPengeluaran.asMap().entries.map((entry) {
          int index = entry.key;
          var fruit = entry.value;

          final tanggal = fruit['created_at'] ?? DateTime.now().toString();
          DateTime current = DateTime.parse(tanggal);
          String currentString = DateFormat('dd-MM-yyyy').format(current);

          return DataRow(
            cells: [
              DataCell(
                SizedBox(width: 10, child: Text('${index + 1}')),
              ),
              DataCell(
                SizedBox(width: 150, child: Text(currentString)),
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

        // 🔥 Tambahkan baris TOTAL
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

  List<DataColumn> _createProdukTerlaris() {
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
          label: Text('Nama Barang',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ))),
      const DataColumn(
          label: Text('Qty',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ))),
      const DataColumn(
          label: Text('Total Penjualan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ))),
    ];
  }

  DataTable _createDataTableProdukTerlaris() {
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
      columns: _createProdukTerlaris(),
      rows: listProdukTerlaris
          .asMap()
          .map((index, fruit) {
            final dataRow = DataRow(
              cells: [
                DataCell(
                  SizedBox(width: 10, child: Text('${index + 1}')),
                ),
                DataCell(SizedBox(
                    width: 150, child: Text(fruit['nama_barang'].toString()))),
                DataCell(SizedBox(
                    width: 150, child: Text(fruit['total_qty'].toString()))),
                DataCell(SizedBox(
                    width: lebar,
                    child: Text(currencyFormatter
                        .format(fruit['total_penjualan'].toString())))),
                //DataCell(SizedBox(width: lebar, child: Text((currentString))))
              ],
            );
            return MapEntry(index, dataRow);
          })
          .values
          .toList(),
    );
  }
}

class DropdownItem {
  final String id;
  final String statusBayar;

  DropdownItem(this.id, this.statusBayar);
}
