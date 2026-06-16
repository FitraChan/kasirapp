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

class AllLaporanPerBulanSqlite extends StatefulWidget {
  const AllLaporanPerBulanSqlite({Key? key, required this.title})
      : super(key: key);
  final String title;

  @override
  _AllLaporanPerBulanSqliteState createState() =>
      _AllLaporanPerBulanSqliteState();
}

class _AllLaporanPerBulanSqliteState extends State<AllLaporanPerBulanSqlite> {
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

    helper!.listPenjualanBulanIni(bulan).then((courses) {
      setState(() {
        listPenjualan = courses;
      });
    });

    // helper!.listKeuntunganBulanIni(bulan).then((courses) {
    //   //setState(() {
    //   keuntungan = courses;
    //   untung = keuntungan.first['total'] ?? 0;
    //   // untung = 0;
    //   //});
    // });

    helper!.totPenerimaanBulanIni(bulan).then((courses) {
      setState(() {
        penerimaan = courses;
        uangTerima = penerimaan.first['tot'].toString() ?? '0';
      });
    });

    helper!.totPengeluaranBulanIni(bulan).then((courses) {
      setState(() {
        pengeluaran = courses;

        uangKeluar = pengeluaran.first['tot'].toString() ?? '0';

        //labaBersihTot = untung - uangKeluar;
      });

      //   labaBersihTot = untung + uangTerima - uangKeluar;

      //   allIncome = untung + uangTerima;
    });
  }

  var listPemasukan = [];

  var listPengeluaran = [];
  bool _isFirstLoadRunning = false;

  void fetchListLaporanPengeluaran(tang) async {
    setState(() {
      _isFirstLoadRunning = true;
    });

    try {
      String url;

      var hasilP;

      var date = DateTime.parse(DateTime.now().toString());

      var tanggalNow = DateFormat('yyyy-MM-dd').format(date);

      if (tang == null) {
        //  url = 'penerimaanPengeluaranLaporanBulanan/$tanggalNow';

        hasilP =
            await helper!.getPenerimaanPengeluaranLaporanBulanan(tanggalNow);
      } else {
        // url = 'penerimaanPengeluaranLaporanBulanan/' + tang;

        hasilP = await helper!.getPenerimaanPengeluaranLaporanBulanan(tang);
      }

      //  final response = await Network().getData_get(url);

      var data = [];

      data = hasilP['pengeluaran'];
      setState(() {
        listPengeluaran = data;
      });
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
      var hasilPen;

      if (tang == null) {
        var date = DateTime.parse(DateTime.now().toString());

        var tanggalNow = DateFormat('dd').format(date);

        hasilPen = await helper!.produkTerlaris(tanggalNow);
      } else {
        var date = DateTime.parse(tang);

        var tanggalNow = DateFormat('dd').format(date);
        hasilPen = await helper!.produkTerlaris(tanggalNow);
      }

      var data = [];

      data = hasilPen['penerimaan'];
      setState(() {
        listPemasukan = data;
      });
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
      var hasilPen;

      var date = DateTime.parse(DateTime.now().toString());

      var tanggalNow = DateFormat('yyyy-MM-dd').format(date);

      if (tang == null) {
        //   url = 'penerimaanPengeluaranLaporanBulanan/$tanggalNow';

        hasilPen =
            await helper!.getPenerimaanPengeluaranLaporanBulanan(tanggalNow);
      } else {
        //  url = 'penerimaanPengeluaranLaporanBulanan/' + tang;
        hasilPen = await helper!.getPenerimaanPengeluaranLaporanBulanan(tang);
      }

      var data = [];

      data = hasilPen['penerimaan'];
      setState(() {
        listPemasukan = data;
      });
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

    try {
      // const String _url = 'http://192.168.5.10/bprs_api/public/api/show_cuti';

      // String _url = 'list_laporan_today';

      String url;

      var listLaporan;

      var date = DateTime.parse(DateTime.now().toString());

      var tanggalNow = DateFormat('yyyy-MM-dd').format(date);

      // if (tang == null) {
      //   url = 'list_laporan_bulanan/$tanggalNow';
      // } else {
      //   url = 'list_laporan_bulanan/' + tang;
      // }

      if (tang == null && status != 0) {
        //  url = 'list_laporan_bulanan/$tanggalNow/$status';

        listLaporan = await helper!.listLaporanBulanan(tanggalNow, status);
      } else if (tang != null && status != 0) {
        // url = 'list_laporan_bulanan/$tanggalNow/$status';
        listLaporan = await helper!.listLaporanBulanan(tanggalNow, status);
      } else if (tang != null && status == 0) {
        // url = '${'list_laporan_bulanan/' + tang}/0';
        listLaporan = await helper!.listLaporanBulanan(tang, 0);
      } else {
        //url = 'list_laporan_bulanan/$tanggalNow/0';

        listLaporan = await helper!.listLaporanBulanan(tanggalNow, 0);
      }
      //    final response = await Network().getData_get(url);
      //  if (response.statusCode == 200) {
      // setState(() {
      //   listPenjualan = listLaporan;
      // });
      // } else {
      //   throw Exception('Failed to load album');
      // }
    } catch (e) {
      print('Something went wrong cuy');
    }

    setState(() {});
  }

  void fetchLaporan(tang, status) async {
    //  String _url = 'http://192.168.5.10/bprs_api/public/api/profil';

    var date = DateTime.parse(DateTime.now().toString());

    var tanggalNow = DateFormat('yyyy-MM-dd').format(date);

    var lapBulan;

    // if (tang == null) {
    //   url = 'laporan_bulanan/$tanggalNow';
    // } else {
    //   url = 'laporan_bulanan/' + tang;
    // }

    if (tang == null && status != 0) {
      //  url = 'laporan_bulanan/$tanggalNow/$status';

      lapBulan = await helper!.laporanBulanan(tanggalNow, status);
    } else if (tang != null && status != 0) {
      //  url = '${'laporan_bulanan/' + tang}/$status';

      lapBulan = await helper!.laporanBulanan(tang, status);
    } else if (tang != null && status == 0) {
      // url = '${'laporan_bulanan/' + tang}/0';

      lapBulan = await helper!.laporanBulanan(tang, 0);
    } else {
      // url = 'laporan_bulanan/$tanggalNow/0';

      lapBulan = await helper!.laporanBulanan(tanggalNow, 0);
    }

    // final response = await Network().getData_get(url);
    // //  print(response.body);
    // var c = json.decode(response.body);
    // if (response.statusCode == 200) {
    // var b = json.decode(response.body);
    // var b = c['absen'];
    setState(() {
      penjualan = currencyFormatter.format(lapBulan['result_omset'].toString());
      untung = currencyFormatter.format(lapBulan['result_laba'].toString());
      // uangTerima =
      //     currencyFormatter.format(lapBulan['result_masuk'].toString());
      // uangKeluar =
      //     currencyFormatter.format(lapBulan['result_keluar'].toString());
      labaBersihTot =
          currencyFormatter.format(lapBulan['laba_bersih_tot'].toString());
      allIncome = currencyFormatter.format(lapBulan['all_income'].toString());
      _isLoading = false;
    });
    // } else {
    //   throw Exception('Failed to load album');
    // }
  }

  void refreshListPenjualan(bulan) async {
    //  widget.tanggal = tgl;
    helper!.listPenjualanBulanIni(bulan).then((courses) {
      setState(() {
        listPenjualan = courses;
      });
    });
  }

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
              title: const Text('Belajar Flutter'),

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
                  MediaQuery.of(context).orientation == Orientation.landscape
                      ? listJumlahLanscape()
                      : listJumlah(),
                  const SizedBox(
                    height: 4,
                  ),
                  headerPemasukan(),
                  _createDataTablePemasukan(),
                  const SizedBox(
                    height: 4,
                  ),
                  headerPengeluaran(),
                  _createDataTablePengeluaran(),
                ]))));
  }

  Container listJumlah() {
    return Container(
        //height: 80,
        child: Table(
            columnWidths: const {
              0: FlexColumnWidth(2.3),
              1: FlexColumnWidth(2.5),
              2: FlexColumnWidth(3),
            },
            //  defaultColumnWidth: FixedColumnWidth(120.0),
            border: TableBorder.all(
                color: Colors.black, style: BorderStyle.solid, width: 1),
            children: [
              TableRow(children: [
                Column(children: [
                  Container(
                      height: 40,
                      padding: const EdgeInsets.only(top: 10),
                      child: const Text('Jumlah',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)))
                ]),
                Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          padding: const EdgeInsets.only(left: 3, top: 10),
                          child: Text(
                              penjualan != null ? penjualan.toString() : '',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)))
                    ]),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          padding: const EdgeInsets.only(left: 3, top: 10),
                          child: Text(untung.toString(),
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)))
                    ]),
              ])
            ]));
  }

  Container listJumlahLanscape() {
    return Container(
        //height: 80,
        child: Table(
            columnWidths: const {
              0: FlexColumnWidth(0.8),
              1: FlexColumnWidth(0.9),
              2: FlexColumnWidth(3.2),
            },
            //  defaultColumnWidth: FixedColumnWidth(120.0),
            border: TableBorder.all(
                color: Colors.black, style: BorderStyle.solid, width: 1),
            children: [
              TableRow(children: [
                Column(children: [
                  Container(
                      height: 40,
                      padding: const EdgeInsets.only(top: 10),
                      child: const Text('Jumlah',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)))
                ]),
                Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          padding: const EdgeInsets.only(left: 3, top: 10),
                          child: Text(
                              penjualan != null ? penjualan.toString() : '',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)))
                    ]),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          padding: const EdgeInsets.only(left: 3, top: 10),
                          child: Text(untung.toString(),
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)))
                    ]),
              ])
            ]));
  }

  ConstrainedBox _createDataTable() {
    return ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.infinity),
        child: DataTable(
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
            columnSpacing: 5,
            columns: _createColumns(),
            rows: _createRows()));
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

  List<DataRow> _createRows() {
    // var no = 1;

    double screenWidth = MediaQuery.of(context).size.width;
    return listPenjualan
        .map((listPenjualan) => DataRow(cells: [
              DataCell(
                  SizedBox(width: 80, child: Text(listPenjualan['tanggal']))),
              DataCell(SizedBox(
                  width: 110,
                  child: Text(currencyFormatter
                      .format(listPenjualan['nilai'].toString())))),
              DataCell(SizedBox(
                  width: screenWidth,
                  child: Text(currencyFormatter
                      .format(listPenjualan['total'].toString()))))
            ]))
        .toList();
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

        // refreshOmset(bulan);
        // refreshLaba(bulan);
        // refreshPenerimaan(bulan);
        // refreshPengeluaran(bulan);

        // refreshListPenjualan(bulan);

        //  refreshLabaBersih(bulan);
      });
    }
  }

  Container keuangan() {
    var date = DateTime.parse(DateTime.now().toString());

    var tanggalNow = DateFormat('yMMMM').format(date);
    //   tanggals = DateFormat('yMMMM').format(DateTime.now());

    return Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(left: 9),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                  ),
                  onPressed: () {
                    _onPressed(context: context);
                  },
                  child: const Text('Select Date')),
            ),
            const Spacer(),
            Container(
              margin: const EdgeInsets.only(right: 9),
              child: Text(
                tanggals ?? tanggalNow,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            )
          ],
        ),
        Container(
          //margin: EdgeInsets.only(lefttop: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          width: double.infinity,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<DropdownItem>(
              hint: const Text('Status Bayar'),
              value: selectedItem,
              onChanged: (DropdownItem? newValue) {
                setState(() {
                  selectedItem = newValue;
                  fetchLaporan(tanggals, selectedItem!.id);
                  fetchListLaporan(tanggals, selectedItem!.id);
                  fetchListLaporanPemasukan(tanggals);
                  fetchListLaporanPengeluaran(tanggals);
                });
              },
              items: level.map((DropdownItem item) {
                return DropdownMenuItem<DropdownItem>(
                  value: item,
                  child: Text(item.statusBayar),
                );
              }).toList(),
            ),
          ),
        ),
        Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: Table(
                border: TableBorder.symmetric(
                    inside: const BorderSide(
                        width: 1, color: Color.fromARGB(255, 197, 194, 194)),
                    outside: const BorderSide(
                        width: 1, color: Color.fromARGB(255, 197, 194, 194))),
                //defaultColumnWidth: const FixedColumnWidth(150),
                //  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(
                      decoration: BoxDecoration(color: Colors.grey[200]),
                      children: [
                        Container(
                          height: 30,
                          //  width: 200,
                          color: const Color.fromARGB(255, 2, 57, 102),
                          child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'LABA',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                              ]),
                        ),
                      ]),
                  TableRow(
                      decoration: BoxDecoration(color: Colors.grey[200]),
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 3),
                          height: 30,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(left: 10),
                                  child: Text(
                                    untung.toString(),
                                    style: const TextStyle(),
                                  ),
                                ),
                              ]),
                        ),
                      ]),
                ],
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: Table(
                border: TableBorder.symmetric(
                    inside: const BorderSide(
                        width: 1, color: Color.fromARGB(255, 197, 194, 194)),
                    outside: const BorderSide(
                        width: 1, color: Color.fromARGB(255, 197, 194, 194))),
                //defaultColumnWidth: const FixedColumnWidth(150),
                //  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(
                      decoration: BoxDecoration(color: Colors.grey[200]),
                      children: [
                        Container(
                          height: 30,
                          //  width: 200,
                          color: const Color.fromARGB(255, 2, 57, 102),
                          child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'OMSET',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                              ]),
                        ),
                      ]),
                  TableRow(
                      decoration: BoxDecoration(color: Colors.grey[200]),
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 3),
                          height: 30,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(left: 10),
                                  child: Text(
                                    penjualan != null
                                        ? penjualan.toString()
                                        : '',
                                    style: const TextStyle(),
                                  ),
                                ),
                              ]),
                        ),
                      ]),
                ],
              ),
            ),
          ],
        ),
        Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: Table(
                border: TableBorder.symmetric(
                    inside: const BorderSide(
                        width: 1, color: Color.fromARGB(255, 197, 194, 194)),
                    outside: const BorderSide(
                        width: 1, color: Color.fromARGB(255, 197, 194, 194))),
                //defaultColumnWidth: const FixedColumnWidth(150),
                //  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(
                      decoration: BoxDecoration(color: Colors.grey[200]),
                      children: [
                        Container(
                          height: 30,
                          //  width: 200,
                          color: const Color.fromARGB(255, 2, 57, 102),
                          child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'PEMASUKAN',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                              ]),
                        ),
                      ]),
                  TableRow(
                      decoration: BoxDecoration(color: Colors.grey[200]),
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 3),
                          height: 30,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(left: 10),
                                  child: Text(
                                    currencyFormatter
                                        .format(uangTerima.toString()),
                                    style: const TextStyle(),
                                  ),
                                ),
                              ]),
                        ),
                      ]),
                ],
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: Table(
                border: TableBorder.symmetric(
                    inside: const BorderSide(
                        width: 1, color: Color.fromARGB(255, 197, 194, 194)),
                    outside: const BorderSide(
                        width: 1, color: Color.fromARGB(255, 197, 194, 194))),
                //defaultColumnWidth: const FixedColumnWidth(150),
                //  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(
                      decoration: BoxDecoration(color: Colors.grey[200]),
                      children: [
                        Container(
                          height: 30,
                          //  width: 200,
                          color: const Color.fromARGB(255, 2, 57, 102),
                          child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'PENGELUARAN',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                              ]),
                        ),
                      ]),
                  TableRow(
                      decoration: BoxDecoration(color: Colors.grey[200]),
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 3),
                          height: 30,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(left: 10),
                                  child: Text(
                                    currencyFormatter
                                        .format(uangKeluar.toString()),
                                    style: const TextStyle(),
                                  ),
                                ),
                              ]),
                        ),
                      ]),
                ],
              ),
            ),
          ],
        ),
        SizedBox(
          width: double.infinity,
          child: Table(
            border: TableBorder.symmetric(
                inside: const BorderSide(
                    width: 1, color: Color.fromARGB(255, 197, 194, 194)),
                outside: const BorderSide(
                    width: 1, color: Color.fromARGB(255, 197, 194, 194))),
            //defaultColumnWidth: const FixedColumnWidth(150),
            //  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                  decoration: BoxDecoration(color: Colors.grey[200]),
                  children: [
                    Container(
                      height: 30,
                      width: double.infinity,
                      color: const Color.fromARGB(255, 2, 57, 102),
                      child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'ESTIMASI LABA BERSIH',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ]),
                    ),
                  ]),
              TableRow(
                  decoration: BoxDecoration(color: Colors.grey[200]),
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 3),
                      height: 30,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(left: 10),
                              child: Text(
                                labaBersihTot.toString(),
                                style: const TextStyle(),
                              ),
                            ),
                          ]),
                    ),
                  ]),
            ],
          ),
        ),
        SizedBox(
          width: double.infinity,
          //   margin: EdgeInsets.only(top: 10),
          child: Table(
            border: TableBorder.symmetric(
                inside: const BorderSide(
                    width: 1, color: Color.fromARGB(255, 197, 194, 194)),
                outside: const BorderSide(
                    width: 1, color: Color.fromARGB(255, 197, 194, 194))),
            //defaultColumnWidth: const FixedColumnWidth(150),
            //  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                  decoration: BoxDecoration(color: Colors.grey[200]),
                  children: [
                    Container(
                      height: 30,
                      width: double.infinity,
                      color: const Color.fromARGB(255, 2, 57, 102),
                      child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'KEUANGAN',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ]),
                    ),
                  ]),
              TableRow(
                  decoration: BoxDecoration(color: Colors.grey[200]),
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 3),
                      height: 30,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(left: 10),
                                  child: const Text(
                                    'KAS',
                                    style: TextStyle(),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  child: Text(
                                    labaBersihTot.toString(),
                                    style: const TextStyle(),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 2,
                            ),
                            Container(
                              margin: const EdgeInsets.only(left: 10),
                              child: Text(
                                "$allIncome - $uangKeluar",
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                          ]),
                    ),
                  ]),
            ],
          ),
        ),
        Container(
          width: double.infinity,

          height: 40,
          decoration: BoxDecoration(
              color: const Color.fromARGB(255, 2, 57, 102),
              border: Border.all(color: Colors.white)),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "TRANSAKSI PENJUALAN",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          //color: Color.fromARGB(255, 2, 57, 102),
        )
      ],
    ));
  }

  Container headerPemasukan() {
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
            "PEMASUKAN",
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Container headerPengeluaran() {
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
            "PENGELUARAN",
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

  DataTable _createDataTablePemasukan() {
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
      rows: listPemasukan
          .asMap()
          .map((index, fruit) {
            final tanggal = fruit['created_at'] ?? DateTime.now().toString();
            current = DateTime.parse(tanggal);

            currentString = DateFormat('dd-MM-yyyy').format(current);
            final dataRow = DataRow(
              cells: [
                DataCell(
                  SizedBox(width: 10, child: Text('${index + 1}')),
                ),
                DataCell(SizedBox(width: 150, child: Text(currentString))),
                DataCell(SizedBox(
                    width: lebar,
                    child: Text(
                        currencyFormatter.format(fruit['nilai'].toString())))),
                //DataCell(SizedBox(width: lebar, child: Text((currentString))))
              ],
            );
            return MapEntry(index, dataRow);
          })
          .values
          .toList(),
    );
  }

  DataTable _createDataTablePengeluaran() {
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
      rows: listPengeluaran
          .asMap()
          .map((index, fruit) {
            final tanggal = fruit['created_at'] ?? DateTime.now().toString();
            current = DateTime.parse(tanggal);

            currentString = DateFormat('dd-MM-yyyy').format(current);
            final dataRow = DataRow(
              cells: [
                DataCell(
                  SizedBox(width: 10, child: Text('${index + 1}')),
                ),
                DataCell(SizedBox(width: 150, child: Text(currentString))),
                DataCell(SizedBox(
                    width: lebar,
                    child: Text(
                        currencyFormatter.format(fruit['nilai'].toString())))),
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
