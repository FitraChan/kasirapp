import 'dart:convert';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kasirapp/laporan/menuLaporan.dart';

import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:kasirapp/model/currencyFormatter.dart';
import 'package:kasirapp/network_utils/api.dart';
import 'package:kasirapp/screen/home.dart';

import '../screen/menu1.dart';

//import 'package:firebase_messaging/firebase_messaging.dart';

class LaporanPerhariAccount extends StatefulWidget {
  const LaporanPerhariAccount({Key? key, required this.title})
      : super(key: key);
  final String title;

  @override
  _LaporanPerhariAccountState createState() => _LaporanPerhariAccountState();
}

class _LaporanPerhariAccountState extends State<LaporanPerhariAccount> {
  //  FirebaseMessaging messaging;

  bool _isLoading = true;

  bool _isLoadingPosting = false;
  KasirHelper? helper;
  var items = [];
  List? keuntungan;
  String? untung;
  var penjualan;

  var listPenjualan = [];

  var listPemasukan = [];

  var listPengeluaran = [];

  String? laba;
  var labaBersih = [];
  String? labaBersihTot;
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
  var currentDate;

  @override
  void initState() {
    super.initState();

    helper = KasirHelper();

    //   current = DateTime.parse(DateTime.now().toString());

    //  currentDate = DateFormat('HH:mm:ss').format(current);

    fetchLaporan(tang, 0);
    totFetchLaporan(tang, 0);
  }

  bool _isFirstLoadRunning = false;
  var total;
  var debet;
  var kredit;

  void fetchLaporan(tang, status) async {
    String url;

    var date = DateTime.parse(DateTime.now().toString());

    var tanggalNow = DateFormat('yyyy-MM-dd').format(date);

    if (tang == null && status != 0) {
      url = 'transaksiJurnal/$tanggalNow/$status';
    } else if (tang != null && status != 0) {
      url = '${'transaksiJurnal/' + tang}/$status';
    } else if (tang != null && status == 0) {
      url = '${'transaksiJurnal/' + tang}/0';
    } else {
      url = 'transaksiJurnal/$tanggalNow/0';
    }

    final response = await Network().getData_get(url);

    if (response.statusCode == 200) {
      setState(() {
        listPenjualan = json.decode(response.body);
        _isFirstLoadRunning = false;
      });
    } else {
      print(response.body);
      throw Exception('Failed to load album');
    }
  }

