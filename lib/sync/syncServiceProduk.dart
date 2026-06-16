import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:kasirapp/master_data/tambahProduk.dart';

import 'package:kasirapp/master_data/produk.dart';
import 'package:kasirapp/screen/login.dart';
import 'package:kasirapp/screen/logout_helper.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:kasirapp/network_utils/api.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class SyncServiceProduk {
  // static const String _lastSyncKey = 'last_sync';
  // static const String _defaultLastSync = '1970-01-01 00:00:00';

  static const String _lastUpdateKey = 'last_update_produk';

  KasirHelper helpers = KasirHelper();
  final db = KasirHelper.db;

  // final String token;

  /// Ambil last_sync dari storage
  Future<String> getLastUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastUpdateKey) ?? "1970-01-01 00:00:00";
  }

  /// Simpan last_sync baru
  Future<void> saveLastUpdate(lastId) async {
    final prefs = await SharedPreferences.getInstance();

    DateTime dateTime = DateTime.parse(lastId).toLocal();
    String formatted = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);

    await prefs.setString(_lastUpdateKey, formatted);
  }

  /// PROSES SYNC UTAMA
  Future syncProduk() async {
    String lastUpdate = await getLastUpdate();
    // bool hasMore = true;

    Map? kirm = {
      'last_update': lastUpdate,
      'limit': 1000,
    };

    //  while (hasMore) {
    final response = await Network().getData_post(kirm, 'produkSync');

    final body = json.decode(response.body);

    if (response.statusCode == 401) {
      //  await logout();

      await LogoutHelper.logout();
      return;
    }
    List data = body['data'];

    final newLastUpdate = body['last_update'];

    Batch batch = db!.batch();

    final results = await Future.wait(
      data.map((item) => _prepareProduk(item)),
    );

    for (var map in results) {
      batch.insert('tb_produk', map);

      print('Sync sampai produk: ${map}');
    }

    await batch.commit(noResult: true);

    lastUpdate = body['last_update'];

    await saveLastUpdate(newLastUpdate);
    // }
  }

  Future<Map<String, dynamic>> _prepareProduk(Map<String, dynamic> item) async {
    String createdAtMysql = item['created_at'];

    var dateValue =
        DateFormat("yyyy-MM-dd HH:mm:ss").parse(createdAtMysql).toLocal();

    String tanggalMysql = DateFormat('yyyy-MM-dd HH:mm').format(dateValue);

    String imgString = '';
    if (item['gambar'] != null && item['gambar'] != '') {
      try {
        final http.Response imgResponse = await http
            .get(Uri.parse(item['gambar']))
            .timeout(Duration(seconds: 10));
        imgString = Utility.base64String(imgResponse.bodyBytes);
      } catch (e) {
        print('Gagal ambil gambar: $e');
      }
    }
    // ⚠️ Saran: skip dulu gambar saat sync besar
    // biar tidak lemot
    // nanti download terpisah

    return {
      'kode': item['kode'],
      'harga_jual': item['harga_jual'].toString(),
      'nama_barang': item['nama_barang'],
      'id_kategori': item['id_kategori'].toString(),
      'tanggal_sekarang': tanggalMysql,
      'harga_beli': item['harga_beli'].toString(),
      'stok': item['stok'].toString(),
      'harga_shopee_food': item['harga_shopee_food'].toString(),
      'harga_go_food': item['harga_go_food'].toString(),
      'gambar': imgString,
      'id_pk': item['id_pk'].toString(),
      'is_sync': 1,
    };
  }

