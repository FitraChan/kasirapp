import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kasirapp/network_utils/api.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class SyncServiceHutangSupplier {
  static const String _lastUpdateKey = 'last_update_hutang_supplier';
  KasirHelper helpers = KasirHelper();
  final db = KasirHelper.db;

  /// 🔹 Ambil last update
  Future<String> getLastUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastUpdateKey) ?? "1970-01-01 00:00:00";
  }

  /// 🔹 Simpan last update
  Future<void> saveLastUpdate(String value) async {
    final prefs = await SharedPreferences.getInstance();

    DateTime dateTime = DateTime.parse(value).toLocal();
    String formatted = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);

    await prefs.setString(_lastUpdateKey, formatted);
  }

  /// 🔥 SYNC INCREMENTAL
  Future<bool> syncHutangSupplier() async {
    try {
      final lastUpdate = await getLastUpdate();

      final response = await Network().getData_post(
        {
          'last_update': lastUpdate,
        },
        'hutangSupplierSync',
      );

      if (response.statusCode != 200) {
        print('SYNC FAILED: ${response.body}');
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
      print('SYNC ERROR: $e');
      return false;
    }
  }

  /// 🔥 SIMPAN KE SQLITE
  Future<void> _saveToLocal(Map<String, dynamic> item) async {
    try {
      final id = item['id'];

      // 🔥 HANDLE DELETE
      if (item['deleted_at'] != null) {
        await db!.delete(
          'tb_hutang_supplier',
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
        'tb_hutang_supplier',
        {
          'id': item['id'],
          'barang_masuk_id': item['barang_masuk_id'],
          'kode_hutang': item['kode_hutang'],
          'kode_supplier': item['kode_supplier'],
          'total': item['total'],
          'dibayar': item['dibayar'] ?? 0,
          'sisa': item['sisa'],
          'status': item['status'],
          'jatuh_tempo': item['jatuh_tempo'],
          'created_at': created,
          'updated_at': updated,
          'is_sync': 1,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print("ERROR SAVE HUTANG: $e");
    }
  }

  /// 🔥 FULL RESTORE (RESET + SYNC ULANG)
  Future<void> syncAll() async {
    try {
      String url = 'hutangSupplierRestore';

      final response = await Network().getData_get(url);
      final dbClient = KasirHelper.db;

      // 🔥 HAPUS SEMUA
      await dbClient!.rawDelete("DELETE FROM tb_hutang_supplier");
      await dbClient.rawDelete(
          "DELETE FROM sqlite_sequence WHERE name='tb_hutang_supplier'");

      var check = await dbClient.rawQuery("SELECT * FROM tb_hutang_supplier");
      print("Jumlah setelah delete: ${check.length}");

      if (response.statusCode == 200) {
        List listData = json.decode(response.body)['data'];
        var newLastUpdate = json.decode(response.body)['last_update'];

        for (var item in listData) {
          try {
            var createdAtMysql = item['created_at'];
            var updatedAtMysql = item['updated_at'];

            // 🔥 FORMAT TANGGAL
            var createdDate = DateTime.parse(createdAtMysql).toLocal();
            var updatedDate = DateTime.parse(updatedAtMysql).toLocal();

            var created = DateFormat('yyyy-MM-dd HH:mm:ss').format(createdDate);
            var updated = DateFormat('yyyy-MM-dd HH:mm:ss').format(updatedDate);

            await dbClient.rawInsert('''
              INSERT INTO tb_hutang_supplier
              (id, barang_masuk_id, kode_hutang, kode_supplier, total, dibayar, sisa, status, jatuh_tempo, created_at, updated_at, is_sync)
              VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', [
              item['id'],
              item['barang_masuk_id'],
              item['kode_hutang'],
              item['kode_supplier'],
              item['total'],
              item['dibayar'] ?? 0,
              item['sisa'],
              item['status'],
              item['jatuh_tempo'],
              created,
              updated,
              1
            ]);
          } catch (e) {
            print('Error proses hutang: $e');
          }
        }

        await saveLastUpdate(newLastUpdate);
      } else {
        print('API hutang gagal: ${response.body}');
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
