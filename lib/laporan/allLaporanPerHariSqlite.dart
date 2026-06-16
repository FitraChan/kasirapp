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

class AllLaporanPerHariSqlite extends StatefulWidget {
  const AllLaporanPerHariSqlite({Key? key, required this.title})
      : super(key: key);
  final String title;

  @override
  _AllLaporanPerHariSqliteState createState() =>
      _AllLaporanPerHariSqliteState();
}

class _AllLaporanPerHariSqliteState extends State<AllLaporanPerHariSqlite> {
  //  FirebaseMessaging messaging;

  bool _isLoading = true;
  KasirHelper? helper;
  Map<String, String>? items;
  List? keuntungan;
  String? untung;
  String? penjualan;

  List listPenjualan = [];

  var listProduk = [];

  var listPemasukan = [];

  var listPengeluaran = [];
  var daftarSaldo = [];

  String? laba;
  var labaBersih = [];
  int? labaBersihTot;
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

    // helper!.listPenjualanHariIni(tang).then((courses) {
    //   setState(() {
    //     listPenjualan = courses;
    //   });
    // });

    helper!.listKeuntunganHariIni(tang).then((courses) {
      setState(() {
        keuntungan = courses;

        // print(keuntungan);
        if (keuntungan!.isNotEmpty) {
          untung = keuntungan?.first['total'].toString();

          print(untung);
        } else {
          untung = '0';
        }
      });
    });

    helper!.totPenerimaan(tang).then((courses) {
      setState(() {
        penerimaan = courses;

        uangTerima = (penerimaan != null && penerimaan.isNotEmpty)
            ? (penerimaan.first['tot']?.toString() ?? '0')
            : '0';
      });
    });

