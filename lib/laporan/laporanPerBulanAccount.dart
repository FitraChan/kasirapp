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

class LaporanPerBulanAccount extends StatefulWidget {
  const LaporanPerBulanAccount({Key? key, required this.title})
      : super(key: key);
  final String title;

  @override
  _LaporanPerBulanAccountState createState() => _LaporanPerBulanAccountState();
}

class _LaporanPerBulanAccountState extends State<LaporanPerBulanAccount> {
  //  FirebaseMessaging messaging;

  bool _isLoading = true;

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

    fetchLaporan(tang);
  }

  var total;
  var debet;
  var kredit;

  void fetchLaporan(tang) async {
    String url;

    // setState(() {
    //   _isLoading = true;
    // });

    var date = DateTime.parse(DateTime.now().toString());

    var tanggalNow = DateFormat('yyyy-MM-dd').format(date);

    if (tang != null) {
      url = 'transaksiJurnalPerBulan/$tang';
    } else {
      url = 'transaksiJurnalPerBulan/$tanggalNow';
    }

    final response = await Network().getData_get(url);

    if (response.statusCode == 200) {
      setState(() {
        listPenjualan = json.decode(response.body);
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
            var tgl = DateTime.parse(fruit['tanggal'].toString());
            var tanggal = DateFormat('dd-MM-yyyy').format(tgl);
            final dataRow = DataRow(
              cells: [
                DataCell(
                  SizedBox(width: 18, child: Text('${index + 1}')),
                ),
                DataCell(SizedBox(width: 70, child: Text(tanggal))),
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
          label: Text('Tanggal',
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

                            fetchLaporan(tanggals);
                          });
                          return null;
                        });
                      },
                    ),
                  )
                ]),
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
            "DAFTAR AKUNTANSI PER BULAN",
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    tanggalSkr.dispose();

    //priceAfterDiscount.dispose();
    super.dispose();
  }
}
