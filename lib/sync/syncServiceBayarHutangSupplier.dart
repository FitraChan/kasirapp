import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kasirapp/network_utils/api.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class SyncServiceBayarHutangSupplier {
  static const String _lastUpdateKey = 'last_update_bayar_hutang_supplier';
  final db = KasirHelper.db;

  /// 🔹 GET LAST UPDATE
  Future<String> getLastUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastUpdateKey) ?? "1970-01-01 00:00:00";
  }

  /// 🔹 SAVE LAST UPDATE
  Future<void> saveLastUpdate(String value) async {
    final prefs = await SharedPreferences.getInstance();

    DateTime dateTime = DateTime.parse(value).toLocal();
    String formatted = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);

    await prefs.setString(_lastUpdateKey, formatted);
  }

  /// 🔥 SYNC INCREMENTAL
  Future<bool> syncBayarHutang() async {
    try {
      final lastUpdate = await getLastUpdate();

      final response = await Network().getData_post(
        {
          'last_update': lastUpdate,
        },
        'bayarHutangSupplierSync',
      );

      if (response.statusCode != 200) {
        print('SYNC BAYAR FAILED: ${response.body}');
        return false;
      }

      final result = json.decode(response.body);
      final List data = result['data'];
      final newLastUpdate = result['last_update'];

      for (final item in data) {
        await _saveToLocal(item);
      }

      await saveLastUpdate(newLastUpdate);

      return true;
    } catch (e) {
      print('SYNC BAYAR ERROR: $e');
      return false;
    }
  }

  /// 🔥 SAVE TO SQLITE (UPSERT + DELETE)
  Future<void> _saveToLocal(Map<String, dynamic> item) async {
    try {
      final id = item['id'];

      // 🔥 HANDLE DELETE
      if (item['deleted_at'] != null) {
        await db!.delete(
          'tb_bayar_hutang_supplier',
          where: 'id = ?',
          whereArgs: [id],
        );
        return;
      }

      // 🔥 FORMAT TANGGAL
      DateTime createdAt;
      DateTime updatedAt;

      try {
        createdAt = DateTime.parse(item['created_at']).toLocal();
      } catch (e) {
        createdAt = DateTime.now();
      }

      try {
        updatedAt = DateTime.parse(item['updated_at']).toLocal();
      } catch (e) {
        updatedAt = DateTime.now();
      }

      final created = DateFormat('yyyy-MM-dd HH:mm:ss').format(createdAt);
      final updated = DateFormat('yyyy-MM-dd HH:mm:ss').format(updatedAt);

      // 🔥 UPSERT
      await db!.insert(
        'tb_bayar_hutang_supplier',
        {
          'id': item['id'],
          'kode_hutang': item['kode_hutang'],
          'jumlah_bayar': item['jumlah_bayar'],
          'tanggal': item['tanggal'],
          'created_at': created,
          'updated_at': updated,
          'is_sync': 1,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print("ERROR SAVE BAYAR: $e");
    }
  }

  /// 🔥 FULL RESTORE
  Future<void> syncAll() async {
    try {
      String url = 'bayarHutangSupplierRestore';

      final response = await Network().getData_get(url);
      final dbClient = KasirHelper.db;

      // 🔥 HAPUS SEMUA
      await dbClient!.rawDelete("DELETE FROM tb_bayar_hutang_supplier");
      await dbClient.rawDelete(
          "DELETE FROM sqlite_sequence WHERE name='tb_bayar_hutang_supplier'");

      if (response.statusCode == 200) {
        List listData = json.decode(response.body)['data'];
        var newLastUpdate = json.decode(response.body)['last_update'];

        for (var item in listData) {
          try {
            var createdDate = DateTime.parse(item['created_at']).toLocal();
            var updatedDate = DateTime.parse(item['updated_at']).toLocal();

            var created = DateFormat('yyyy-MM-dd HH:mm:ss').format(createdDate);
            var updated = DateFormat('yyyy-MM-dd HH:mm:ss').format(updatedDate);

            await dbClient.rawInsert('''
              INSERT INTO tb_bayar_hutang_supplier
              (id, kode_hutang, jumlah_bayar, tanggal, created_at, updated_at, is_sync)
              VALUES (?, ?, ?, ?, ?, ?, ?)
            ''', [
              item['id'],
              item['kode_hutang'],
              item['jumlah_bayar'],
              item['tanggal'],
              created,
              updated,
              1
            ]);
          } catch (e) {
            print('Error proses bayar hutang: $e');
          }
        }

        await saveLastUpdate(newLastUpdate);
      } else {
        print('API bayar hutang gagal: ${response.body}');
      }
    } on SocketException {
      print("Tidak bisa konek ke server");
    } on HttpException {
      print("Server tidak merespon");
    } on FormatException {
      print("Format response salah");
    } catch (e) {
      print("Error lain: $e");
    }
  }
}
