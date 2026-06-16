import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:kasirapp/master_data/tambahProduk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kasirapp/network_utils/api.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class SyncServiceKategori {
  static const String _lastUpdateKey = 'last_update_kategori';
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
  Future<bool> syncKategori() async {
    try {
      final lastUpdate = await getLastUpdate();

      final response = await Network().getData_post(
        {
          'last_update': lastUpdate,
        },
        'kategoriSync',
      );

      if (response.statusCode != 200) {
        print('SYNC FAILED: ${response.body}');
        return false;
      }

      final result = json.decode(response.body);
      final List data = result['data'];
      final newLastUpdate = result['last_update'];

      for (final item in data) {
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
      final kode = item['kode'];

      // 🔥 HANDLE DELETE
      if (item['deleted_at'] != null) {
        await db!.delete(
          'tb_kategori',
          where: 'kode = ?',
          whereArgs: [kode],
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
        'tb_kategori',
        {
          'kode': kode,
          'nama_kategori': item['nama_kategori'],
          'created_at': tanggal,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print("ERROR SAVE KATEGORI: $e");
    }
  }

  Future<void> syncAll() async {
    try {
      String url = 'kategoriRestoreNew';

      final response = await Network().getData_get(url);
      final dbClient = KasirHelper.db;

      await dbClient!.rawDelete("DELETE FROM tb_kategori");
      await dbClient
          .rawDelete("DELETE FROM sqlite_sequence WHERE name='tb_kategori'");

      var check = await dbClient.rawQuery("SELECT * FROM tb_kategori");
      print("Jumlah setelah delete: ${check.length}");

      if (response.statusCode == 200) {
        List listKategori = json.decode(response.body)['data'];
        var newLastUpdate = json.decode(response.body)['last_update'];

        for (var item in listKategori) {
          try {
            var id = item['id'];
            var kode = item['kode'];
            var namaKategori = item['nama_kategori'];
            var createdAtMysql = item['created_at'];

            // konversi tanggal MySQL → lokal
            var dateValue = DateFormat("yyyy-MM-ddTHH:mm:ssZ")
                .parseUTC(createdAtMysql)
                .subtract(const Duration(hours: 1))
                .toLocal();

            var tanggalMysql = DateFormat('yyyy-MM-dd HH:mm').format(dateValue);

            // insert data baru
            await dbClient.rawQuery('''
              INSERT INTO tb_kategori
              (id, kode, nama_kategori, created_at, is_sync)
              VALUES (?, ?, ?, ?, ?)
            ''', [id, kode, namaKategori, tanggalMysql, 1]);
          } catch (e) {
            print('Error proses kategori: $e');
          }
        }

        await saveLastUpdate(newLastUpdate);
      } else {
        print('API kategori gagal: ${response.body}');
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
