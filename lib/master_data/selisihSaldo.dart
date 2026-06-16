import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:kasirapp/master_data/master.dart';
import 'package:intl/intl.dart';
//import 'package:kasirapp/model/shiftModel.dart';
import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:kasirapp/network_utils/api.dart';
import 'package:kasirapp/screen/home.dart';
import 'package:sqflite/sqflite.dart';
import '../helpers/currency.dart';
import '../screen/menu1.dart';
import '../sync/restoreAll.dart';

//import 'package:firebase_messaging/firebase_messaging.dart';

class SelisihSaldo extends StatefulWidget {
  const SelisihSaldo({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _SelisihSaldoState createState() => _SelisihSaldoState();
}

class _SelisihSaldoState extends State<SelisihSaldo> {
  //  FirebaseMessaging messaging;

  TextEditingController teSeach = TextEditingController();

  bool _isLoading = true;
  KasirHelper? helper;
  var items = [];
  var allCourses = [];

  void _refreshSaldo() {
    if (helper != null) {
      helper!.getSaldo().then((courses) {
        setState(() {
          allCourses = courses;
          items = allCourses;
          _isLoading = false;
        });
      });
    }
  }

  bool isLoading = false;

  syncAll() async {
    setState(() {
      _isLoading = true;
    });

    final dbClient = KasirHelper.db;
    String url = 'lastShift5';

    try {
      final response =
          await Network().getData_get(url).timeout(Duration(seconds: 15));

      print('Response status: ${response.body}');

      if (response.statusCode != 200) {
        print('Error: ${response.body}');
        return;
      }

      // Decode JSON di luar setState
      List<dynamic> data = json.decode(response.body);

      // Hapus semua produk lama
      await dbClient!.execute("DELETE FROM tb_shift");

      // Siapkan batch insert
      Batch batch = dbClient.batch();

      for (var item in data) {
        var id = item['id'];
        var userid = item['user_id'];
        var saldoawal = item['saldo_awal'].toString();
        var saldoakhir = item['saldo_akhir'];
        var uangfisik = item['uang_fisik'].toString();
        var selisih = item['selisih'];
        var waktubuka = item['waktu_buka'].toString();
        var waktututup = item['waktu_tutup'].toString();
        var createdAt = item['created_at'].toString();

        batch.insert('tb_shift', {
          'id': id,
          'user_id': userid,
          'saldo_awal': saldoawal,
          'saldo_akhir': saldoakhir,
          'uang_fisik': uangfisik,
          'selisih': selisih,
          'waktu_buka': waktubuka,
          'waktu_tutup': waktututup,
          'created_at': createdAt,
        });
      }

      // Eksekusi batch sekaligus
      await batch.commit(noResult: true);

      // Navigasi ke halaman produk setelah selesai
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SelisihSaldo(title: '')),
      );
    } on TimeoutException {
      print('Timeout: Tidak bisa terhubung ke server.');
    } on SocketException {
      print('Koneksi internet bermasalah.');
    } catch (e) {
      print('Terjadi error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    //   restoreToMysql();
    _refreshSaldo();

    helper = KasirHelper();

    helper!.getSaldo().then((courses) {
      setState(() {
        allCourses = courses;
        items = allCourses;
        _isLoading = false;
      });
    });
  }

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _saldoAwalController = TextEditingController();
  final TextEditingController _saldoAkhirController = TextEditingController();

  void _showForm(int? id) async {
    if (id != null) {
      final existingJournal =
          items.firstWhere((element) => element['id'] == id);
      _namaController.text = rupiah.format(existingJournal['uang_fisik']);
      _saldoAwalController.text = rupiah.format(existingJournal['saldo_awal']);
      _saldoAkhirController.text =
          rupiah.format(existingJournal['saldo_akhir']);
    }

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    showModalBottomSheet(
        context: context,
        elevation: 5,
        builder: (_) => Container(
              padding: const EdgeInsets.all(15),
              width: double.infinity,
              height: 500,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _namaController,
                    decoration: const InputDecoration(hintText: 'Uang Fisik'),
                    keyboardType:
                        TextInputType.number, // tampilkan keyboard angka
                    inputFormatters: [
                      CurrencyInputFormatter(
                          currencyFormatter), // hanya boleh angka
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _saldoAwalController,
                    decoration: const InputDecoration(hintText: 'Saldo Awal'),
                    keyboardType:
                        TextInputType.number, // tampilkan keyboard angka
                    inputFormatters: [
                      CurrencyInputFormatter(
                          currencyFormatter), // hanya boleh angka
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _saldoAkhirController,
                    decoration: const InputDecoration(hintText: 'Saldo Akhir'),
                    keyboardType:
                        TextInputType.number, // tampilkan keyboard angka
                    inputFormatters: [
                      CurrencyInputFormatter(
                          currencyFormatter), // hanya boleh angka
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Save new journal

                      if (id != null) {
                        await _updateItem(id);
                      } else {
                        await _tambahItem();
                      }

                      // Clear the text fields
                      _namaController.text = '';
                      _saldoAwalController.text = '';
                      _saldoAkhirController.text = '';

                      // Close the bottom sheet
                      Navigator.of(context).pop();
                    },
                    child: Text(id == null ? 'Create New' : 'Update'),
                  )
                ],
              ),
            ));
  }

  void sendToMysql(id, nama, saldoAwal, saldoAkhir) async {
    Map data = {
      'id': id.toString(),
      'uang_fisik': nama,
      'saldo_awal': saldoAwal,
      'saldo_akhir': saldoAkhir,
    };

    String url;

    if (id != 0 && nama != '') {
      url = 'update_shift';
    } else if (id != 0) {
      url = 'delete_shift';
    } else {
      url = 'tambah_shift';
    }
    // final response = await htpp.post(Uri.parse(url), body: data);
    final response = await Network().getData_post(data, url);
    // var c = json.decode(response.body);

    if (response.statusCode == 200) {
      print(response.body);
    } else {
      throw Exception('Failed to load album');
    }
  }

  String removeCurrency(String value) {
    // Hapus semua selain angka
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }

  // Update an existing journal
  Future<void> _updateItem(int id) async {
    //contact.phone = phoneController.text;

    var uangFisik = removeCurrency(_namaController.text);
    var saldoAwal = removeCurrency(_saldoAwalController.text);
    var saldoAkhir = removeCurrency(_saldoAkhirController.text);
    await helper!.updateShift(id, uangFisik, saldoAwal, saldoAkhir);
    _refreshSaldo();

    sendToMysql(id, uangFisik, saldoAwal, saldoAkhir);
  }

  Future<void> _tambahItem() async {
    //contact.phone = phoneController.text;

    var uangFisik = removeCurrency(_namaController.text);
    var saldoAwal = removeCurrency(_saldoAwalController.text);
    var saldoAkhir = removeCurrency(_saldoAkhirController.text);
    await helper!.tambahShift(uangFisik, saldoAwal, saldoAkhir);
    _refreshSaldo();

    sendToMysql(0, uangFisik, saldoAwal, saldoAkhir);
  }

  // Delete an item
  void _deleteItem(int id) async {
    await helper!.deleteShift(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a kategori!'),
    ));

    _refreshSaldo();
    Navigator.of(context).pop(false);
    sendToMysql(id, '', '', '');
  }

