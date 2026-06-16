import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kasirapp/laporan/menuLaporan.dart';

import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:kasirapp/screen/home.dart';

import '../screen/menu1.dart';

//import 'package:firebase_messaging/firebase_messaging.dart';

class PenjualanTerbanyak extends StatefulWidget {
  const PenjualanTerbanyak({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _PenjualanTerbanyakState createState() => _PenjualanTerbanyakState();
}

class _PenjualanTerbanyakState extends State<PenjualanTerbanyak> {
  //  FirebaseMessaging messaging;

  final bool _isLoading = true;
  KasirHelper? helper;
  var items = [];
  var keuntungan = [];
  int untung = 0;
  var penjualan;

  var listPenjualan = [];

  int laba = 0;
  var labaBersih = [];
  int labaBersihTot = 0;

  int uangKeluar = 0;
  var pengeluaran = [];

  int uangTerima = 0;
  var penerimaan = [];
  int allIncome = 0;

  var allCourses = [];
  final oCcy = NumberFormat.decimalPattern();

  var bulan;

  @override
  void initState() {
    super.initState();

    helper = KasirHelper();

    helper!.totPenjualanTerbanyakBulanIni(bulan).then((courses) {
      setState(() {
        // allCourses = courses;
        items = courses;

        if (items.isNotEmpty) {
          penjualan = items.first['tot_harga'];
        } else {
          penjualan = 0;
        }
        //_isLoading = false;
      });
    });

    helper!.listPenjualanBulanIni(bulan).then((courses) {
      setState(() {
        listPenjualan = courses;
      });
    });

    helper!.listKeuntunganBulanIni(bulan).then((courses) {
      //setState(() {
      keuntungan = courses;
      untung = keuntungan.first['total'] ?? 0;
      // untung = 0;
      //});
    });

    helper!.totPenerimaanBulanIni(bulan).then((courses) {
      setState(() {
        penerimaan = courses;
        uangTerima = penerimaan.first['tot'] ?? 0;
      });
    });

    helper!.totPengeluaranBulanIni(bulan).then((courses) {
      setState(() {
        pengeluaran = courses;
        uangKeluar = pengeluaran.first['tot'] ?? 0;

        //labaBersihTot = untung - uangKeluar;
      });

      labaBersihTot = untung + uangTerima - uangKeluar;

      allIncome = untung + uangTerima;
    });
  }

  void refreshListPenjualan(bulan) async {
    //  widget.tanggal = tgl;
    helper!.listPenjualanBulanIni(bulan).then((courses) {
      setState(() {
        listPenjualan = courses;
      });
    });
  }

  void refreshOmset(bulan) async {
    //  widget.tanggal = tgl;
    helper!.totPenjualanBulanIni(bulan).then((courses) {
      //  setState(() {
      items = courses;

      if (items.isNotEmpty) {
        penjualan = items.first['tot_harga'];
      } else {
        penjualan = 0;
      }

      //_isLoading = false;
      // });
    });
  }

  void refreshLaba(bulan) async {
    //  widget.tanggal = tgl;
    helper!.listKeuntunganBulanIni(bulan).then((courses) {
      //setState(() {
      keuntungan = courses;
      untung = keuntungan.first['total'] ?? 0;
      //});
    });
  }

  void refreshPengeluaran(bulan) async {
    //  widget.tanggal = tgl;
    helper!.totPengeluaranBulanIni(bulan).then((courses) {
      setState(() {
        pengeluaran = courses;
        uangKeluar = pengeluaran.first['tot'] ?? 0;

        //labaBersihTot = untung - uangKeluar;
        labaBersihTot = untung + uangTerima - uangKeluar;

        allIncome = untung + uangTerima;
      });
    });
  }

  void refreshPenerimaan(bulan) async {
    //  widget.tanggal = tgl;
    helper!.totPenerimaanBulanIni(bulan).then((courses) {
      setState(() {
        penerimaan = courses;
        uangTerima = penerimaan.first['tot'] ?? 0;
      });
    });
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
                  _createDataTable(),
                  listJumlah()
                ]))));
  }

  Container listJumlah() {
    return Container(
        //height: 80,
        child: Table(
            columnWidths: const {
              0: FlexColumnWidth(2.9),
              1: FlexColumnWidth(1.9),
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
                          child: Text(oCcy.format(untung),
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)))
                    ]),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          padding: const EdgeInsets.only(left: 3, top: 10),
                          child: Text(
                              penjualan != null ? oCcy.format(penjualan) : '',
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
          label: Text('Laba',
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

  List<DataRow> _createRows() {
    var no = 1;

    double screenWidth = MediaQuery.of(context).size.width;
    return listPenjualan
        .map((listPenjualan) => DataRow(cells: [
              DataCell(
                  SizedBox(width: 80, child: Text(listPenjualan['tanggal']))),
              DataCell(SizedBox(
                  width: 50, child: Text(oCcy.format(listPenjualan['total'])))),
              DataCell(SizedBox(
                  width: 80, child: Text(oCcy.format(listPenjualan['nilai']))))
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

        refreshOmset(bulan);
        refreshLaba(bulan);
        refreshPenerimaan(bulan);
        refreshPengeluaran(bulan);

        refreshListPenjualan(bulan);

        //  refreshLabaBersih(bulan);
      });
    }
  }

  Container keuangan() {
    final border = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    );
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
                                    oCcy.format(untung),
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
                                        ? oCcy.format(penjualan)
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
                                    oCcy.format(uangTerima),
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
                                    oCcy.format(uangKeluar),
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
                                oCcy.format(labaBersihTot),
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
                                    oCcy.format(labaBersihTot),
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
                                "${oCcy.format(allIncome)} - ${oCcy.format(uangKeluar)}",
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
}
