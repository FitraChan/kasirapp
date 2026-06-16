import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:kasirapp/master_data/master.dart';

import 'package:kasirapp/model/kategoriModel.dart';
import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:kasirapp/network_utils/api.dart';
import 'package:kasirapp/screen/home.dart';
import 'package:sqflite/sqflite.dart';
import '../screen/menu1.dart';
import '../sync/restoreAll.dart';

//import 'package:firebase_messaging/firebase_messaging.dart';

class Pelanggan extends StatefulWidget {
  const Pelanggan({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _PelangganState createState() => _PelangganState();
}

class _PelangganState extends State<Pelanggan> {
  //  FirebaseMessaging messaging;

  TextEditingController teSeach = TextEditingController();

  bool _isLoading = true;
  KasirHelper? helper;
  var items = [];
  var allCourses = [];

  void _refresh() {
    if (helper != null) {
      helper!.pelanggan().then((courses) {
        setState(() {
          allCourses = courses;
          items = allCourses;
          _isLoading = false;
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // restoreToMysql();
    //syncAll();
    _refresh();

    helper = KasirHelper();

    helper!.pelanggan().then((courses) {
      setState(() {
        allCourses = courses;
        items = allCourses;
        _isLoading = false;
      });
    });
  }

  syncAll() async {
    final dbClient = KasirHelper.db;
    String url = 'pelanggan';

    try {
      final response =
          await Network().getData_get(url).timeout(Duration(seconds: 15));

      if (response.statusCode != 200) {
        print('Error: ${response.body}');
        return;
      }

      // Decode JSON di luar setState
      List<dynamic> data = json.decode(response.body);

      // Hapus semua produk lama
      await dbClient!.execute("DELETE FROM pelanggan");

      // Siapkan batch insert
      Batch batch = dbClient.batch();

      for (var item in data) {
        String nama = item['nama'];
        String noHp = item['no_hp'].toString();
        String alamat = item['alamat'];

        // Konversi tanggal

        // Ambil gambar jika ada

        // Tambahkan ke batch
        batch.insert('pelanggan', {
          'nama': nama,
          'no_hp': noHp,
          'alamat': alamat,
        });
      }

      // Eksekusi batch sekaligus
      await batch.commit(noResult: true);

      // Navigasi ke halaman produk setelah selesai
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Pelanggan(title: '')),
      );
    } on TimeoutException {
      print('Timeout: Tidak bisa terhubung ke server.');
    } on SocketException {
      print('Koneksi internet bermasalah.');
    } catch (e) {
      print('Terjadi error: $e');
    } finally {}
  }

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _noHp = TextEditingController();
  final TextEditingController _alamat = TextEditingController();

  void _showForm(kode) async {
    if (kode != null) {
      final existingJournal =
          items.firstWhere((element) => element['kode'] == kode);
      _namaController.text = existingJournal['nama'];
      _noHp.text = existingJournal['no_hp'];
      _alamat.text = existingJournal['alamat'];
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Tambahkan ini agar modal bisa menyesuaikan tinggi
      elevation: 5,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          // Bungkus dengan scroll view
          child: Container(
            padding: const EdgeInsets.all(15),
            width: double.infinity,
            child: Column(
              mainAxisSize:
                  MainAxisSize.min, // Supaya tidak mengambil tinggi tetap
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextField(
                  controller: _namaController,
                  decoration: const InputDecoration(hintText: 'Nama'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _noHp,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter
                        .digitsOnly, // Hanya angka yang diizinkan
                  ],
                  decoration: const InputDecoration(hintText: 'No HP'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _alamat,
                  decoration: const InputDecoration(hintText: 'Alamat'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    String kodeBaru =
                        await helper!.generateCustomerCode('pelanggan', 'kode');
                    if (kode == null) {
                      await _addItem(
                        _namaController.text,
                        _noHp.text,
                        _alamat.text,
                        kodeBaru,
                      );
                    } else {
                      await _updateItem(kode);
                    }

                    _namaController.clear();
                    _noHp.clear();
                    _alamat.clear();

                    Navigator.of(context).pop();
                  },
                  child: Text(kode == null ? 'Create New' : 'Update'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addItem(nama, noHp, alamat, kodeBaru) async {
    await helper!.createPelanggan(nama, noHp, alamat, kodeBaru);
    _refresh();
    sendToMysql(0, nama, noHp, alamat, kodeBaru);
  }

  void sendToMysql(id, nama, noHp, alamat, kode) async {
    Map data = {
      'id': id.toString(),
      'nama': nama,
      'no_hp': noHp,
      'alamat': alamat,
      'kode': kode,
    };

    String url;

    if (id != 0 && nama != '') {
      url = 'updatePelanggan';
    } else if (id != 0) {
      url = 'destroyPelanggan';
    } else {
      url = 'simpanPelanggan';
    }
    // final response = await htpp.post(Uri.parse(url), body: data);
    final response = await Network().getData_post(data, url);
    // var c = json.decode(response.body);

    if (response.statusCode == 201) {
      print('sukses');
    } else {
      print(response.body);
      throw Exception('Failed to load album');
    }
  }

  // Update an existing journal
  Future<void> _updateItem(kode) async {
    //contact.phone = phoneController.text;
    await helper!.updatePelanggan(
        kode, _namaController.text, _noHp.text, _alamat.text, kode);
    _refresh();

    sendToMysql(1, _namaController.text, _noHp.text, _alamat.text, kode);
  }

  // Delete an item
  void _deleteItem(kode) async {
    await helper!.deletePelanggan(kode);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a kategori!'),
    ));

    _refresh();
    Navigator.of(context).pop(false);
    sendToMysql(1, '', '', '', kode);
  }

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
              title: const Text('Pelanggan'),
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
                  cari(),
                  _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : _data(),
                  const SizedBox(height: 15),
                ]))));
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
        var course = KategoriModel.fromMap(item);
        if (course.nama!.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      }
      setState(() {
        items = [];
        items.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        items = [];
        items = allCourses;
      });
    }
  }

  showAlertDialog(BuildContext context, kode) {
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
        _deleteItem(kode);
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

  Container _data() {
    return Container(
        child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              KategoriModel? course = KategoriModel.fromMap(items[index]);
              return Card(
                color: Colors.orange[200],
                margin: const EdgeInsets.all(15),
                child: ListTile(
                    title: Text(items[index]['nama'].toString()),
                    // subtitle: Text(_kategori[index]['description']),id
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showForm(items[index]['kode']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              showAlertDialog(context, items[index]['kode']);
                            },
                          ),
                        ],
                      ),
                    )),
              );
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
