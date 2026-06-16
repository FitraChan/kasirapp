import 'dart:convert';
import 'dart:io';
import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kasirapp/network_utils/api.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class SyncServicePkAc {
  static const String _lastUpdateKey = 'last_update_pk_ac';
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
  Future<bool> syncPkAc() async {
    try {
      final lastUpdate = await getLastUpdate();

      final response = await Network().getData_post(
        {
          'last_update': lastUpdate,
        },
        'pkAcSync',
      );

      if (response.statusCode != 200) {
        print('SYNC FAILED: ${response.body}');
        return false;
      }

      final result = json.decode(response.body);
      final List data = result['data'];
      final newLastUpdate = result['last_update'];

      for (final item in data) {
        await _savePkAcToLocal(item);
      }

      await saveLastUpdate(newLastUpdate);

      return true;
    } catch (e) {
      print('SYNC ERROR: $e');
      return false;
    }
  }

  /// SIMPAN PRODUK KE SQLITE
  Future<void> _savePkAcToLocal(Map<String, dynamic> item) async {
    try {
      final id = item['id'];

      // 🔥 HANDLE DELETE
      if (item['deleted_at'] != null) {
        await db!.delete(
          'tb_pk_ac',
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

      final tanggal = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateValue);

      // 🔥 UPSERT (INSERT / UPDATE)
      await db!.insert(
        'tb_pk_ac',
        {
          'id': id,
          'nama': item['nama'],
          'created_at': tanggal,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print("ERROR SAVE PK_AC: $e");
    }
  }

  Future<void> syncAll() async {
    try {
      String url = 'pkAcRestoreNew';

      final response = await Network().getData_get(url);
      final dbClient = KasirHelper.db;

      await dbClient!.rawDelete("DELETE FROM tb_pk_ac");
      await dbClient
          .rawDelete("DELETE FROM sqlite_sequence WHERE name='tb_pk_ac'");

      if (response.statusCode == 200) {
        List listpkAc = json.decode(response.body)['data'];
        var newLastUpdate = json.decode(response.body)['last_update'];

        for (var item in listpkAc) {
          try {
            var id = item['id'];
            var nama = item['nama'];

            // konversi tanggal MySQL → lokal
            // var dateValue = DateFormat("yyyy-MM-dd HH:mm:ss")
            //     .parse(createdAtMysql)
            //     .subtract(const Duration(hours: 1));

            // var tanggalMysql = DateFormat('yyyy-MM-dd HH:mm').format(dateValue);

            // cek data di sqlite

            // insert data baru
            await dbClient.rawQuery('''
              INSERT INTO tb_pk_ac
              (id, nama)
              VALUES (?, ?)
            ''', [id, nama]);
          } catch (e) {
            print('Error proses pkAc: $e');
          }

          await saveLastUpdate(newLastUpdate);
        }

        // ===============================
        // 3️⃣ DELETE DATA YANG SUDAH HILANG DI SERVER
        // ===============================
      } else {
        print('API pkAc gagal: ${response.body}');
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

class SyncService {}
