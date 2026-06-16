import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:kasirapp/master_data/master.dart';

import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:kasirapp/network_utils/api.dart';
import 'package:kasirapp/screen/home.dart';
import '../screen/menu1.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';

//import 'package:firebase_messaging/firebase_messaging.dart';

class BackUpAll extends StatefulWidget {
  const BackUpAll({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _BackUpAllState createState() => _BackUpAllState();
}

class _BackUpAllState extends State<BackUpAll> {
  //  FirebaseMessaging messaging;

  TextEditingController teSeach = TextEditingController();

  bool _isLoading = true;
  KasirHelper? helper;
  var items = [];
  var allCourses = [];

  var lastDate;

  void _refreshKategori() {
    if (helper != null) {
      helper!.allCategori().then((courses) {
        setState(() {
          allCourses = courses;
          items = allCourses;
          _isLoading = false;
        });
      });
    }
  }

  var current;
  var currentString;
  int idTrx = 0;
  var idPembeli;
  var pembelian = [];

  var pembayaran = [];
  var selectDetailPembelian = [];

  var total;

  @override
  void initState() {
    super.initState();
    getTanggal();

    _refreshKategori();

    helper = KasirHelper();

    current = DateTime.parse(DateTime.now().toString());

    currentString = DateFormat('yyyy-MM-dd HH:mm:ss').format(current);
  }

  void getTanggal() async {
    try {
      String url = 'getTanggalTransaksi';
      // final response = await htpp.post(Uri.parse(url), body: data);
      final response = await Network().getData_post('', url);

      var c = json.decode(response.body);
      if (response.statusCode == 200) {
        //setState(() {
        lastDate = c['created_at'].toString();
        helper!.backUpTrans(lastDate).then((courses) {
          //setState(() {
          pembelian = courses;
          pembelian.length;

          for (var x = 0; x < pembelian.length; x++) {
            idTrx = 0;
            idTrx = pembelian[x]['id'];
            total = pembelian[x]['total'];
            idPembeli = pembelian[x]['id_pembeli'];
            sendToMysqlTransaksiPembelian(
                idTrx, total, idPembeli, currentString);

            helper!.selectDetailTransaksiPembelian(idTrx).then((cou) {
              selectDetailPembelian = cou;

              // var panj = selectDetailPembelian.length;

              for (var a = 0; a < selectDetailPembelian.length; a++) {
                // print(selectDetailPembelian[a]['harga']);

                var idBar = selectDetailPembelian[a]['kode'];
                var idTrans = selectDetailPembelian[a]['id_transaksi'];
                var stock = selectDetailPembelian[a]['stok'];
                var jum = selectDetailPembelian[a]['qty'];
                var status = 2;
                var diskon = selectDetailPembelian[a]['qty'];
                var harga = selectDetailPembelian[a]['harga'];

                sendDetailPembelianMysql(
                    idTrans, idBar, stock, jum, status, diskon, harga);

                //helper!.updateStok(idBar, stock, jum);
              }
              //allDetailTrans = courses;
            });
          }

          // });
        });
        //});
      } else {
        //throw Exception('Failed to load album');

        Fluttertoast.showToast(
          msg: "This is a toast message",
          toastLength: Toast
              .LENGTH_SHORT, // Duration for which the toast should be visible
          gravity: ToastGravity.BOTTOM, // Position of the toast on the screen
          // Font size of the message
        );
      }
    } on Exception catch (exception) {
      // only executed if error is of type Exception

      Fluttertoast.showToast(
        msg: exception.toString(),
        toastLength: Toast
            .LENGTH_SHORT, // Duration for which the toast should be visible
        gravity: ToastGravity.BOTTOM, // Position of the toast on the screen
        // Font size of the message
      );
    } catch (error) {
      Fluttertoast.showToast(
        msg: error.toString(),
        toastLength: Toast
            .LENGTH_SHORT, // Duration for which the toast should be visible
        gravity: ToastGravity.BOTTOM, // Position of the toast on the screen
        // Font size of the message
      );
      // executed for errors of all types other than Exception
    }
  }

  void sendToMysqlPembayaran(idTrx, dibayar, kembalian, total) async {
    try {
      Map data = {
        'id_transaksi': idTrx,
        'dibayar': dibayar,
        'kembalian': kembalian,
        'total': total,

        // 'id_transaksi': idTransaksi,
      };

      String url;

      url = 'save_pembayaran_sync';
      // final response = await htpp.post(Uri.parse(url), body: data);
      final response = await Network().getData_post(data, url);
      // var c = json.decode(response.body);

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: 'BACK UP PEMBAYARAN SUKSES',
          toastLength: Toast
              .LENGTH_SHORT, // Duration for which the toast should be visible
          gravity: ToastGravity.BOTTOM, // Position of the toast on the screen
          // Font size of the message
        );
      } else {
        throw Exception('Failed to load album');
      }
    } on Exception catch (exception) {
      // only executed if error is of type Exception

      Fluttertoast.showToast(
        msg: exception.toString(),
        toastLength: Toast
            .LENGTH_SHORT, // Duration for which the toast should be visible
        gravity: ToastGravity.BOTTOM, // Position of the toast on the screen
        // Font size of the message
      );
    } catch (error) {
      Fluttertoast.showToast(
        msg: error.toString(),
        toastLength: Toast
            .LENGTH_SHORT, // Duration for which the toast should be visible
        gravity: ToastGravity.BOTTOM, // Position of the toast on the screen
        // Font size of the message
      );
      // executed for errors of all types other than Exception
    }
  }

