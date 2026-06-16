import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:kasirapp/master_data/tambahProduk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kasirapp/network_utils/api.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class SyncServiceConfig {
  static const String _lastUpdateKey = 'last_update_config';
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
  Future<bool> syncKonfigurasi() async {
    try {
      final lastUpdate = await getLastUpdate();

      final response = await Network().getData_post(
        {
          'last_update': lastUpdate,
        },
        'konfigurasiSync',
      );

      if (response.statusCode != 200) {
        print('SYNC FAILED: ${response.body}');
        return false;
      }

      final result = json.decode(response.body);
      final List data = result['data'];
      final newLastUpdate = result['last_update'];

      for (final item in data) {
        await _saveKonfigurasiToLocal(item);
      }

      await saveLastUpdate(newLastUpdate);

      return true;
    } catch (e) {
      print('SYNC ERROR: $e');
      return false;
    }
  }

  /// SIMPAN PRODUK KE SQLITE

  Future<void> _saveKonfigurasiToLocal(Map<String, dynamic> item) async {
    try {
      final id = item['id'];

      // 🔥 DELETE
      if (item['deleted_at'] != null) {
        await db!.delete(
          'konfigurasi',
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
        'konfigurasi',
        {
          'id': id,
          'nama': item['nama'],
          'kode_toko': item['kode_toko'],
          'status': item['status'],
          'created_at': tanggal,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print("ERROR SAVE KONFIG: $e");
    }
  }
}

class SyncService {
  Future<void> syncAll() async {
    try {
      String url = 'konfigurasiRestore';

      final response = await Network().getData_get(url);
      final dbClient = KasirHelper.db;

      if (response.statusCode == 200) {
        List listKonfigurasi = json.decode(response.body)['data'];

        final Set serverKode = listKonfigurasi.map((e) => e['id']).toSet();

        for (var item in listKonfigurasi) {
          try {
            var id = item['id'];
            var nama = item['nama'];
            var kodeToko = item['kode_toko'];
            var status = item['status'];
            var createdAtMysql = item['created_at'];

            // konversi tanggal MySQL → lokal
            var dateValue = DateFormat("yyyy-MM-ddTHH:mm:ssZ")
                .parseUTC(createdAtMysql)
                .subtract(const Duration(hours: 1))
                .toLocal();

            var tanggalMysql = DateFormat('yyyy-MM-dd HH:mm').format(dateValue);

            // cek data di sqlite
            final maps = await dbClient!.rawQuery(
              "SELECT * FROM konfigurasi WHERE id = ?",
              [id],
            );

            if (maps.isNotEmpty) {
              var createdAt = maps.first['created_at'];

              // update jika tanggal berbeda
              if (tanggalMysql != createdAt) {
                await dbClient.rawQuery('''
                UPDATE konfigurasi
                SET 
                  nama = ?,
                  kode_toko = ?,
                  status = ?, 
                  created_at = ?
                WHERE id = ?
              ''', [nama, kodeToko, status, id]);
              }
            } else {
              // insert data baru
              await dbClient.rawQuery('''
              INSERT INTO konfigurasi
              (id, nama, kode_toko, status,created_at)
              VALUES (?, ?, ?, ?)
            ''', [id, nama, kodeToko, status, tanggalMysql]);
            }
          } catch (e) {
            print('Error proses konfigurasi: $e');
          }
        }

        // ===============================
        // 3️⃣ DELETE DATA YANG SUDAH HILANG DI SERVER
        // ===============================
        final localList =
            await dbClient!.rawQuery("SELECT id FROM konfigurasi");

        final Set localKode = localList.map((e) => e['id']).toSet();

        final kodeHapus = localKode.difference(serverKode);

        for (final kode in kodeHapus) {
          await dbClient.rawQuery(
            "DELETE FROM konfigurasi WHERE id = ?",
            [kode],
          );
        }
      } else {
        print('API konfigurasi gagal: ${response.body}');
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
