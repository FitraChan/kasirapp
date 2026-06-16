// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kasirapp/network_utils/api.dart';
import 'package:kasirapp/screen/home.dart';
import 'package:kasirapp/screen/login.dart';
import 'package:kasirapp/screen/menu2.dart';
import 'package:kasirapp/transaksi/detailPenjualan.dart';
import 'package:kasirapp/transaksi/transPengembalian.dart';

import 'package:kasirapp/transaksi/transPenjualan.dart';

import 'package:kasirapp/helpers/dbkasir.dart';

import '../screen/menu1.dart';

//import 'package:dio/dio.dart';

class Penjualan extends StatefulWidget {
  Penjualan({Key? key, required this.tanggal}) : super(key: key);
  String tanggal;

  @override
  _PenjualanState createState() => _PenjualanState();
}

class _PenjualanState extends State<Penjualan> {
  //  FirebaseMessaging messaging;
  final TextEditingController _filter = TextEditingController();

  String? email;
  //String? nim;
  String? notificationText;
  String? kewajiban;
  String? bayar;
  String? tunggakan;
  String? _dropdownError;
  String? _mySelection;
  KasirHelper? helper;

  List names = [];
  List filteredNames = [];

  bool _isLoading = false;
  String? kode;

  bool loadData = true;
  List data = [];
  DateTime? _selectedDate;
  var allTrans = [];
  var allDetailTrans = [];
  var allDetailTrans2 = [];
  var Trans = [];
  var selectDetailPembelian = [];
  List detailTrans = [];
  List detailTrans2 = [];
  var p;
  List<List> all = [];
  int? idTrx = 0;
  int? idSubTrx = 0;
  final oCcy = NumberFormat.decimalPattern();
  var tang;
  @override
  void initState() {
    // _loadUserData();
    helper = KasirHelper();

    if (helper != null) {
      try {
        helper!.listTransaksiPemesananDidepan(tang).then((courses) {
          //  setState(() {

          _isLoading = true;
          allTrans = courses;
          Trans = allTrans;

          //print(Trans);

          // var id = Trans.first['id'];
          for (var x = 0; x < Trans.length; x++) {
            idTrx = 0;
            idTrx = Trans[x]['id'];
            // for (var a = 0; a < Trans.length; a++) {
            helper!.listDetailTransaksi(idTrx).then((cou) {
              selectDetailPembelian = cou;

              for (var a = 0; a < 1; a++) {
                allDetailTrans = cou;
                detailTrans = allDetailTrans;
                all.add(detailTrans);

                //idSubTrx = detailTrans[a]['id_sub_transaksi'];

                // detailToping(idSubTrx);
              }

              for (var x = 0; x < selectDetailPembelian.length; x++) {
                allDetailTrans2 = cou;
                detailTrans2 = allDetailTrans2;

                idSubTrx = detailTrans2[x]['id_sub_transaksi'];

                detailToping(idSubTrx);
              }

              // print(all);
            });

            p = all.length;
            _isLoading = false;
          }
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
    }

    // sync();

    super.initState();
  }

  List selectSubDetailPembelian = [];

  List subDetailTrans = [];
  List allDetailTransaksi = [];
  List subAll = [];

  List subAllData = [];
  //List subDetailTrans = [];

  detailToping(id) async {
    try {
      subAllData = [];
      helper!.listSubDetailTransaksiDidepan(id).then((cou) {
        selectSubDetailPembelian = cou;

        // subDetailTrans = [];
        // print(id);
        for (var a = 0; a < 1; a++) {
          allDetailTransaksi = cou;
          subDetailTrans = allDetailTransaksi;
          subAllData.add(subDetailTrans);
        }
        // print(subAll);

        setState(() {
          subAll = subAllData;
        });

        //  print(subAllData);
      });

      // p = all.length;
      _isLoading = false;
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    // Cleanup code here
    super.dispose();
  }

  String? level;
  // _loadUserData() async {
  //   SharedPreferences localStorage = await SharedPreferences.getInstance();
  //   //print(localStorage.getString('user'));

  //   var a = localStorage.getString('user');

  //   //print(user);

  //   if (a != null) {
  //     var user = jsonDecode(localStorage.getString('user') ?? '');

  //     setState(() {
  //       level = user['level'].toString();
  //     });
  //   } else {
  //     // Login();

  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => const Login()),
  //     );
  //   }
  // }

  void refreshlistTransaksi(tgl) async {
    widget.tanggal = tgl;
    helper!.listTransaksi(tgl).then((courses) {
      setState(() {
        allTrans = courses;
        Trans = allTrans;

        //_isLoading = false;
      });
    });
  }

  var listPenjualan = [];
  // sync() async {
  //   String url;

  //   url = 'produkSync';

  //   final response = await Network().getData_get(url);

  //   final dbClient = KasirHelper.db;

  //   if (response.statusCode == 200) {
  //     setState(() {
  //       listPenjualan = json.decode(response.body);
  //     });
  //     for (var item in listPenjualan) {
  //       var kode = item['kode'];
  //       var hargaJual = item['harga_jual'];
  //       var nama = item['nama_barang'];
  //       var idKategori = item['id_kategori'];
  //       var createdAtMysql = item['created_at'];
  //       var hargaBeli = item['harga_beli'];
  //       var stok = item['stok'];
  //       //var satuan = item['satuan'];

  //       // var gambar = item['gambar'];
  //       //String imgString;

  //       // var date = DateTime.parse(createdAtMysql.toString());

  //       var dateValue = DateFormat("yyyy-MM-ddTHH:mm:ssZ")
  //           .parseUTC(createdAtMysql)
  //           .subtract(const Duration(hours: 1))
  //           .toLocal();

  //       var tanggalMysql = DateFormat('yyyy-MM-dd HH:mm').format(dateValue);

  //       final maps = await dbClient!
  //           .rawQuery("select * from tb_produk where kode = ?", [kode]);

  //       //  var kd = maps.first['kode'];

  //       if (maps.isNotEmpty) {
  //         var createdAt = maps.first['tanggal_sekarang'];
  //         if (tanggalMysql != createdAt) {
  //           dbClient.rawQuery('''
  //             UPDATE tb_produk
  //             SET nama_barang = '$nama', harga_jual = '$hargaJual' , tanggal_sekarang = '$tanggalMysql', id_kategori = '$idKategori', harga_beli = '$hargaBeli', stok = '$stok'
  //             WHERE kode = '$kode'
  //             ''');
  //         }
  //       } else {
  //         //final http.Response response = await http.get(Uri.parse(gambar));

  //         //imgString = Utility.base64String(response.bodyBytes);
  //         dbClient.rawQuery('''
  //                 INSERT INTO tb_produk (kode, harga_jual,nama_barang,id_kategori,tanggal_sekarang,harga_beli,stok)
  //                                VALUES ('$kode','$hargaJual' ,'$nama','$idKategori','$tanggalMysql','$hargaBeli','$stok')
  //             ''');
  //       }
  //     }
  //   } else {
  //     print(response.body);
  //     throw Exception('Failed to load album');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Home(
                      title: "",
                    )),
          );
          return Future.value(true);
        },
        child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              title: const Text(
                "Penjualan",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: IconButton(
                icon: Icon(Icons.home, color: Colors.black),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Home(
                              title: '',
                            )),
                  );
                },
              ),
              //Menambahkan Beberapa Action Button
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.add, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TransPenjualan(
                                tanggal: tanggal != null
                                    ? tanggalString
                                    : currentString,
                                delivery: "1",
                                idPembayaran: 0,
                              )),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.search, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
            drawer: level == '1' ? const Menu() : const Menu2(),
            backgroundColor: Colors.grey[300],
            body: SingleChildScrollView(
              child: Stack(
                children: [
                  Column(
                    //  mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      header(),
                      _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : content(),
                    ],
                  )
                ],
              ),
            )));
  }

  Container add() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                margin: EdgeInsets.only(left: 8, top: 150),
                child: Text("Tap"),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TransPenjualan(
                              tanggal: tanggal != null
                                  ? tanggalString
                                  : currentString,
                              delivery: "1",
                              idPembayaran: 0,
                            )),
                  );
                },
                child: Container(
                  margin: EdgeInsets.only(top: 150, left: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                  ),
                  height: 35,
                  width: 35,
                  child: Icon(Icons.add, color: Colors.white),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 8, top: 150),
                child: Text("Buat Penjualan"),
              )
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Container(
                margin: EdgeInsets.only(left: 8),
                child: Text("Tap"),
              ),
              GestureDetector(
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) => TransPengembalian(
                  //           tanggal: tanggal != null
                  //               ? tanggalString
                  //               : currentString)),
                  // );
                },
                child: Container(
                  margin: EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                  ),
                  height: 35,
                  width: 35,
                  child: Icon(Icons.undo, color: Colors.white),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 8),
                child: Text("Buat Pengembalian"),
              )
            ],
          )
        ],
      ),
    );
  }

  Container listPembelian() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: ListView.builder(
        itemCount: Trans.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final transaksi = Trans[index];

          final total = int.tryParse(transaksi['total'].toString()) ?? 0;

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DetailPenjualan(idTrans: transaksi['id']),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                    color: Colors.black.withOpacity(0.06),
                  )
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    /// HEADER
                    Row(
                      children: [
                        Container(
                          height: 52,
                          width: 52,
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.shopping_bag_outlined,
                            color: Colors.blue,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                transaksi['keterangan'] ?? "Transaksi",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "ID : ${transaksi['id']}",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: transaksi['status'] == 3
                                ? Colors.orange.withOpacity(0.15)
                                : Colors.green.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            transaksi['status'] == 3 ? "Pending" : "Lunas",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: transaksi['status'] == 3
                                  ? Colors.orange
                                  : Colors.green,
                              fontSize: 12,
                            ),
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 16),

                    /// LIST BARANG
                    all.isEmpty
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : ListView.builder(
                            itemCount: all[index].length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index2) {
                              final barang = all[index][index2];

                              final namaBarang = barang['nama_barang'] ?? "";

                              final qty = barang['qty'] ?? 0;

                              final harga = int.tryParse(
                                    barang['harga'].toString(),
                                  ) ??
                                  0;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        namaBarang,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "$qty x ${oCcy.format(harga)}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                    const SizedBox(height: 16),

                    /// TOTAL
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue,
                            Colors.blueAccent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Total Pembayaran",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                "Rp ${oCcy.format(total)}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: 16,
                              )
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Container content() {
    Container isi;
    if (Trans.isNotEmpty) {
      isi = listPembelian();
    } else {
      isi = add();
    }
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(left: 9, top: 12),
            child: Text("Daftar Penjualan / Pengembalian",
                style: TextStyle(
                    color: Colors.black,
                    //fontWeight: FontWeight.bold,
                    fontSize: 20)),
          ),
          Container(
            child: Divider(
              color: Colors.black26,
              indent: 11,
              endIndent: 11,
            ),
          ),
          isi,
        ],
      ),
      //)
    );
  }

  void _presentDatePicker() {
    showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime.now())
        .then((pickedDate) {
      // Check if no date is selected
      if (pickedDate == null) {
        return;
      }
      setState(() {
        // using state so that the UI will be rerendered when date is picked
        _selectedDate = pickedDate;

        var dates = DateTime.parse(_selectedDate.toString());

        var tanggals = DateFormat('yyyy-MM-dd').format(dates);

        refreshlistTransaksi(tanggals);
      });
    });
  }

  var tanggal;
  var tanggalString;
  var currentDate;
  var current;
  var currentString;
  Container header() {
    setState(() {
      current = DateTime.parse(DateTime.now().toString());

      currentString = DateFormat('yyyy-MM-dd HH:mm:ss').format(current);

      currentDate = DateFormat('dd-MM-yyyy').format(current);
      if (_selectedDate != null) {
        var date = DateTime.parse(_selectedDate.toString());
        tanggal = DateFormat('dd-MM-yyyy').format(date);
        tanggalString = DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
      }
    });
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        //Color.fromARGB(1, 41, 87, 129),
      ),
      height: 90,
      width: double.infinity,
      child: Material(
        elevation: 4.0,
        borderRadius: BorderRadius.circular(5.0),
        color: Color.fromARGB(255, 42, 87, 129),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 9),
                  child: ElevatedButton(
                      onPressed: _presentDatePicker,
                      child: const Text('Pilih Tanggal')),
                ),
                Container(
                  padding: const EdgeInsets.all(5),
                  child: Text(
                    _selectedDate != null ? tanggal : currentDate,
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
