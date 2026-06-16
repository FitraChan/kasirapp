import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:kasirapp/master_data/tambahProduk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kasirapp/network_utils/api.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class SyncServicePengeluaran {
  static const String _lastUpdateKey = 'last_update_pengeluaran';
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
  Future<bool> syncPengeluaran() async {
    try {
      final lastUpdate = await getLastUpdate();

      final response = await Network().getData_post(
        {
          'last_update': lastUpdate,
        },
        'pengeluaranSync',
      );

      if (response.statusCode != 200) {
        print('SYNC FAILED: ${response.body}');
        return false;
      }

      final result = json.decode(response.body);
      final List data = result['data'];
      final newLastUpdate = result['last_update'];

      for (final item in data) {
        await _savePengeluaranToLocal(item);
      }

      await saveLastUpdate(newLastUpdate);

      return true;
    } catch (e) {
      print('SYNC ERROR: $e');
      return false;
    }
  }

  Future<void> _savePengeluaranToLocal(Map<String, dynamic> item) async {
    try {
      final id = item['id'];

      // 🔥 HANDLE DELETE
      if (item['deleted_at'] != null) {
        await db!.delete(
          'tb_pengeluaran',
          where: 'id = ?',
          whereArgs: [id],
        );
        return;
      }

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
        'tb_pengeluaran',
        {
          'id': item['id'],
          'keterangan': item['keterangan'],
          'nilai': item['nilai'],
          'created_at': tanggal,
          'is_sync': 1,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print("ERROR SAVE PENGELUARAN: $e");
    }
  }

  Future<void> syncAll() async {
    try {
      String url = 'pengeluaranRestoreNew';

      final response = await Network().getData_get(url);
      final dbClient = KasirHelper.db;

      await dbClient!.rawDelete("DELETE FROM tb_pengeluaran");
      await dbClient
          .rawDelete("DELETE FROM sqlite_sequence WHERE name='tb_pengeluaran'");

      var check = await dbClient.rawQuery("SELECT * FROM tb_pengeluaran");
      print("Jumlah setelah delete: ${check.length}");

      if (response.statusCode == 200) {
        List listPengeluaran = json.decode(response.body)['data'];

        var newLastUpdate = json.decode(response.body)['last_update'];

        for (var item in listPengeluaran) {
          try {
            var id = item['id'];

            var keterangan = item['keterangan'];
            var nilai = item['nilai'];
            var createdAtMysql = item['created_at'];

            // konversi tanggal MySQL → lokal
            var dateValue = DateFormat("yyyy-MM-ddTHH:mm:ssZ")
                .parseUTC(createdAtMysql)
                .subtract(const Duration(hours: 1))
                .toLocal();

            var tanggalMysql = DateFormat('yyyy-MM-dd HH:mm').format(dateValue);

            // insert data baru
            await dbClient.rawQuery('''
              INSERT INTO tb_pengeluaran
              (id, keterangan, nilai, created_at, is_sync)
              VALUES (?, ?, ?, ?, ?)
            ''', [id, keterangan, nilai, tanggalMysql, 1]);
          } catch (e) {
            print('Error proses pengeluaran: $e');
          }
        }

        await saveLastUpdate(newLastUpdate);
      } else {
        print('API pengeluaran gagal: ${response.body}');
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
