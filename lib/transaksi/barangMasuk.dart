import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:kasirapp/model/currencyFormatter.dart';

import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:kasirapp/model/barangMasukModel.dart';
import 'package:kasirapp/network_utils/api.dart';
import 'package:kasirapp/screen/home.dart';
import 'package:kasirapp/sync/syncServicePkAc.dart';
import 'package:kasirapp/sync/syncServiceSupplier.dart';
import 'package:kasirapp/sync/syncServiceBarangMasuk.dart';
import 'package:kasirapp/transaksi/hutangKeSupplier.dart';

import 'package:kasirapp/transaksi/tambahBarangMasuk.dart';
import 'package:kasirapp/transaksi/editBarangMasuk.dart';

import '../screen/menu1.dart';

//import 'package:firebase_messaging/firebase_messaging.dart';

class BarangMasuk extends StatefulWidget {
  const BarangMasuk({Key? key, required this.title, required this.tambah})
      : super(key: key);
  final String title;
  final int tambah;

  @override
  _BarangMasukState createState() => _BarangMasukState();
}

class _BarangMasukState extends State<BarangMasuk> {
  //  FirebaseMessaging messaging;

  TextEditingController teSeach = TextEditingController();

  bool _isLoading = true;
  KasirHelper? helper;
  var items = [];
  var allCourses = [];

  @override
  void initState() {
    super.initState();

    helper = KasirHelper();

    // restoreToMysql();
    // _refreshBarangMasuk();
    _loadData();
    _initData();
  }

  final syncServiceSupplier = SyncServiceSupplier();
  final syncServicePkAc = SyncServicePkAc();

  final syncServiceBarangMasuk = SyncServiceBarangMasuk();

  bool sudahSync = false;
  bool sudahSyncBarangMasuk = false;

  Future<void> _initData() async {
    await syncServicePkAc.syncPkAc();

    sudahSyncBarangMasuk = true;

    int jumlahBarangMasuk = await helper!.countBarangMasuk();

    if (jumlahBarangMasuk == 0) {
      await syncServiceBarangMasuk.syncAll();
      await _loadData(isRefresh: true); // 🔥 pakai refresh
    } else {
      if (widget.tambah == 0) {
        // dari tambah barang masuk,

        await syncServiceBarangMasuk.syncBarangMasuk();
        await _loadData(isRefresh: true); // 🔥 pakai refresh
      }
    }

    sudahSync = true;

    int jumlah = await helper!.countSupplier();

    if (jumlah == 0) {
      await syncServiceSupplier.syncAll();
      await _loadData(isRefresh: true); // 🔥 pakai refresh
    } else {
      await syncServiceSupplier.syncSupplier();

      await _loadData(isRefresh: true); // 🔥 pakai refresh
    }
  }

  void _refreshBarangMasuk() {
    if (helper != null) {
      helper!.allBarangMasuk().then((courses) {
        setState(() {
          allCourses = courses;
          items = allCourses;
          _isLoading = false;
        });
      });
    }
  }

  KasirHelper helpers = KasirHelper();
  var newData;
  final int itemsPerPage = 10;
  int currentPage = 0;
  var _data = [];
  int jumlah = 0;
  int jumlahBarangMasuk = 0;

  bool click = true;

  Future<void> _loadData({bool isRefresh = false}) async {
    if (isRefresh) {
      _data.clear(); // 🔥 reset data
      currentPage = 0; // 🔥 reset halaman
    }

    newData = await helpers.allBarangMasukPage(
        itemsPerPage, currentPage * itemsPerPage);

    setState(() {
      _data.addAll(newData);
      _isLoading = false;
    });

    if (jumlah == _data.length) {
      setState(() {
        click = false;
      });
    }
  }

  void _loadMoreData() {
    setState(() {
      currentPage++;
      _loadData();
    });
  }