    helper!.totPengeluaran(tang).then((courses) {
      setState(() {
        pengeluaran = courses;

        // if (pengeluaran.isNotEmpty) {
        //   uangKeluar = pengeluaran.first['tot'].toString() ?? '0';
        // } else {
        //   uangKeluar = '0';
        // }

        uangKeluar = (pengeluaran != null && pengeluaran.isNotEmpty)
            ? (pengeluaran.first['tot']?.toString() ?? '0')
            : '0';

        //uangKeluar = 0;

        //labaBersihTot = untung - uangKeluar;
      });
      var profit = int.parse(untung!);
      var acceptMoney = int.parse(uangTerima!);
      var outMoney = int.parse(uangKeluar!);

      labaBersihTot = (profit + acceptMoney) - outMoney;

      // allIncome = untung! + uangTerima!;
      if (untung != null) {
        allIncome = untung! + uangTerima!;
      }
    });
  }

  bool _isFirstLoadRunning = false;

  void fetchListLaporanPengeluaran(tang) async {
    setState(() {
      _isFirstLoadRunning = true;
    });

    try {
      String url;

      var hasilPP;

      var date = DateTime.parse(DateTime.now().toString());

      var tanggalNow = DateFormat('yyyy-MM-dd').format(date);

      if (tang == null) {
        //url = 'penerimaanPengeluaranLaporan/$tanggalNow';

        hasilPP = await helper!.getPenerimaanPengeluaranLaporan(tanggalNow);
      } else {
        //  url = 'penerimaanPengeluaranLaporan/' + tang;

        hasilPP = await helper!.getPenerimaanPengeluaranLaporan(tang);
      }

      // final response = await Network().getData_get(url);
      // if (response.statusCode == 200) {
      var data = [];
      //  var c = json.decode(response.body);
      data = hasilPP['pengeluaran'];
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

  void fetchListSaldo(tang) async {
    setState(() {
      _isFirstLoadRunning = true;
    });

    try {
      String url;

      var listSaldo;

      var date = DateTime.parse(DateTime.now().toString());

      var tanggalNow = DateFormat('yyyy-MM-dd').format(date);

      if (tang == null) {
        //url = 'penerimaanPengeluaranLaporan/$tanggalNow';

        listSaldo = await helper!.listSaldo(tanggalNow);
      } else {
        //  url = 'penerimaanPengeluaranLaporan/' + tang;

        listSaldo = await helper!.listSaldo(tang);
      }

      // final response = await Network().getData_get(url);
      // if (response.statusCode == 200) {
      var data = [];
      //  var c = json.decode(response.body);
      data = listSaldo;
      setState(() {
        daftarSaldo = data;
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

      var hasilMasuk;

      var date = DateTime.parse(DateTime.now().toString());

      var tanggalNow = DateFormat('yyyy-MM-dd').format(date);

      if (tang == null) {
        hasilMasuk = await helper!.getPenerimaanPengeluaranLaporan(tanggalNow);
      } else {
        hasilMasuk = await helper!.getPenerimaanPengeluaranLaporan(tang);
      }

      var data = [];
      data = hasilMasuk['penerimaan'];
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
    setState(() {
      _isLoading = true;
    });

    try {
      var date = DateTime.parse(DateTime.now().toString());

      var tanggalNow = DateFormat('yyyy-MM-dd').format(date);

      if (tang == null && status != 0) {
        // url = 'list_laporan_today/$tanggalNow/$status';

        //hasilList = await helper!.getLaporanToday(tanggalNow, status);
        helper!.listPenjualanHariIni(tanggalNow, status).then((courses) {
          if (!mounted) return; // aman untuk lifecycle
          print("Courses dapat: $courses");
          setState(() {
            listPenjualan = courses;
            _isLoading = false;
          });
        }).catchError((e) {
          print("Gagal ambil data: $e");
        });
      } else if (tang != null && status != 0) {
        // url = 'list_laporan_today/$tanggalNow/$status';
        // hasilList = await helper!.getLaporanToday(tanggalNow, status);

        helper!.listPenjualanHariIni(tang, status).then((courses) {
          setState(() {
            listPenjualan = courses;

            // print(listPenjualan);
            _isLoading = false;
          });
        });
      } else if (tang != null && status == 0) {
        // url = '${'list_laporan_today/' + tang}/0';

        // hasilList = await helper!.getLaporanToday(tang, 0);

        helper!.listPenjualanHariIni(tang, 0).then((courses) {
          setState(() {
            listPenjualan = courses;
            _isLoading = false;
          });
        });
      } else {
        //url = 'list_laporan_today/$tanggalNow/0';
        //  hasilList = await helper!.getLaporanToday(tanggalNow, 0);

        helper!.listPenjualanHariIni(tanggalNow, 0).then((courses) {
          setState(() {
            listPenjualan = courses;
            _isLoading = false;
          });
        });
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

  void fetchPemasukan(tang) {
    helper!.totPenerimaan(tang).then((courses) {
      setState(() {
        penerimaan = courses;

        if (penerimaan.isNotEmpty) {
          uangTerima = penerimaan.first['tot'].toString() ?? '0';
        } else {
          uangTerima = '0';
        }
      });
    });
  }

  void fetchPengeluaran(tang) {
    helper!.totPengeluaran(tang).then((courses) {
      setState(() {
        pengeluaran = courses;

        if (pengeluaran.isNotEmpty) {
          uangKeluar = pengeluaran.first['tot'].toString() ?? '0';
        } else {
          uangKeluar = '0';
        }

        labaBersihTot = 0;
        allIncome = '0';
      });
    });
  }

  var hasil;
  void fetchLaporan(tang, status) async {
    //  String _url = 'http://192.168.5.10/bprs_api/public/api/profil';
    String url;

    var date = DateTime.parse(DateTime.now().toString());

    var tanggalNow = DateFormat('yyyy-MM-dd').format(date);

    if (tang == null && status != 0) {
      // url = 'laporan_today/$tanggalNow/$status';

      // hasil = await helper!.laporanHariIni(tanggalNow, status);

      hasil = await helper!.totPenjualanHariIni(tanggalNow, status);
      setState(() {
        // allCourses = courses;
        //  items = courses;
        hasil;
        //_isLoading = false;
      });
    } else if (tang != null && status != 0) {
      //url = '${'laporan_today/' + tang}/$status';

      //  hasil = await helper!.laporanHariIni(tang, status);

      hasil = await helper!.totPenjualanHariIni(tang, status);
      setState(() {
        // allCourses = courses;
        //  items = courses;
        hasil;
        //_isLoading = false;
      });
    } else if (tang != null && status == 0) {
      //url = '${'laporan_today/' + tang}/0';

      //  hasil = await helper!.laporanHariIni(tang, 0);

      hasil = await helper!.totPenjualanHariIni(tang, 0);
      setState(() {
        // allCourses = courses;
        //  items = courses;
        hasil;
        //_isLoading = false;
      });
    } else {
      // url = 'laporan_today/$tanggalNow/0';

      //  hasil = await helper!.laporanHariIni(tanggalNow, 0);
      hasil = await helper!.totPenjualanHariIni(tanggalNow, 0);
      setState(() {
        // allCourses = courses;
        //  items = courses;
        hasil;
        //_isLoading = false;
      });
    }
  }

  //   helper!.listPenjualanHariIni(tgl).then((courses) {
  //     setState(() {
  //       listPenjualan = courses;
  //     });
  //   });

  //   helper!.listKeuntunganHariIni(tgl).then((courses) {
  //     //  setState(() {
  //     keuntungan = courses;

  //     if (keuntungan!.isNotEmpty) {
  //       untung = keuntungan?.first['total'] ?? 0;
  //     } else {
  //       untung;
  //     }
  //   });

  //   helper!.totPenerimaan(tgl).then((courses) {
  //     setState(() {
  //       penerimaan = courses;
  //       uangTerima = penerimaan.first['tot'] ?? 0;
  //     });
  //   });

  //   helper!.totPengeluaran(tgl).then((courses) {
  //     setState(() {
  //       pengeluaran = courses;
  //       uangKeluar = pengeluaran.first['tot'] ?? 0;

  //       //labaBersihTot = untung - uangKeluar;
  //     });

  //     labaBersihTot;

  //     allIncome;
  //   });
  // }

  // void refreshListPenjualanHariIni(tgl) async {
  //   helper!.listPenjualanHariIni(tgl).then((courses) {
  //     setState(() {
  //       listPenjualan = courses;
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
                  const SizedBox(
                    height: 4,
                  ),
                  headerPenjualan(),
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
                  const SizedBox(
                    height: 4,
                  ),
                  headerSaldo(),
                  _createDataTableSaldo()
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
            //if (fruit['nama_barang'] == null && fruit['qty'] != null) {
            //cekKodeMysql(fruit['id_barang']);

            //  cekMysql(fruit['id_barang']);
            //  fetchListLaporan(null, 0);
            // }
            var date = DateTime.parse(fruit['created_at'].toString());

            var tanggalNow = DateFormat('HH:mm:ss').format(date);

            final dataRow = DataRow(
              cells: [
                DataCell(
                  SizedBox(width: 25, child: Text('${index + 1}')),
                ),
                DataCell(SizedBox(
                    width: 150,
                    child: Text(fruit['nama_barang'].toString() +
                        ' - ${fruit['kode_transaksi'].toString()}'))),
                DataCell(SizedBox(width: 100, child: Text(tanggalNow))),
                DataCell(
                    SizedBox(width: 50, child: Text(fruit['qty'].toString()))),
                DataCell(SizedBox(
                    width: lebar,
                    child: Text(currencyFormatter
                        .format(fruit['total'].toString() ?? ''))))
              ],
            );
            return MapEntry(index, dataRow);
          })
          .values
          .toList(),
    );
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
          label: Text('Nilai',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ))),
    ];
  }

  List<DataColumn> _createColumnsPengeluaran() {
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

                            //  refreshTotPenjualanHariIni(tanggals);

                            fetchLaporan(tanggals, 0);
                            fetchListLaporan(tanggals, 0);
                            fetchListLaporanPemasukan(tanggals);
                            fetchListLaporanPengeluaran(tanggals);
                            fetchPemasukan(tanggals);
                            fetchPengeluaran(tanggals);
                            // refreshListPenjualanHariIni(tanggals);

                            // refreshKeuntunganHariIni(tanggals);
                            // refreshTotPenerimaan(tanggals);
                            // refreshTotPengeluaran(tanggals);
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
                  fetchLaporan(tanggals, int.parse(selectedItem!.id));
                  fetchListLaporan(tanggals, int.parse(selectedItem!.id));
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
              width: screenWidth,
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
                                    oCcy.format(
                                        int.tryParse(untung ?? '') ?? 0),
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
              width: screenWidth,
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
                                    "${hasil != null ? oCcy.format((hasil)) : 0}",
                                    //oCcy.format(hasil ?? 0) ?? '0',
                                    // penjualan ?? '',
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
              width: screenWidth,
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
                                    oCcy.format(
                                        int.tryParse(uangTerima ?? '') ?? 0),
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
              width: screenWidth,
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
                                    oCcy.format(
                                        int.tryParse(uangKeluar ?? '') ?? 0),
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
                                oCcy.format(
                                    int.tryParse(labaBersihTot.toString()) ??
                                        0),
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
                                allIncome.toString() +
                                    "-" +
                                    uangKeluar.toString(),
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                          ]),
                    ),
                  ]),
            ],
          ),
        )
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
            "DAFTAR PENJUALAN",
            style: TextStyle(color: Colors.white),
          ),
        ],
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
            // current = fruit['created_at'].toString();

            // currentString = DateFormat('dd-MM-yyyy').format(current);
            final dataRow = DataRow(
              cells: [
                DataCell(
                  SizedBox(width: 10, child: Text('${index + 1}')),
                ),
                DataCell(SizedBox(
                    width: 150, child: Text(fruit['keterangan'].toString()))),
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
            final dataRow = DataRow(
              cells: [
                DataCell(
                  SizedBox(width: 10, child: Text('${index + 1}')),
                ),
                DataCell(SizedBox(
                    width: 150, child: Text(fruit['keterangan'].toString()))),
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

  List<DataColumn> _createColumnsSaldo() {
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
          label: Text('Saldo Awal',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ))),
      const DataColumn(
          label: Text('Saldo Akhir',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ))),
      const DataColumn(
          label: Text('Uang Fisik',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ))),
      const DataColumn(
          label: Text('Selisih',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ))),
      const DataColumn(
          label: Text('Tanggal',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ))),
    ];
  }

  DataTable _createDataTableSaldo() {
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
      columns: _createColumnsSaldo(),
      rows: daftarSaldo
          .asMap()
          .map((index, fruit) {
            final dataRow = DataRow(
              cells: [
                DataCell(
                  SizedBox(width: 10, child: Text('${index + 1}')),
                ),

                DataCell(SizedBox(
                    width: 100,
                    child: Text(currencyFormatter
                        .format(fruit['saldo_awal'].toString())))),
                DataCell(SizedBox(
                    width: 100,
                    child: Text(currencyFormatter
                        .format(fruit['saldo_akhir'].toString())))),
                DataCell(SizedBox(
                    width: 100,
                    child: Text(currencyFormatter
                        .format(fruit['uang_fisik'].toString())))),

                DataCell(SizedBox(
                    width: 100,
                    child: Text(currencyFormatter
                        .format(fruit['selisih'].toString())))),
                // DataCell(SizedBox(
                //     width: lebar,
                //     child: Text((fruit['tanggal'] != null
                //         ? DateFormat('dd-MM-yyyy')
                //             .format(DateTime.parse(fruit['tanggal']))
                //         : '')))),
                DataCell(
                    SizedBox(width: lebar, child: Text((fruit['tanggal'])))),
                //DataCell(SizedBox(width: lebar, child: Text((currentString))))
              ],
            );
            return MapEntry(index, dataRow);
          })
          .values
          .toList(),
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
