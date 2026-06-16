import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:kasirapp/master_data/tambahProduk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kasirapp/network_utils/api.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

class SyncServiceSupplier {
  static const String _lastUpdateKey = 'last_update_supplier';
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
  Future<bool> syncSupplier() async {
    try {
      final lastUpdate = await getLastUpdate();
      final response = await Network().getData_post(
        {
          'last_update': lastUpdate,
        },
        'supplierSync',
      );

      if (response.statusCode != 200) {
        print('SYNC FAILED: ${response.body}');
        return false;
      }

      final result = json.decode(response.body);
      final List data = result['data'];
      final newLastUpdate = result['last_update'];

      for (final item in data) {
        await _saveSupplierToLocal(item);
      }

      await saveLastUpdate(newLastUpdate);

      return true;
    } catch (e) {
      print('SYNC ERROR: $e');
      return false;
    }
  }

  Future<void> _saveSupplierToLocal(Map<String, dynamic> item) async {
    try {
      final kode = item['kode_supplier'];

      // 🔥 HANDLE DELETE
      if (item['deleted_at'] != null) {
        await db!.delete(
          'supplier',
          where: 'kode_supplier = ?',
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
        'supplier',
        {
          'kode_supplier': kode,
          'nama': item['nama'],
          'created_at': tanggal,
          'is_sync': 1,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print("ERROR SAVE SUPPLIER: $e");
    }
  }

  syncAll() async {
    final dbClient = KasirHelper.db;
    String url = 'supplierRestoreNew';

    try {
      final response =
          await Network().getData_get(url).timeout(Duration(seconds: 15));

      if (response.statusCode != 200) {
        print('Error: ${response.body}');
        return;
      }

      // Decode JSON di luar setState
      List data = json.decode(response.body)['data'];

      var newLastUpdate = json.decode(response.body)['last_update'];

      // Hapus semua produk lama
      await dbClient!.execute("DELETE FROM supplier");
      await dbClient
          .execute("DELETE FROM sqlite_sequence WHERE name='supplier'");

      // Siapkan batch insert
      Batch batch = dbClient.batch();

      for (var item in data) {
        String nama = item['nama'];
        String kodeSupplier = item['kode_supplier'];

        String noHp = item['no_hp'].toString();
        String alamat = item['alamat'];

        // Konversi tanggal

        // Ambil gambar jika ada

        // Tambahkan ke batch
        batch.insert('supplier', {
          'kode_supplier': kodeSupplier,
          'nama': nama,
          'no_hp': noHp,
          'alamat': alamat,
        });
      }
      await saveLastUpdate(newLastUpdate);

      // Eksekusi batch sekaligus
      await batch.commit(noResult: true);

      // Navigasi ke halaman produk setelah selesai
    } on TimeoutException {
      print('Timeout: Tidak bisa terhubung ke server.');
    } on SocketException {
      print('Koneksi internet bermasalah.');
    } catch (e) {
      print('Terjadi error: $e');
    } finally {}
  }
}

class SyncService {
  Future<void> syncAll() async {
    try {
      String url = 'supplierRestore';

      final response = await Network().getData_get(url);
      final dbClient = KasirHelper.db;

      if (response.statusCode == 200) {
        List listSupplier = json.decode(response.body);

        final Set serverKode =
            listSupplier.map((e) => e['kode_supplier']).toSet();

        for (var item in listSupplier) {
          try {
            var id = item['id'];
            var kode = item['kode_supplier'];
            var namaSupplier = item['nama'];
            var createdAtMysql = item['created_at'];

            // konversi tanggal MySQL → lokal
            var dateValue = DateFormat("yyyy-MM-ddTHH:mm:ssZ")
                .parseUTC(createdAtMysql)
                .subtract(const Duration(hours: 1))
                .toLocal();

            var tanggalMysql = DateFormat('yyyy-MM-dd HH:mm').format(dateValue);

            // cek data di sqlite
            final maps = await dbClient!.rawQuery(
              "SELECT * FROM supplier WHERE kode_supplier = ?",
              [kode],
            );

            if (maps.isNotEmpty) {
              var createdAt = maps.first['created_at'];

              // update jika tanggal berbeda
              if (tanggalMysql != createdAt) {
                await dbClient.rawQuery('''
                UPDATE supplier
                SET 
                  nama = ?, 
                  created_at = ?
                WHERE kode_supplier = ?
              ''', [namaSupplier, tanggalMysql, kode]);
              }
            } else {
              // insert data baru
              await dbClient.rawQuery('''
              INSERT INTO supplier
              (id, kode_supplier, nama, created_at,is_sync)
              VALUES (?, ?, ?, ?, ?)
            ''', [id, kode, namaSupplier, tanggalMysql, 1]);
            }
          } catch (e) {
            print('Error proses kategori: $e');
          }
        }

        // ===============================
        // 3️⃣ DELETE DATA YANG SUDAH HILANG DI SERVER
        // ===============================
        final localList =
            await dbClient!.rawQuery("SELECT kode_supplier FROM supplier");

        final Set localKode = localList.map((e) => e['kode_supplier']).toSet();

        final kodeHapus = localKode.difference(serverKode);

        for (final kode in kodeHapus) {
          await dbClient.rawQuery(
            "DELETE FROM supplier WHERE kode_supplier = ?",
            [kode],
          );
        }
      } else {
        print('API supplier gagal: ${response.body}');
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
