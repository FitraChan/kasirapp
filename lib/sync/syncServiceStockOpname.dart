import 'dart:convert';
import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kasirapp/network_utils/api.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

/// Callback for progress tracking
typedef ProgressCallback = void Function(
    String message, int current, int total);

class SyncServiceStockOpname {
  static const String _lastUpdateKey = 'last_update_stock_opname';
  KasirHelper helpers = KasirHelper();
  final db = KasirHelper.db;

  /// Ambil last_sync dari storage
  Future<String> getLastUpdate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_lastUpdateKey) ?? "1970-01-01 00:00:00";
    } catch (e) {
      print('Error getting last update: $e');
      return "1970-01-01 00:00:00";
    }
  }

  /// Simpan last_sync baru
  Future<void> saveLastUpdate(String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      DateTime dateTime = DateTime.parse(value).toLocal();
      String formatted = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
      await prefs.setString(_lastUpdateKey, formatted);
    } catch (e) {
      print('Error saving last update: $e');
    }
  }

  /// PROSES SYNC UTAMA - Download dari server
  Future<bool> syncStockOpname({ProgressCallback? onProgress}) async {
    try {
      onProgress?.call('Memulai sync stock opname...', 0, 0);

      final lastUpdate = await getLastUpdate();
      onProgress?.call('Mengambil data dari server...', 0, 0);

      final response = await Network().getData_post(
        {
          'last_update': lastUpdate,
        },
        'stockOpnameSync',
      );

      if (response.statusCode != 200) {
        print('SYNC FAILED: ${response.body}');
        onProgress?.call('Sync gagal: Server error', 0, 0);
        return false;
      }

      final result = json.decode(response.body);
      final List data = result['data'];
      final newLastUpdate = result['last_update'];

      onProgress?.call('Menyimpan ${data.length} data...', 0, data.length);

      int processed = 0;
      for (final item in data) {
        await _saveStockOpnameToLocal(item);
        processed++;
        onProgress?.call(
          'Menyimpan data $processed dari ${data.length}',
          processed,
          data.length,
        );
      }

      await saveLastUpdate(newLastUpdate);
      onProgress?.call('Sync selesai!', data.length, data.length);

      print('SYNC SUCCESS: $processed items synced');
      return true;
    } catch (e) {
      print('SYNC ERROR: $e');
      onProgress?.call('Sync error: $e', 0, 0);
      return false;
    }
  }

  /// Sync semua data (force sync)
  Future<bool> syncAll({ProgressCallback? onProgress}) async {
    try {
      onProgress?.call('Memulai full sync stock opname...', 0, 0);

      final lastUpdate = await getLastUpdate();

      final response = await Network().getData_post(
        {
          'last_update': lastUpdate,
        },
        'stockOpnameSync',
      );

      if (response.statusCode != 200) {
        print('SYNC ALL FAILED: ${response.body}');
        onProgress?.call('Full sync gagal: Server error', 0, 0);
        return false;
      }

      final result = json.decode(response.body);
      final List data = result['data'];
      final newLastUpdate = result['last_update'];

      onProgress?.call('Menyimpan ${data.length} data...', 0, data.length);

      int processed = 0;
      for (final item in data) {
        await _saveStockOpnameToLocal(item);
        processed++;
        onProgress?.call(
          'Menyimpan data $processed dari ${data.length}',
          processed,
          data.length,
        );
      }

      await saveLastUpdate(newLastUpdate);
      onProgress?.call('Full sync selesai!', data.length, data.length);

      print('SYNC ALL SUCCESS: $processed items synced');
      return true;
    } catch (e) {
      print('SYNC ALL ERROR: $e');
      onProgress?.call('Full sync error: $e', 0, 0);
      return false;
    }
  }

  /// Upload data stock opname lokal ke server
  Future<bool> syncToServer({ProgressCallback? onProgress}) async {
    try {
      onProgress?.call('Mempersiapkan upload data...', 0, 0);

      final unsyncData = await helpers.callSync('tb_stock_opname');

      if (unsyncData.isEmpty) {
        onProgress?.call('Tidak ada data untuk diupload', 0, 0);
        print('No unsynced data found');
        return true;
      }

      onProgress?.call('Mengupload ${unsyncData.length} data ke server...', 0,
          unsyncData.length);

      int successCount = 0;
      int failedCount = 0;

      for (final item in unsyncData) {
        try {
          final response = await Network().getData_post(
            {
              'id': item['id'].toString(),
              'produk_id': item['produk_id'].toString(),
              'kode_produk': item['kode_produk'] ?? '',
              'nama_produk': item['nama_produk'] ?? '',
              'stok_sistem': item['stok_sistem'].toString(),
              'stok_fisik': item['stok_fisik'].toString(),
              'selisih': item['selisih'].toString(),
              'keterangan': item['keterangan'] ?? '',
              'tanggal': item['tanggal'] ?? '',
              'created_by': item['created_by'] ?? '',
              'created_at': item['created_at'] ?? '',
            },
            'createStockOpname',
          );

          if (response.statusCode == 200) {
            await helpers.syncStockOpname(item['id']);
            successCount++;
          } else {
            failedCount++;
            print('Failed to upload item ${item['id']}: ${response.body}');
          }

          onProgress?.call(
            'Upload progress: $successCount sukses, $failedCount gagal',
            successCount + failedCount,
            unsyncData.length,
          );
        } catch (e) {
          failedCount++;
          print('Error uploading item ${item['id']}: $e');
        }
      }

      onProgress?.call(
        'Upload selesai: $successCount sukses, $failedCount gagal',
        unsyncData.length,
        unsyncData.length,
      );

      print(
          'SYNC TO SERVER SUCCESS: $successCount succeeded, $failedCount failed');
      return failedCount == 0;
    } catch (e) {
      print('SYNC TO SERVER ERROR: $e');
      onProgress?.call('Upload error: $e', 0, 0);
      return false;
    }
  }

  /// Two-way sync (download then upload)
  Future<bool> syncTwoWay({ProgressCallback? onProgress}) async {
    try {
      onProgress?.call('Memulai two-way sync...', 0, 0);

      // Step 1: Download from server
      onProgress?.call('Step 1: Download dari server...', 0, 2);
      final downloadSuccess = await syncStockOpname(
        onProgress: (msg, current, total) {
          onProgress?.call('[Download] $msg', current, total);
        },
      );

      if (!downloadSuccess) {
        onProgress?.call('Download gagal, sync dibatalkan', 0, 2);
        return false;
      }

      // Step 2: Upload to server
      onProgress?.call('Step 2: Upload ke server...', 1, 2);
      final uploadSuccess = await syncToServer(
        onProgress: (msg, current, total) {
          onProgress?.call('[Upload] $msg', current, total);
        },
      );

      if (uploadSuccess) {
        onProgress?.call('Two-way sync selesai!', 2, 2);
      } else {
        onProgress?.call('Upload gagal, tetapi download berhasil', 1, 2);
      }

      return downloadSuccess && uploadSuccess;
    } catch (e) {
      print('TWO-WAY SYNC ERROR: $e');
      onProgress?.call('Two-way sync error: $e', 0, 0);
      return false;
    }
  }

  /// Get sync statistics
  Future<Map<String, dynamic>> getSyncStats() async {
    try {
      final totalData = await helpers.countStockOpname();
      final unsyncData = await helpers.callSync('tb_stock_opname');
      final lastUpdate = await getLastUpdate();

      return {
        'total': totalData,
        'unsynced': unsyncData.length,
        'synced': totalData - unsyncData.length,
        'last_sync': lastUpdate,
      };
    } catch (e) {
      print('Error getting sync stats: $e');
      return {
        'total': 0,
        'unsynced': 0,
        'synced': 0,
        'last_sync': 'Unknown',
      };
    }
  }

  /// Check if there are unsynced data
  Future<bool> hasUnsyncedData() async {
    try {
      final unsyncData = await helpers.callSync('tb_stock_opname');
      return unsyncData.isNotEmpty;
    } catch (e) {
      print('Error checking unsynced data: $e');
      return false;
    }
  }

  /// Reset sync status (force re-sync)
  Future<void> resetSyncStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastUpdateKey);
      print('Sync status reset');
    } catch (e) {
      print('Error resetting sync status: $e');
    }
  }

  /// Clear all local data
  Future<void> clearLocalData() async {
    try {
      await helpers.clearStockOpname();
      await resetSyncStatus();
      print('Local data cleared');
    } catch (e) {
      print('Error clearing local data: $e');
    }
  }

  /// Simpan data stock opname dari server ke lokal
  Future<void> _saveStockOpnameToLocal(Map<String, dynamic> item) async {
    try {
      final id = item['id'];

      // HANDLE DELETE
      if (item['deleted_at'] != null) {
        await db!.delete(
          'tb_stock_opname',
          where: 'id = ?',
          whereArgs: [id],
        );
        return;
      }

      // FORMAT TANGGAL
      DateTime dateValue;
      try {
        dateValue =
            DateTime.parse(item['updated_at'] ?? item['created_at']).toLocal();
      } catch (e) {
        dateValue = DateTime.now();
      }

      final tanggal = DateFormat('yyyy-MM-dd HH:mm').format(dateValue);

      // UPSERT (INSERT / UPDATE)
      await db!.insert(
        'tb_stock_opname',
        {
          'id': item['id'],
          'produk_id': item['produk_id'],
          'kode_produk': item['kode_produk'],
          'nama_produk': item['nama_produk'],
          'stok_sistem': item['stok_sistem'].toString(),
          'stok_fisik': item['stok_fisik'].toString(),
          'selisih': item['selisih'].toString(),
          'keterangan': item['keterangan'],
          'tanggal': item['tanggal'],
          'created_by': item['created_by'],
          'is_sync': 1,
          'created_at': tanggal,
          'updated_at': tanggal,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error saving stock opname to local: $e');
    }
  }
}