//lokal
  syncAllServer() async {
    final dbClient = KasirHelper.db;
    String url = 'produkRestore';

    String lastUpdate = await getLastUpdate();
    ;

    Map? kirm = {
      'last_update': lastUpdate,
      'limit': 1000,
    };

    try {
      final response = await Network().getData_post(kirm, url);

      print('Response status: ${response.body}');

      if (response.statusCode != 200) {
        print('Error: ${response.body}');
        return;
      }

      // Decode JSON di luar setState
      var data = json.decode(response.body)['data'];

      if (response.statusCode == 401) {
        //  await logout();

        await LogoutHelper.logout();
        return;
      }

      var newLastUpdate = json.decode(response.body)['last_update'];

      // Hapus semua produk lama
      await dbClient!.execute("DELETE FROM tb_produk");

      await dbClient
          .execute("DELETE FROM sqlite_sequence WHERE name='tb_produk'");

      // Siapkan batch insert
      Batch batch = dbClient.batch();

      for (var item in data) {
        print('Sync all Server');

        String kode = item['kode'];
        String hargaJual = item['harga_jual'].toString();
        String nama = item['nama_barang'];
        String idPk = item['id_pk'].toString();
        String idKategori = item['id_kategori'].toString();
        String createdAtMysql = item['created_at'];
        String hargaBeli = item['harga_beli'].toString();
        String stok = item['stok'].toString();
        String hargaGoFood = item['harga_go_food'].toString();
        String hargaShoopeFood = item['harga_shopee_food'].toString();

        // Konversi tanggal
        var dateValue = DateFormat("yyyy-MM-ddTHH:mm:ssZ")
            .parseUTC(createdAtMysql)
            .subtract(const Duration(hours: 1))
            .toLocal();
        String tanggalMysql = DateFormat('yyyy-MM-dd HH:mm').format(dateValue);

        // Ambil gambar jika ada
        String imgString = '';
        if (item['gambar'] != null && item['gambar'] != '') {
          try {
            final http.Response imgResponse = await http
                .get(Uri.parse(item['gambar']))
                .timeout(Duration(seconds: 10));
            imgString = Utility.base64String(imgResponse.bodyBytes);
          } catch (e) {
            print('Gagal ambil gambar: $e');
          }
        }

        // Tambahkan ke batch
        batch.insert('tb_produk', {
          'kode': kode,
          'harga_jual': hargaJual,
          'nama_barang': nama,
          'id_kategori': idKategori,
          'tanggal_sekarang': tanggalMysql,
          'harga_beli': hargaBeli,
          'stok': stok,
          'harga_shopee_food': hargaShoopeFood,
          'harga_go_food': hargaGoFood,
          'gambar': imgString,
          'id_pk': idPk,
          'is_sync': 1,
        });
      }
      print('Jumlah data yang akan disimpan: ${data.length}');
      // Eksekusi batch sekaligus
      await batch.commit(noResult: true);

      await saveLastUpdate(newLastUpdate);

      // Navigasi ke halaman produk setelah selesai
    } on TimeoutException {
      print('Timeout: Tidak bisa terhubung ke server.');
    } on SocketException {
      print('Koneksi internet bermasalah.');
    } catch (e) {
      print('Terjadi error: $e');
    } finally {}
  }

  syncAllLocal() async {
    final dbClient = KasirHelper.db;
    String url = 'produkRestore';

    int offset = 0;
    int limit = 1000;
    bool hasMore = true;

    Map? kirm = {
      // 'last_update': lastUpdate,
      'limit': 1000,
      'offset': 0,
    };

    try {
      // Hapus sekali di awal saja
      await dbClient!.execute("DELETE FROM tb_produk");
      await dbClient
          .execute("DELETE FROM sqlite_sequence WHERE name='tb_produk'");

      while (hasMore) {
        final response = await Network()
            .getData_post(kirm, '$url')
            .timeout(Duration(seconds: 15));

        if (response.statusCode != 200) {
          print('Error: ${response.body}');
          return;
        }

        final body = json.decode(response.body);
        List<dynamic> data = body['data'];

        if (data.isEmpty) {
          hasMore = false;
          break;
        }

        Batch batch = dbClient.batch();

        for (var item in data) {
          batch.insert('tb_produk', {
            'kode': item['kode'],
            'harga_jual': item['harga_jual'].toString(),
            'nama_barang': item['nama_barang'],
            'id_kategori': item['id_kategori'].toString(),
            'tanggal_sekarang': item['created_at'],
            'harga_beli': item['harga_beli'].toString(),
            'stok': item['stok'].toString(),
            'harga_shopee_food': item['harga_shopee_food'].toString(),
            'harga_go_food': item['harga_go_food'].toString(),
            'gambar': '', // ⚠️ skip dulu (lihat bawah)
            'id_pk': item['id_pk'].toString(),
            'is_sync': 1,
          });
        }

        await batch.commit(noResult: true);

        print('Sync offset $offset selesai, jumlah: ${data.length}');

        offset += limit;
      }

      print('SYNC SELESAI');
    } catch (e) {
      print('Error: $e');
    }
  }

  /// SIMPAN PRODUK KE SQLITE
}
