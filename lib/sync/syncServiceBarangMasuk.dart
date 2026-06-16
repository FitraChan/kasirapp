import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:kasirapp/master_data/tambahProduk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kasirapp/network_utils/api.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class SyncServiceBarangMasuk {
  static const String _lastUpdateKey = 'last_update_barang_masuk';
  KasirHelper helpers = KasirHelper();
  final db = KasirHelper.db;

  // final String token;

  /// Ambil last_sync dari storage
  Future<String> getLastUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastUpdateKey) ?? "1970-01-01 00:00:00";
  }

  /// Simpan last_sync baru
  Future<void> saveLastUpdate(String value) async {
    final prefs = await SharedPreferences.getInstance();
    DateTime dateTime = DateTime.parse(value).toLocal();
    String formatted = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);

    await prefs.setString(_lastUpdateKey, formatted);
  }

  /// PROSES SYNC UTAMA
  Future<bool> syncBarangMasuk() async {
    try {
      final lastUpdate = await getLastUpdate();

      final response = await Network().getData_post(
        {
          'last_update': lastUpdate,
        },
        'barangMasukSync',
      );

      if (response.statusCode != 200) {
        print('SYNC FAILED: ${response.body}');
        return false;
      }

      final result = json.decode(response.body);
      final List data = result['data'];
      final newLastUpdate = result['last_update'];

      for (final item in data) {
        print(
            'SYNC BARANG MASUK: ${item['no_transaksi']} - ${item['updated_at']}');
        await _saveKategoriToLocal(item);
      }

      await saveLastUpdate(newLastUpdate);

      return true;
    } catch (e) {
      print('SYNC ERROR: $e');
      return false;
    }
  }

  Future<void> _saveKategoriToLocal(Map<String, dynamic> item) async {
    try {
      // 🔥 HANDLE DELETE

      // 🔥 FORMAT TANGGAL
      DateTime dateValue;
      try {
        dateValue = DateTime.parse(item['updated_at']).toLocal();
      } catch (e) {
        dateValue = DateTime.now();
      }

      final tanggal = DateFormat('yyyy-MM-dd HH:mm').format(dateValue);

      // 🔥 UPSERT (INSERT / UPDATE)
      await db!.insert(
        'barang_masuk',
        {
          'no_transaksi': item['no_transaksi'],
          'tanggal': item['tanggal'],
          'kode_produk': item['kode_produk'],
          'kode_supplier': item['kode_supplier'],
          'qty': item['qty'],
          'harga_beli': item['harga_beli'],
          'total': item['total'],
          'keterangan': item['keterangan'],
          'metode_pembayaran': item['metode_pembayaran'],
          'is_sync': 1,
          'created_at': tanggal,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print("ERROR SAVE BARANG MASUK: $e");
    }
  }

  Future<void> syncAll() async {
    try {
      String url = 'barangMasukRestoreNew';

      final response = await Network().getData_get(url);
      final dbClient = KasirHelper.db;

      await dbClient!.rawDelete("DELETE FROM barang_masuk");
      await dbClient
          .rawDelete("DELETE FROM sqlite_sequence WHERE name='barang_masuk'");

      if (response.statusCode == 200) {
        List listKategori = json.decode(response.body)['data'];

        var newLastUpdate = json.decode(response.body)['last_update'];

        for (var item in listKategori) {
          try {
            var id = item['id'];
            var noTransaksi = item['no_transaksi'];
            var tanggal = item['tanggal'];
            var kodeSupplier = item['kode_supplier'];
            var kodeProduk = item['kode_produk'];
            var qty = item['qty'];
            var hargaBeli = item['harga_beli'];
            var total = item['total'];
            var metodePembayaran = item['metode_pembayaran'];
            var keterangan = item['keterangan'];
            var createdAtMysql = item['created_at'];

            // insert data baru
            var dateValue =
                DateFormat("yyyy-MM-dd HH:mm:ss").parse(createdAtMysql);
            var tanggalMysql = DateFormat('yyyy-MM-dd HH:mm').format(dateValue);
            // insert data baru
            await dbClient.rawQuery('''
              INSERT INTO barang_masuk
              (no_transaksi, tanggal, kode_supplier, kode_produk, qty, harga_beli, total, metode_pembayaran, keterangan, created_at, is_sync)
              VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', [
              noTransaksi,
              tanggal,
              kodeSupplier,
              kodeProduk,
              qty,
              hargaBeli,
              total,
              metodePembayaran,
              keterangan,
              tanggalMysql,
              1
            ]);

            print('SYNC RESTORE BARANG MASUK: $noTransaksi - $createdAtMysql');
          } catch (e) {
            print('Error proses barang masuk: $e');
          }
        }

        await saveLastUpdate(newLastUpdate);
      } else {
        print('API barang masuk gagal: ${response.body}');
      }
    } on SocketException catch (_) {
      print("Tidak bisa konek ke server");
    } on HttpException catch (_) {
      print("Server tidak merespon");
    } on FormatException catch (_) {
      print("Format response salah");
    } catch (e) {
      print("Error lain: $e");
    }
  }
}
