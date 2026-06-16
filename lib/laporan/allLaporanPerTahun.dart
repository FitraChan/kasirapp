import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:kasirapp/laporan/menuLaporan.dart';

import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:kasirapp/model/currencyFormatter.dart';
import 'package:kasirapp/network_utils/api.dart';
import 'package:kasirapp/screen/home.dart';

import '../screen/menu1.dart';

//import 'package:firebase_messaging/firebase_messaging.dart';

class AllLaporanPerTahun extends StatefulWidget {
  const AllLaporanPerTahun({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _AllLaporanPerTahunState createState() => _AllLaporanPerTahunState();
}

class _AllLaporanPerTahunState extends State<AllLaporanPerTahun> {
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

  var tahun;

  @override
  void initState() {
    super.initState();

    helper = KasirHelper();

    final now = DateTime.now().year;
    years = List.generate(26, (index) => now - 5 + index);

    selectedYear = now; // Tahun awal

    fetchLaporan(tahun, 0);
    fetchListLaporan(tahun, 0);
    fetchListLaporanPemasukan(tahun);
    fetchListLaporanPengeluaran(tahun);
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

      var date = DateTime.parse(DateTime.now().toString());

      var tanggalNow = DateFormat('yyyy-MM-dd').format(date);

      if (tang == null) {
        url = 'penerimaanPengeluaranLaporanTahunan/$tanggalNow';
      } else {
        url = 'penerimaanPengeluaranLaporanTahunan/' + tang;
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
        url = 'penerimaanPengeluaranLaporanTahunan/$tanggalNow';
      } else {
        url = 'penerimaanPengeluaranLaporanTahunan/' + tang;
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

    try {
      // const String _url = 'http://192.168.5.10/bprs_api/public/api/show_cuti';

      // String _url = 'list_laporan_today';

      String url;

      var date = DateTime.parse(DateTime.now().toString());

      var tanggalNow = DateFormat('yyyy-MM-dd').format(date);

      // if (tang == null) {
      //   url = 'list_laporan_tahunan/$tanggalNow';
      // } else {
      //   url = 'list_laporan_tahunan/' + tang;
      // }

      if (tang == null && status != 0) {
        url = 'list_laporan_tahunan/$tanggalNow/$status';
      } else if (tang != null && status != 0) {
        url = 'list_laporan_tahunan/$tanggalNow/$status';
      } else if (tang != null && status == 0) {
        url = '${'list_laporan_tahunan/' + tang}/0';
      } else {
        url = 'list_laporan_tahunan/$tanggalNow/0';
      }
      final response = await Network().getData_get(url);
      if (response.statusCode == 200) {
        setState(() {
          listPenjualan = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load album');
      }
    } catch (e) {
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
    //   url = 'laporan_tahunan/$tanggalNow';
    // } else {
    //   url = 'laporan_tahunan/' + tang;
    // }

    if (tang == null && status != 0) {
      url = 'laporan_tahunan/$tanggalNow/$status';
    } else if (tang != null && status != 0) {
      url = '${'laporan_tahunan/' + tang}/$status';
    } else if (tang != null && status == 0) {
      url = '${'laporan_tahunan/' + tang}/0';
    } else {
      url = 'laporan_tahunan/$tanggalNow/0';
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
                'Laporan Tahunan',
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

  Widget _createDataTable() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowHeight: 45,
            dataRowHeight: 45,

            /// HEADER STYLE
            headingRowColor: MaterialStateProperty.all(
              const Color(0xff0F4C81),
            ),

            /// ROW STYLE
            dataRowColor: MaterialStateProperty.resolveWith((states) {
              return Colors.white;
            }),

            /// BORDER LEBIH HALUS
            border: TableBorder(
              horizontalInside: BorderSide(
                color: Colors.grey.shade300,
              ),
              verticalInside: BorderSide(
                color: Colors.grey.shade200,
              ),
            ),

            columnSpacing: 25,
            horizontalMargin: 20,

            columns: _createColumns(),
            rows: _createRows(),
          ),
        ),
      ),
    );
  }

  List<DataColumn> _createColumns() {
    return [
      const DataColumn(
          label: Text('Bulan',
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
    double screenWidth = MediaQuery.of(context).size.width;
    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    double totalOmset = 0;
    double totalLaba = 0;

    // hitung total
    for (var item in listPenjualan) {
      totalOmset += double.tryParse(item['omset'].toString()) ?? 0;
      totalLaba += double.tryParse(item['laba'].toString()) ?? 0;
    }

    List<DataRow> rows = listPenjualan.map((item) {
      return DataRow(
        cells: [
          DataCell(
            SizedBox(
              width: 80,
              child: Text(item['bulan'].toString()),
            ),
          ),
          DataCell(
            SizedBox(
              width: 110,
              child: Text(
                currencyFormatter.format(
                  double.tryParse(item['omset'].toString()) ?? 0,
                ),
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: screenWidth,
              child: Text(
                currencyFormatter.format(
                  double.tryParse(item['laba'].toString()) ?? 0,
                ),
              ),
            ),
          ),
        ],
      );
    }).toList();

    /// BARIS TOTAL
    rows.add(
      DataRow(
        color: MaterialStateProperty.all(Colors.blue.shade50),
        cells: [
          const DataCell(
            SizedBox(
              width: 80,
              child: Text(
                "TOTAL",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: 110,
              child: Text(
                currencyFormatter.format(totalOmset),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: screenWidth,
              child: Text(
                currencyFormatter.format(totalLaba),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );

    return rows;
  }

  var tanggals;

  late int selectedYear;
  late List<int> years;

  Container keuangan() {
    var date = DateTime.now();
    var tanggalNow = DateFormat('yMMMM').format(date);

    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ===== FILTER CARD =====
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  /// ROW TAHUN
                  Row(
                    children: [
                      /// DROPDOWN TAHUN
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: selectedYear,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              isExpanded: true,
                              items: years.map((year) {
                                return DropdownMenuItem(
                                  value: year,
                                  child: Text(
                                    year.toString(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  selectedYear = val!;

                                  final dates = DateTime(selectedYear, 1, 1);

                                  tanggals = DateFormat('yMMMM').format(dates);
                                  tahun =
                                      DateFormat('yyyy-MM-dd').format(dates);

                                  fetchLaporan(tahun, 0);
                                  fetchListLaporan(tahun, 0);
                                  fetchListLaporanPemasukan(tahun);
                                  fetchListLaporanPengeluaran(tahun);
                                });
                              },
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 15),

                      /// TANGGAL SEKARANG
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month,
                                size: 18, color: Colors.blue),
                            const SizedBox(width: 6),
                            Text(
                              tanggals ?? tanggalNow,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// STATUS BAYAR
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<DropdownItem>(
                        hint: const Row(
                          children: [
                            Icon(Icons.payment),
                            SizedBox(width: 8),
                            Text("Status Bayar"),
                          ],
                        ),
                        value: selectedItem,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down),
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
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          /// ===== SUMMARY GRID =====
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.4,
            children: [
              summaryCard(
                  "LABA", untung.toString(), Colors.green, Icons.trending_up),
              summaryCard("OMSET", penjualan.toString(), Colors.blue,
                  Icons.shopping_cart),
              summaryCard("PEMASUKAN", uangTerima.toString(), Colors.teal,
                  Icons.arrow_downward),
              summaryCard("PENGELUARAN", uangKeluar.toString(), Colors.red,
                  Icons.arrow_upward),
              summaryCard("LABA BERSIH", labaBersihTot.toString(),
                  Colors.deepPurple, Icons.account_balance_wallet),
            ],
          ),

          const SizedBox(height: 20),

          /// HEADER SECTION
          sectionHeader("TRANSAKSI PENJUALAN"),
        ],
      ),
    );
  }

  Widget sectionHeader(String title) {
    return Container(
      // margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 2, 57, 102),
        //   borderRadius: BorderRadius.circular(12),
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

  Widget summaryCard(String title, String value, Color color, IconData icon) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            /// ICON
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color),
            ),

            const SizedBox(width: 10),

            /// TEXT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
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

  double getTotalPemasukan() {
    double total = 0;

    for (var item in listPemasukan) {
      total += double.tryParse(item['nilai'].toString()) ?? 0;
    }

    return total;
  }

  var current;
  var currentString;

  Widget _createDataTablePemasukan() {
    double lebar = MediaQuery.of(context).size.width;

    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    double total = getTotalPemasukan();

    List<DataRow> rows = listPemasukan.asMap().entries.map((entry) {
      int index = entry.key;
      var fruit = entry.value;

      final tanggal = fruit['created_at'] ?? DateTime.now().toString();
      current = DateTime.parse(tanggal);
      currentString = DateFormat('dd-MM-yyyy').format(current);

      return DataRow(
        color: MaterialStateProperty.resolveWith<Color?>((states) {
          return index % 2 == 0 ? Colors.grey.shade50 : Colors.white;
        }),
        cells: [
          DataCell(
            SizedBox(
              width: 30,
              child: Text(
                '${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: 150,
              child: Text(
                currentString,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: lebar,
              child: Text(
                currencyFormatter.format(
                  double.tryParse(fruit['nilai'].toString()) ?? 0,
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      );
    }).toList();

    /// 🔵 ROW TOTAL
    rows.add(
      DataRow(
        color: MaterialStateProperty.all(
          Colors.green.shade100,
        ),
        cells: [
          const DataCell(Text('')),
          const DataCell(
            Text(
              "TOTAL",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          DataCell(
            Text(
              currencyFormatter.format(total),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowHeight: 45,
            dataRowHeight: 45,
            headingRowColor: MaterialStateProperty.all(
              const Color(0xff0F4C81),
            ),
            border: TableBorder(
              horizontalInside: BorderSide(
                color: Colors.grey.shade300,
              ),
              verticalInside: BorderSide(
                color: Colors.grey.shade200,
              ),
            ),
            columnSpacing: 25,
            horizontalMargin: 20,
            columns: _createColumnsPemasukan(),
            rows: rows,
          ),
        ),
      ),
    );
  }

  Widget _createDataTablePengeluaran() {
    double lebar = MediaQuery.of(context).size.width;

    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    double total = listPengeluaran.fold(0.0, (sum, item) {
      return sum + (double.tryParse(item['nilai'].toString()) ?? 0);
    });

    List<DataRow> rows = listPengeluaran.asMap().entries.map((entry) {
      int index = entry.key;
      var fruit = entry.value;

      final tanggal = fruit['created_at'] ?? DateTime.now().toString();
      DateTime current = DateTime.parse(tanggal);
      String currentString = DateFormat('dd-MM-yyyy').format(current);

      return DataRow(
        color: MaterialStateProperty.resolveWith<Color?>((states) {
          return index % 2 == 0 ? Colors.grey.shade50 : Colors.white;
        }),
        cells: [
          DataCell(
            SizedBox(
              width: 30,
              child: Text(
                '${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: 150,
              child: Text(
                currentString,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
          DataCell(
            SizedBox(
              width: lebar,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  currencyFormatter
                      .format(double.tryParse(fruit['nilai']) ?? 0),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }).toList();

    /// ROW TOTAL
    rows.add(
      DataRow(
        color: MaterialStateProperty.all(
          Colors.red.shade100,
        ),
        cells: [
          const DataCell(Text('')),
          const DataCell(
            Text(
              "TOTAL",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          DataCell(
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                currencyFormatter.format(total),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowHeight: 45,
            dataRowHeight: 45,
            headingRowColor: MaterialStateProperty.all(
              Colors.red.shade700,
            ),
            border: TableBorder(
              horizontalInside: BorderSide(
                color: Colors.grey.shade300,
              ),
              verticalInside: BorderSide(
                color: Colors.grey.shade200,
              ),
            ),
            columnSpacing: 25,
            horizontalMargin: 20,
            columns: _createColumnsPemasukan(),
            rows: rows,
          ),
        ),
      ),
    );
  }
}

class DropdownItem {
  final String id;
  final String statusBayar;

  DropdownItem(this.id, this.statusBayar);
}
