import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:kasirapp/master_data/master.dart';

import 'package:kasirapp/model/kategoriModel.dart';
import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:kasirapp/network_utils/api.dart';
import 'package:kasirapp/screen/home.dart';
import 'package:kasirapp/sync/syncServiceConfig.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../screen/menu1.dart';

//import 'package:firebase_messaging/firebase_messaging.dart';

class Config extends StatefulWidget {
  const Config({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _ConfigState createState() => _ConfigState();
}

class _ConfigState extends State<Config> {
  KasirHelper? helper;
  final syncServiceKonfigurasi = SyncServiceConfig();
  bool isLoading = true;

  bool isOn = false; // Nilai awal: OFF  @override

  var allConfig = [];
  var listFitur = [];
  void initState() {
    _initData();
    helper = KasirHelper();
    if (helper != null) {
      helper!.konfigurasi().then((product) {
        setState(() {
          allConfig = product;
          listFitur = allConfig;
        });
      });
    }

    super.initState();
  }

  syncAll() async {
    setState(() {
      isLoading = true;
    });

    final dbClient = KasirHelper.db;
    String url = 'konfigurasiRestore';

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
      await dbClient!.execute("DELETE FROM konfigurasi");

      await dbClient
          .execute("DELETE FROM sqlite_sequence WHERE name='konfigurasi'");

      // Siapkan batch insert
      Batch batch = dbClient.batch();

      for (var item in data) {
        String kodeToko = item['kode_toko'];
        String nama = item['nama'].toString();
        String status = item['status'].toString();
        String createdAtMysql = item['created_at'];

        // Tambahkan ke batch
        batch.insert('konfigurasi', {
          'kode_toko': kodeToko,
          'nama': nama,
          'status': status,
          'created_at': createdAtMysql,
        });
      }

      // Eksekusi batch sekaligus
      await batch.commit(noResult: true);

      // Navigasi ke halaman produk setelah selesai
      if (mounted) {
        //  _refreshProduk();

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const Config(
                    title: '',
                  )),
        );
      }
    } on TimeoutException {
      print('Timeout: Tidak bisa terhubung ke server.');
    } on SocketException {
      print('Koneksi internet bermasalah.');
    } catch (e) {
      print('Terjadi error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _initData() async {
    await syncServiceKonfigurasi.syncKonfigurasi();
  }

  Future<void> _toggleStatus(String nama, bool value) async {
    final updatedStatus = value ? "1" : "0";
    SharedPreferences localStorage = await SharedPreferences.getInstance();

    var kodeToko = localStorage.getString('kode_toko');

    Map data;

    data = {
      'nama': nama,
      'status': updatedStatus,
      'kode_toko': kodeToko,
    };

    var url = 'konfigurasi';

    final response = await Network().getData_post(data, url);
    if (response.statusCode == 200) {
      print('sukses');
    } else {
      print(response.body);
      throw Exception(response);
    }

    helper!.updateKonfigurasi(updatedStatus, nama);
    var session;

    if (nama == 'field kategori') {
      session = 'kategori';
    } else if (nama == 'field pencarian produk') {
      session = 'pencarian';
    } else if (nama == 'stok') {
      session = 'stok';
    } else if (nama == 'kategori dalam container') {
      session = 'kategoriDalamContainer';
    }

    await localStorage.remove(session);

    localStorage.setString(session, updatedStatus);

    cekConfig();
  }

  void cekConfig() async {
    helper!.konfigurasi().then((product) {
      setState(() {
        allConfig = product;
        listFitur = allConfig;
      });
    });
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
            title: const Text('Konfigurasi Fitur'),
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
                icon: const Icon(Icons.restore, color: Colors.white),
                onPressed: () {
                  syncAll();
                },
              ),
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
          drawer: const Menu(),
          backgroundColor: Colors.grey[300],
          body: ListView.builder(
            itemCount: listFitur.length,
            itemBuilder: (context, index) {
              final fitur = listFitur[index];
              return SwitchListTile(
                title: Text(fitur['nama'] + ' id ' + fitur['id'].toString()),
                value: fitur['status'] == 1,
                onChanged: (value) => _toggleStatus(fitur['nama'], value),
              );
            },
          ),
        ));
  }
}