  Center tombolLoad() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10), // lebih kecil
        child: GestureDetector(
          onTap: _loadMoreData,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 18, vertical: 8), // kecil
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Colors.deepOrange,
                  Colors.deepOrange,
                ],
              ),
              borderRadius: BorderRadius.circular(20), // lebih kecil
              boxShadow: [
                BoxShadow(
                  color: Colors.deepOrange.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.expand_more, color: Colors.white, size: 18), // kecil
                SizedBox(width: 6),
                Text(
                  "More",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13, // kecil
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  var isSync;
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nilaiController = TextEditingController();
  // final TextEditingController _createdAtController = TextEditingController();
  final currencyFormatter = CurrencyFormatter();
  Widget _buildTable() {
    return Padding(
      padding: const EdgeInsets.all(11),
      child: Card(
        elevation: 8,
        shadowColor: Colors.grey.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 30,
              headingRowHeight: 55,
              dataRowHeight: 60,
              headingRowColor: MaterialStateProperty.all(
                Colors.grey.shade100,
              ),
              columns: const [
                DataColumn(
                  numeric: true,
                  label: Text(
                    'No',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'No Transaksi',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Nama Produk',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                DataColumn(
                  numeric: true,
                  label: Text(
                    'Qty',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  numeric: true,
                  label: Text(
                    'Harga Beli',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  numeric: true,
                  label: Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Metode',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Supplier',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Aksi',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: _data.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                //print('item ${item}');
                final barang = BarangMasukModel.fromMap(item);

                final hargaBeli = barang.hargaBeli ?? 0;
                final qty = barang.qty ?? 0;
                final total = hargaBeli * qty;

                isSync = item['is_sync'] ?? 0;

                return DataRow(
                  color: MaterialStateProperty.resolveWith<Color?>(
                    (states) {
                      if (states.contains(MaterialState.hovered)) {
                        return Colors.grey.shade50;
                      }
                      return null;
                    },
                  ),
                  onLongPress: () {
                    showAlertDialog(context, item['id']);
                  },
                  cells: [
                    DataCell(
                      Text(
                        (index + 1).toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataCell(
                      Text(
                        barang.noTransaksi ?? '-',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        barang.namaProduk ?? '-',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DataCell(Text(qty.toString())),
                    DataCell(
                      Text(
                        "Rp ${currencyFormatter.format(hargaBeli.toString())}",
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                    DataCell(
                      Text(
                        "Rp ${currencyFormatter.format(total.toString())}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          barang.metodePembayaran.toString() ?? '-',
                          style: TextStyle(
                            color: Colors.red.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        barang.namaSupplier ?? '-',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (_) => EditBarangMasuk(
                              //       barangMasuk: item,
                              //     ),
                              //   ),
                              // );
                            },
                            tooltip: 'Edit',
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              showAlertDialog(context, item['no_transaksi']);
                            },
                            tooltip: 'Hapus',
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  // Future<void> simpanKeMysql(Map item) async {
  //   try {
  //     setState(() {
  //       _isLoading = true;
  //     });

  //     String url = 'createBarangMasuk';
  //     var id = item['id'].toString();

  //     Map<String, String> body = {
  //       'id': item['id']?.toString() ?? '',
  //       'no_transaksi': item['no_transaksi']?.toString() ?? '',
  //       'tanggal': item['tanggal']?.toString() ?? '',
  //       'kode_produk': item['kode_produk']?.toString() ?? '',
  //       'kode_supplier': item['kode_supplier']?.toString() ?? '',
  //       'qty': item['qty']?.toString() ?? '0',
  //       'harga_beli': item['harga_beli']?.toString() ?? '0',
  //       'total': item['total']?.toString() ?? '0',
  //       'keterangan': item['keterangan']?.toString() ?? '',
  //       'metode_pembayaran': item['metode_pembayaran']?.toString() ?? '',
  //     };

  //     final response = await Network().getData_post(body, url);

  //     if (response.statusCode == 200) {
  //       /// update sqlite
  //       await helper!.sync(id, 'id', 'barang_masuk');

  //       /// update tampilan
  //       setState(() {
  //         // item['is_sync'] = 1;

  //         isSync = 1;
  //         _isLoading = false;
  //       });

  //       print('✅ Sync ke MySQL sukses');

  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Data berhasil disimpan ke server")),
  //       );
  //     } else {
  //       setState(() {
  //         _isLoading = false;
  //       });

  //       print('❌ Error: ${response.body}');
  //       throw Exception('Gagal sync ke server');
  //     }
  //   } catch (e) {
  //     setState(() {
  //       _isLoading = false;
  //     });

  //     print('❌ Exception: $e');

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Gagal menyimpan ke server")),
  //     );
  //   }
  // }

  var current;
  var currentString;

  void sendToMysqlDelete(noTransaksi) async {
    Map data = {
      'no_transaksi': noTransaksi.toString(),
    };

    String url;

    url = 'delete_barang_masuk';

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

  // Update an existing journal

  // Delete an item
  void _deleteItem(String noTransaksi) async {
    await helper!.deleteBarangMasuk(noTransaksi);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a Data!'),
    ));

    setState(() {
      currentPage = 0;
      _data = [];
      allCourses = [];
      items = [];
    });

    _refreshBarangMasuk();
    _loadData();
    Navigator.of(context).pop(false);
    sendToMysqlDelete(noTransaksi);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const Home(
                      title: "",
                    )),
          );
          return Future.value(true);
        },
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Barang Masuk'),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.home, color: Colors.black),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Home(title: ''),
                    ),
                  );
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.restore),
                  onPressed: () {
                    restoreToMysql();

                    //_refreshBarangMasuk();
                  },
                ),
              ],
            ),
            drawer: const Menu(),
            backgroundColor: Colors.grey[300],
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 🔴 Tombol kiri (Hutang)
                Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: FloatingActionButton(
                    heroTag: "hutang",
                    backgroundColor: Colors.blue,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HutangSupplierPage(),
                        ),
                      );
                    },
                    child: const Icon(Icons.account_balance_wallet),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 30),
                  child:
                      // 🟠 Tombol kanan (Tambah barang masuk)
                      FloatingActionButton(
                    heroTag: "tambah",
                    backgroundColor: Colors.deepOrange,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const TambahBarangMasuk(scannedBarcode: null),
                        ),
                      );
                    },
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                )
              ],
            ),
            body: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  // students(),
                  cari(),
                  _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : _buildTable(),
                  click ? tombolLoad() : const Center(),
                ]))));
  }

  restoreToMysql() async {
    await syncServiceBarangMasuk.syncAll();
    _refreshBarangMasuk();
  }

  Padding cari() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: TextField(
        onChanged: (value) {
          setState(() {
            filterSeach(value);
          });
        },
        controller: teSeach,
        decoration: const InputDecoration(
            hintText: 'Search...',
            labelText: 'Search',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(25)),
            )),
      ),
    );
  }

  void filterSeach(String query) async {
    var dummySearchList = allCourses;
    if (query.isNotEmpty) {
      var dummyListData = [];
      for (var item in dummySearchList) {
        var course = BarangMasukModel.fromMap(item);
        if (course.namaProduk!.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      }
      setState(() {
        _data = [];
        _data.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        _data = [];
        _data = allCourses;
      });
    }
  }

  showAlertDialog(BuildContext context, String noTransaksi) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Yes"),
      onPressed: () {
        _deleteItem(noTransaksi);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("AlertDialog"),
      content: const Text("Apa Yakin Anda Akan Menghapus?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  void dispose() {
    // Membersihkan sumber daya saat widget dihapus
    // myController.dispose();

    teSeach.dispose();
    super.dispose();
  }
}