  final rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
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
                  onPressed: () {
                    _showForm(null);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.restore, color: Colors.white),
                  onPressed: () {
                    syncAll();
                    _refreshSaldo();
                  },
                ),
              ],
            ),
            drawer: const Menu(),
            backgroundColor: Colors.grey[300],
            body: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  // students(),

                  _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : dataKategori(),
                  const SizedBox(height: 15),
                ]))));
  }

  showAlertDialog(BuildContext context, int id) {
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
        // hapus(id);
        _deleteItem(id);
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

  Container dataKategori() {
    return Container(
        child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              var nilai =
                  int.tryParse(items[index]['uang_fisik'].toString()) ?? 0;

              var nilaiSaldoAwal =
                  int.tryParse(items[index]['saldo_awal'].toString()) ?? 0;
              var nilaiSaldoAkhir =
                  int.tryParse(items[index]['saldo_akhir'].toString()) ?? 0;
              var tampil = rupiah.format(nilai);
              var saldoAwal = rupiah.format(nilaiSaldoAwal);
              var saldoAkhir = rupiah.format(nilaiSaldoAkhir);
              return Card(
                color: Colors.orange[200],
                margin: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Saldo Awal : $saldoAwal',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Saldo Akhir : $saldoAkhir',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Uang Fisik : $tampil',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    'Tanggal: ${DateFormat('dd-MM-yyyy').format(
                      DateTime.parse(items[index]['created_at']),
                    )}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showForm(items[index]['id']),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showAlertDialog(context, items[index]['id']);
                        },
                      ),
                    ],
                  ),
                ),
              );
              ;
            }));
  }

  @override
  void dispose() {
    // Membersihkan sumber daya saat widget dihapus
    // myController.dispose();

    _namaController.dispose();
    teSeach.dispose();
    super.dispose();
  }
}