  void sendDetailPembelianMysql(
      idTransaksi, idBarang, stok, qty, status, diskon, harga) async {
    try {
      Map data = {
        'id_transaksi': idTransaksi,
        'id_barang': idBarang,
        'harga': harga,
        'diskon': diskon,
        'qty': qty,
        'status': status,
      };

      String url;

      url = 'save_detail_trans_pembelian_sync';
      // final response = await htpp.post(Uri.parse(url), body: data);
      final response = await Network().getData_post(data, url);
      // var c = json.decode(response.body);

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: 'BACK UP DETAIL TRANSAKSI PEMBELIAN SUKSES',
          toastLength: Toast
              .LENGTH_SHORT, // Duration for which the toast should be visible
          gravity: ToastGravity.BOTTOM, // Position of the toast on the screen
          // Font size of the message
        );
      } else {
        throw Exception('Failed to load album');
      }
    } on Exception catch (exception) {
      // only executed if error is of type Exception

      Fluttertoast.showToast(
        msg: exception.toString(),
        toastLength: Toast
            .LENGTH_SHORT, // Duration for which the toast should be visible
        gravity: ToastGravity.BOTTOM, // Position of the toast on the screen
        // Font size of the message
      );
    } catch (error) {
      Fluttertoast.showToast(
        msg: error.toString(),
        toastLength: Toast
            .LENGTH_SHORT, // Duration for which the toast should be visible
        gravity: ToastGravity.BOTTOM, // Position of the toast on the screen
        // Font size of the message
      );
      // executed for errors of all types other than Exception
    }
  }

  void sendToMysqlTransaksiPembelian(id, total, idPembeli, createdAt) async {
    try {
      Map data = {
        'id': id,
        'total': total,
        'id_pembeli': idPembeli,
        'created_at': createdAt
      };

      String url;

      url = 'save_transaksi_pembelian_sync';
      // final response = await htpp.post(Uri.parse(url), body: data);
      final response = await Network().getData_post(data, url);
      // var c = json.decode(response.body);

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: 'BACK UP TRANSAKSI PEMBELIAN SUKSES',
          toastLength: Toast
              .LENGTH_SHORT, // Duration for which the toast should be visible
          gravity: ToastGravity.BOTTOM, // Position of the toast on the screen
          // Font size of the message
        );
      } else {
        throw Exception('Failed to load album');
      }
    } on Exception catch (exception) {
      // only executed if error is of type Exception

      Fluttertoast.showToast(
        msg: exception.toString(),
        toastLength: Toast
            .LENGTH_SHORT, // Duration for which the toast should be visible
        gravity: ToastGravity.BOTTOM, // Position of the toast on the screen
        // Font size of the message
      );
    } catch (error) {
      Fluttertoast.showToast(
        msg: error.toString(),
        toastLength: Toast
            .LENGTH_SHORT, // Duration for which the toast should be visible
        gravity: ToastGravity.BOTTOM, // Position of the toast on the screen
        // Font size of the message
      );
      // executed for errors of all types other than Exception
    }
  }

  void sendToMysql(id, nama) async {
    Map data = {
      'id': id.toString(),
      'nama_kategori': nama,
    };

    String url;

    if (id != 0 && nama != '') {
      url = 'update_kategori';
    } else if (id != 0) {
      url = 'delete_kategori';
    } else {
      url = 'save_sync_kategori';
    }
    // final response = await htpp.post(Uri.parse(url), body: data);
    final response = await Network().getData_post(data, url);
    // var c = json.decode(response.body);

    if (response.statusCode == 200) {
      print('sukses');
    } else {
      throw Exception('Failed to load album');
    }
  }

  // Update an existing journal

  // Delete an item

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const Master(
                      title: "",
                    )),
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
            backgroundColor: Colors.grey[300],
            body: const SingleChildScrollView(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
            ))));
  }
}
