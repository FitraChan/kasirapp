import 'dart:convert';

//import 'package:connectivity/connectivity.dart';

//import 'package:data_connection_checker/data_connection_checker.dart';
//import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../helpers/dbkasir.dart';
import '../network_utils/api.dart';

import '../model/kategoriModel.dart';
import '../model/shiftModel.dart';

import '../model/produkModel.dart';
import 'package:http/http.dart' as htpp;
import 'package:kasirapp/model/jamKerjaModel.dart';

class SyncronizationData {
  final conn = KasirHelper.instance;

  Future<List<KategoriModelMysql>> fetchAllKategori() async {
    final dbClient = KasirHelper.db;
    List<KategoriModelMysql> kategori = [];
    try {
      final maps = await dbClient?.query("tb_kategori");
      for (var item in maps!) {
        kategori.add(KategoriModelMysql.fromJson(item));
      }
    } catch (e) {
      print(e.toString());
    }
    return kategori;
  }

  Future saveToMysqlKategori(List<KategoriModelMysql> kategori) async {
    for (var i = 0; i < kategori.length; i++) {
      Map<String, dynamic> data = {
        "id": kategori[i].id.toString(),
        //"user_id": contactList[i].userId.toString(),
        "nama_kategori": kategori[i].namaKategori,

        //"created_at": contactList[i].createdAt,
      };

      String url = 'save_sync_kategori';
      final response = await htpp.post(Uri.parse(url), body: data);
      if (response.statusCode == 200) {
        print("Saving Data ");
      } else {
        print(response.statusCode);
      }
    }
  }

  Future<int> addDataKategori(KategoriModelMysql kategoriModel) async {
    var dbclient = KasirHelper.db;
    int result = 0;
    //dbclient!.execute("delete from tb_kategori");
    try {
      result = await dbclient!.insert('tb_kategori', kategoriModel.toJson());
      //return db!.insert('tb_detail_transaksi_pembelian', kat.toMap());
    } catch (e) {
      print(e.toString());
    }
    return result;
  }

  Future<int> addDataShift(ShiftModelMysql shiftModel) async {
    var dbclient = KasirHelper.db;
    int result = 0;
    //dbclient!.execute("delete from tb_kategori");
    try {
      result = await dbclient!.insert('tb_shift', shiftModel.toJson());
      //return db!.insert('tb_detail_transaksi_pembelian', kat.toMap());
    } catch (e) {
      print(e.toString());
    }
    return result;
  }

  Future<List<JamKerjaModelMysql>> restoreMysqlJamKerja() async {
    //  List? listed;

    var dbclient = KasirHelper.db;
    dbclient!.execute("delete from tb_jam_kerja");
    String url = 'jam_kerja';
    final response = await Network().getData_get(url);

    List<JamKerjaModelMysql> tempList = [];

    List<dynamic> values = <dynamic>[];
    values = json.decode(response.body);
    for (int i = 0; i < values.length; i++) {
      tempList.add(JamKerjaModelMysql.fromJson(values[i]));
    }

    return tempList;
  }

  Future<List<KategoriModelMysql>> restoreMysqlKategori() async {
    //  List? listed;

    var dbclient = KasirHelper.db;
    dbclient!.execute("delete from tb_kategori");
    String url = 'kategori';
    final response = await Network().getData_get(url);

    List<KategoriModelMysql> tempList = [];

    List<dynamic> values = <dynamic>[];
    values = json.decode(response.body);
    for (int i = 0; i < values.length; i++) {
      tempList.add(KategoriModelMysql.fromJson(values[i]));
    }

    return tempList;
  }

  Future<List<ShiftModelMysql>> restoreMysqlShift() async {
    //  List? listed;

    var dbclient = KasirHelper.db;
    dbclient!.execute("delete from tb_shift");
    String url = 'lastShift5';
    final response = await Network().getData_get(url);

    List<ShiftModelMysql> tempList = [];

    List<dynamic> values = <dynamic>[];
    values = json.decode(response.body);
    for (int i = 0; i < values.length; i++) {
      tempList.add(ShiftModelMysql.fromJson(values[i]));
    }

    return tempList;
  }

  Future<List<ProdukModelMysql>> restoreMysqlProduk() async {
    //  List? listed;

    var dbclient = KasirHelper.db;
    dbclient!.execute("delete from tb_produk");
    String url = 'produkRestore';
    final response = await Network().getData_get(url);

    List<ProdukModelMysql> tempList = [];

    List<dynamic> values = <dynamic>[];
    values = json.decode(response.body);

    //print(values.length);
    for (int i = 0; i < values.length; i++) {
      tempList.add(ProdukModelMysql.fromJson(values[i]));
    }

    return tempList;
  }

  Future<int> addDataProduk(ProdukModelMysql produkModel) async {
    var dbclient = KasirHelper.db;
    int result = 0;
    //dbclient!.execute("delete from tb_kategori");
    try {
      result = await dbclient!.insert('tb_produk', produkModel.toJson());
      //return db!.insert('tb_detail_transaksi_pembelian', kat.toMap());
    } catch (e) {
      print(e.toString());
    }
    return result;
  }

  Future<int> addDataJamKerja(JamKerjaModelMysql jamKerjaModel) async {
    var dbclient = KasirHelper.db;
    int result = 0;
    //dbclient!.execute("delete from tb_kategori");
    try {
      result = await dbclient!.insert('tb_jam_kerja', jamKerjaModel.toJson());
      //return db!.insert('tb_detail_transaksi_pembelian', kat.toMap());
    } catch (e) {
      print(e.toString());
    }
    return result;
  }
}