  void fetchPosting(tanggal) async {
    setState(() {
      _isLoadingPosting = true;
    });
    var url = 'cekSaldo/$tanggal';

    final response = await Network().getData_get(url);

    if (response.statusCode == 200) {
      setState(() {
        _isLoadingPosting = false;
      });
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const LaporanPerhariAccount(title: '')),
      );
    } else {
      print(response.body);
      throw Exception('Failed to load album');
    }
  }

  void totFetchLaporan(tang, status) async {
    String url;

    var date = DateTime.parse(DateTime.now().toString());

    var tanggalNow = DateFormat('yyyy-MM-dd').format(date);

    if (tang == null && status != 0) {
      url = 'totTransaksi/$tanggalNow/$status';
    } else if (tang != null && status != 0) {
      url = '${'totTransaksi/' + tang}/$status';
    } else if (tang != null && status == 0) {
      url = '${'totTransaksi/' + tang}/0';
    } else {
      url = 'totTransaksi/$tanggalNow/0';
    }

    final response = await Network().getData_get(url);

    if (response.statusCode == 200) {
      var c = json.decode(response.body);
      setState(() {
        total = c['tot'].toString();
        debet = c['debet'].toString();
        kredit = c['kredit'].toString();
        _isLoading = false;
      });
    } else {
      print(response.body);
      throw Exception('Failed to load album');
    }
  }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.landscapeLeft,
    //   DeviceOrientation.landscapeRight,
    // ]);
    MediaQueryData mediaQueryData = MediaQuery.of(context);
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
                  const SizedBox(
                    height: 4,
                  ),
                  headerPenjualan(),
                  _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : _createDataTable(),
                  mediaQueryData.orientation == Orientation.portrait
                      ? listJumlah()
                      : listJumlahLandscape()
                ]))));
  }

  final currencyFormatter = CurrencyFormatter();

  DataTable _createDataTable() {
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
      columns: _createColumns(),
      rows: listPenjualan
          .asMap()
          .map((index, fruit) {
            var tgl = DateTime.parse(fruit['tgl_trans'].toString());
            var tanggal = DateFormat('HH:mm:ss').format(tgl);
            final dataRow = DataRow(
              cells: [
                DataCell(
                  SizedBox(width: 18, child: Text('${index + 1}')),
                ),
                DataCell(SizedBox(width: 70, child: Text(tanggal))),
                DataCell(SizedBox(
                    width: 100, child: Text(fruit['keterangan'].toString()))),
                DataCell(SizedBox(
                    width: 100,
                    child: Text(int.parse(fruit['debet']) > 0
                        ? currencyFormatter.format(fruit['debet'].toString())
                        : '-'))),
                DataCell(SizedBox(
                    width: 100,
                    child: Text(int.parse(fruit['kredit']) > 0
                        ? currencyFormatter.format(fruit['kredit'].toString())
                        : '-'))),
                DataCell(SizedBox(
                    width: lebar,
                    child: Text(int.parse(fruit['saldo']) > 0
                        ? currencyFormatter.format(fruit['saldo'].toString())
                        : '-'))),
              ],
            );
            return MapEntry(index, dataRow);
          })
          .values
          .toList(),
    );
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
          label: Text('Jam',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ))),
      const DataColumn(
          label: Text('Keterangan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ))),
      const DataColumn(
          label: Text('Debet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ))),
      const DataColumn(
          label: Text('Kredit',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ))),
      const DataColumn(
          label: Text('Saldo',
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
    var date = DateTime.parse(DateTime.now().toString());

    var tanggalNow = DateFormat('yyyy-MM-dd').format(date);

    final format = DateFormat("yyyy-MM-dd");

    if (_selectedDate != null) {
      tanggalSkr = TextEditingController(text: tanggals);
    } else {
      tanggalSkr = TextEditingController(text: tanggalNow);
    }

    var screenWidth = MediaQuery.of(context).size.width / 2;
    final border = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    );
    return Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 9),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white),
              onPressed: () {
                // _onPressed(context: context);

                fetchPosting(tanggalNow);

                setState(() {
                  _isFirstLoadRunning = true;
                });
              },
              child: _isFirstLoadRunning
                  ? const Text('Please Wait...')
                  : const Text('Posting')),
        ),
        Container(
          margin: const EdgeInsets.only(left: 14.0, right: 14),
          height: 60,
          //width: 150,
          child: Card(
            shape: border,
            color: Colors.white,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    child: DateTimeField(
                      validator: (value) {
                        if (value == null) {
                          return 'Please enter a date';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        //hintText: "Tanggal Akhir",
                        //  labelText: "Tanggal Akhir",
                        // prefixText: _currency,
                        prefixIcon: Icon(
                          Icons.date_range,
                          color: Colors.grey,
                        ),
                      ),
                      format: format,
                      controller: tanggalSkr,
                      onShowPicker: (context, currentValue) {
                        return showDatePicker(
                                context: context,
                                firstDate: DateTime(1900),
                                initialDate: currentValue ?? DateTime.now(),
                                lastDate: DateTime(2100))
                            .then((pickedDate) {
                          if (pickedDate == null) {
                            return;
                          }

                          setState(() {
                            // using state so that the UI will be rerendered when date is picked
                            _selectedDate = pickedDate;

                            var dates =
                                DateTime.parse(_selectedDate.toString());

                            tanggals = DateFormat('yyyy-MM-dd').format(dates);

                            fetchLaporan(tanggals, 0);
                            totFetchLaporan(tanggals, 0);
                          });
                          return null;
                        });
                      },
                    ),
                  )
                ]),
          ),
        ),
        // SizedBox(
        //   height: 10,
        // ),
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
                  totFetchLaporan(tanggals, selectedItem!.id);
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
      ],
    ));
  }

  Container headerPenjualan() {
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
            "DAFTAR AKUNTANSI",
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Container listJumlah() {
    return Container(
        //height: 80,
        child: Table(
            columnWidths: const {
              0: FlexColumnWidth(5.7),
              1: FlexColumnWidth(2.8),
              2: FlexColumnWidth(0.2),
              // 3: FlexColumnWidth(3.2),
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
                          child: Text(debet.toString(),
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)))
                    ]),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          padding: const EdgeInsets.only(left: 3, top: 10),
                          child: Text(kredit.toString(),
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)))
                    ]),
                // Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: [
                //       Container(
                //           padding: const EdgeInsets.only(left: 3, top: 10),
                //           child: Text(total.toString(),
                //               style: const TextStyle(
                //                   fontSize: 14, fontWeight: FontWeight.bold)))
                //     ]),
              ])
            ]));
  }

  Container listJumlahLandscape() {
    return Container(
        //height: 80,
        child: Table(
            columnWidths: const {
              0: FlexColumnWidth(4.1),
              1: FlexColumnWidth(1.9),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(3.2),
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
                          child: Text(debet.toString(),
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)))
                    ]),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          padding: const EdgeInsets.only(left: 3, top: 10),
                          child: Text(kredit.toString(),
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)))
                    ]),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          padding: const EdgeInsets.only(left: 3, top: 10),
                          child: Text(total.toString(),
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)))
                    ]),
              ])
            ]));
  }

  @override
  void dispose() {
    tanggalSkr.dispose();

    //priceAfterDiscount.dispose();
    super.dispose();
  }
}

class DropdownItem {
  final String id;
  final String statusBayar;

  DropdownItem(this.id, this.statusBayar);
}
