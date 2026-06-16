import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';

import 'package:kasirapp/master_data/master.dart';

import 'package:kasirapp/model/kategoriModel.dart';
import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:kasirapp/network_utils/api.dart';
import 'package:kasirapp/screen/home.dart';
import 'package:kasirapp/sync/syncServiceKategori.dart';
import '../screen/menu1.dart';
import '../sync/restoreAll.dart';

//import 'package:firebase_messaging/firebase_messaging.dart';

class Kategori extends StatefulWidget {
  const Kategori({Key? key, required this.title, required this.tambah})
      : super(key: key);
  final String title;
  final int tambah;

  @override
  _KategoriState createState() => _KategoriState();
}

class _KategoriState extends State<Kategori> {
  //  FirebaseMessaging messaging;

  TextEditingController teSeach = TextEditingController();
  final syncServiceKategori = SyncServiceKategori();

  bool _isLoading = true;
  KasirHelper? helper;
  var items = [];
  var allCourses = [];

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

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    helper = KasirHelper();

    // _refreshKategori(); // kalau async
    // await syncKategori(); // TUNGGU sampai selesai

    final success = await syncServiceKategori.syncKategori();

    if (success) {
      print('✅ Sync berhasil');
      _refreshKategori();
    } else {
      print('❌ Sync gagal');
    }

    final courses = await helper!.allCategori();

    setState(() {
      allCourses = courses;
      items = allCourses;
      _isLoading = false;
    });
  }

  final TextEditingController _namaController = TextEditingController();

  void _showForm(kode) async {
    if (kode != null) {
      final existingJournal =
          items.firstWhere((element) => element['kode'] == kode);
      _namaController.text = existingJournal['nama_kategori'];
    }

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
                    decoration:
                        const InputDecoration(hintText: 'Nama Kategori'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Save new journal
                      if (kode == null) {
                        await _addItem();
                      }

                      if (kode != null) {
                        await _updateItem(kode);
                      }

                      // Clear the text fields
                      _namaController.text = '';

                      // Close the bottom sheet
                      Navigator.of(context).pop();
                    },
                    child: Text(kode == null ? 'Create New' : 'Update'),
                  )
                ],
              ),
            ));
  }

  Future<void> _addItem() async {
    String kode = await helper!.generateKodeKategori();

    KategoriModel kat = KategoriModel({
      'kode': kode,
      'nama_kategori': _namaController.text,
    });

    await helper!.createKategori(kat);
    _refreshKategori();
    sendToMysql(kode, _namaController.text, 0);
  }

  void sendToMysql(kode, nama, isUpdate) async {
    Map data = {
      'kode': kode.toString(),
      'nama_kategori': nama,
    };

    var url;

    if (kode != '' && nama != '' && isUpdate == 1) {
      url = 'update_kategori';
    } else if (kode != '' && nama != '' && isUpdate == 0) {
      url = 'save_sync_kategori';
    } else if (kode != '' && nama == '' && isUpdate == 0) {
      url = 'delete_kategori';
    }
    // final response = await htpp.post(Uri.parse(url), body: data);
    final response = await Network().getData_post(data, url);
    // var c = json.decode(response.body);

    if (response.statusCode == 200) {
      print('sukses');

      await helper!.sync(kode, 'kode', 'tb_kategori');
    } else {
      print(response.body);
      throw Exception('Failed to load album');
    }
  }

  // Update an existing journal
  Future<void> _updateItem(kode) async {
    KategoriModel kat =
        KategoriModel({'kode': kode, 'nama_kategori': _namaController.text});
    //contact.phone = phoneController.text;
    await helper!.updateKategori(kode, _namaController.text);
    _refreshKategori();

    sendToMysql(kode, _namaController.text, 1);
  }

  // Delete an item
  void _deleteItem(kode) async {
    await helper!.deleteKategori(kode);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a kategori!'),
    ));

    _refreshKategori();
    Navigator.of(context).pop(false);
    sendToMysql(kode, '', 0);
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
                    // restoreToMysql();

                    syncServiceKategori.syncAll();
                    _refreshKategori();
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
                      : dataKategori(),
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

  showAlertDialog(BuildContext context, id) {
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
              KategoriModel? course = KategoriModel.fromMap(items[index]);
              return Card(
                color: Colors.orange[200],
                margin: const EdgeInsets.all(15),
                child: ListTile(
                    title: Text('${course.kode} - ${course.nama}'),
                    // subtitle: Text(_kategori[index]['description']),
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
