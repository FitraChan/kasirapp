import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class CsvImportScreen extends StatefulWidget {
  const CsvImportScreen({super.key});

  @override
  State<CsvImportScreen> createState() => _CsvImportScreenState();
}

class _CsvImportScreenState extends State<CsvImportScreen> {
  List<Map<String, dynamic>> _importedItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadImportedItems();
  }

  Future<void> _loadImportedItems() async {
    setState(() {
      _isLoading = true;
    });

    final items = await KasirHelper().getProdukGudang();
    // Ensure mutable deep copy of maps
    final mutableItems =
        items.map((m) => Map<String, dynamic>.from(m)).toList();
    setState(() {
      _importedItems = mutableItems;
      _isLoading = false;
    });
  }

  Future<void> importExcel() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result == null) {
        return;
      }

      EasyLoading.show(status: 'Importing Excel...');

      final file = File(result.files.single.path!);

      final bytes = file.readAsBytesSync();

      final excel = Excel.decodeBytes(bytes);

      if (excel.tables.isEmpty) {
        EasyLoading.showError('Sheet tidak ditemukan');
        return;
      }

      final sheetName = excel.tables.keys.first;

      final Sheet sheet = excel.tables[sheetName]!;

      int importedCount = 0;
      int skippedCount = 0;

      final now = DateTime.now().toString();

      print('Sheet: $sheetName');
      print('Total Rows: ${sheet.rows.length}');

      for (int i = 4; i < sheet.rows.length; i++) {
        final row = sheet.rows[i];

        if (row.isEmpty) {
          skippedCount++;
          continue;
        }

        // Skip baris kosong
        if (row.every((cell) =>
            cell == null ||
            cell.value == null ||
            cell.value.toString().trim().isEmpty)) {
          skippedCount++;
          continue;
        }

        // Skip header
        if (i == 0) {
          final firstCell = row[0]?.value.toString().toLowerCase().trim() ?? '';

          if (firstCell.contains('kode') ||
              firstCell.contains('barcode') ||
              firstCell.contains('nama')) {
            print('Header ditemukan, dilewati');
            skippedCount++;
            continue;
          }
        }

        String kodeItem =
            row.length > 1 ? row[1]?.value.toString().trim() ?? '' : '';

        String kodeBarcode =
            row.length > 2 ? row[2]?.value.toString().trim() ?? '' : '';

        String namaItem =
            row.length > 3 ? row[3]?.value.toString().trim() ?? '' : '';

        String stok =
            row.length > 4 ? row[4]?.value.toString().trim() ?? '0' : '0';

        String tanggal =
            row.length > 5 ? row[5]?.value.toString().trim() ?? '' : '';

        if (kodeItem.isEmpty) {
          skippedCount++;
          continue;
        }

        if (kodeBarcode.isEmpty) {
          kodeBarcode = kodeItem;
        }

        final data = {
          'kode_item': kodeItem,
          'kode_barcode': kodeBarcode,
          'nama_item': namaItem,
          'stok': stok.isEmpty ? '0' : stok,
          'waktu_scan': tanggal,
          'created_at': tanggal,
          'updated_at': now,
          'is_sync': 0,
        };

        try {
          await KasirHelper().createProdukGudang(data);

          importedCount++;

          print(
            'Imported: $kodeItem | $kodeBarcode | $namaItem | $stok',
          );
        } catch (e) {
          print('Error row $i: $e');
          skippedCount++;
        }
      }

      await _loadImportedItems();

      EasyLoading.dismiss();

      if (importedCount > 0) {
        EasyLoading.showSuccess(
          '$importedCount item berhasil diimport\n$skippedCount dilewati',
        );
      } else {
        EasyLoading.showError('Tidak ada data yang berhasil diimport');
      }
    } catch (e) {
      print('Import Excel Error: $e');

      EasyLoading.dismiss();

      EasyLoading.showError(
        'Gagal import Excel\n$e',
      );
    }
  }

  // Future<void> _importCsv() async {
  //   try {
  //     FilePickerResult? result = await FilePicker.platform.pickFiles(
  //       type: FileType.custom,
  //       allowedExtensions: ['csv'],
  //     );

  //     if (result != null) {
  //       EasyLoading.show(status: 'Importing CSV...');

  //       final file = File(result.files.single.path!);
  //       final csvString = await file.readAsString();

  //       // Debug: check file content
  //       print('=== CSV DEBUG INFO ===');
  //       print('File size: ${csvString.length} characters');
  //       print(
  //           'First 500 chars: ${csvString.substring(0, csvString.length > 500 ? 500 : csvString.length)}');
  //       print('Contains newlines (\\n): ${csvString.contains('\n')}');
  //       print('Contains \\r\\n: ${csvString.contains('\r\n')}');
  //       print('Line count (manual split): ${csvString.split('\n').length}');
  //       print('=======================');

  //       // Try manual split first to verify
  //       final manualLines = csvString
  //           .split('\n')
  //           .where((line) => line.trim().isNotEmpty)
  //           .toList();
  //       print('Manual line count (non-empty): ${manualLines.length}');
  //       if (manualLines.isNotEmpty) {
  //         print('First manual line: ${manualLines[0]}');
  //       }
  //       if (manualLines.length > 1) {
  //         print('Second manual line: ${manualLines[1]}');
  //       }

  //       // Parse with CsvToListConverter
  //       final csvConverter = const CsvToListConverter(
  //         fieldDelimiter: ',',
  //         shouldParseNumbers: false,
  //       );
  //       final List<List<dynamic>> csvData = csvConverter.convert(csvString);

  //       if (csvData.isEmpty) {
  //         EasyLoading.showError('CSV file is empty');
  //         return;
  //       }

  //       print('CSV Total rows from parser: ${csvData.length}');
  //       if (csvData.isNotEmpty) {
  //         print('First row parsed: ${csvData[0]}');
  //       }
  //       if (csvData.length > 1) {
  //         print('Second row parsed: ${csvData[1]}');
  //       }

  //       // If CSV parser only found 1 row but file has many lines, use manual parsing
  //       if (csvData.length == 1 && manualLines.length > 1) {
  //         print(
  //             '⚠️ CSV parser found only 1 row, switching to manual parsing...');
  //       }

  //       int importedCount = 0;
  //       int skippedCount = 0;
  //       final now = DateTime.now().toString();

  //       // Use manualLines if CSV parser failed
  //       List<List<dynamic>> dataToProcess;
  //       if (csvData.length == 1 && manualLines.length > 1) {
  //         // Manual parsing fallback
  //         dataToProcess = manualLines.map((line) {
  //           return line.split(',').map((e) => e.trim()).toList();
  //         }).toList();
  //         print('Using manual parsing: ${dataToProcess.length} rows');
  //       } else {
  //         dataToProcess = csvData;
  //       }

  //       print('Processing ${dataToProcess.length} rows...');

  //       for (int i = 0; i < dataToProcess.length; i++) {
  //         final row = dataToProcess[i];

  //         // Skip empty rows
  //         if (row.isEmpty ||
  //             row.every((cell) => cell.toString().trim().isEmpty)) {
  //           skippedCount++;
  //           continue;
  //         }

  //         String? kodeItem, kodeBarcode, namaItem, stok;

  //         // Parse CSV columns based on your actual format: kode_item,,nama_item
  //         // Column 0: kode_item (ID)
  //         // Column 1: (empty - was for barcode)
  //         // Column 2: nama_item (product name)
  //         if (row.length > 0) kodeItem = row[0].toString().trim();
  //         if (row.length > 1) kodeBarcode = row[1].toString().trim();
  //         if (row.length > 2) namaItem = row[2].toString().trim();
  //         if (row.length > 3) stok = row[3].toString().trim();

  //         // Skip header row detection (if first row contains text like "kode", "nama", etc)
  //         if (i == 0) {
  //           if (kodeItem != null &&
  //               (kodeItem.toLowerCase().contains('kode') ||
  //                   kodeItem.toLowerCase().contains('id') ||
  //                   kodeItem.toLowerCase().contains('no') ||
  //                   kodeItem.toLowerCase().contains('nama'))) {
  //             print('Skipping header row');
  //             skippedCount++;
  //             continue;
  //           }
  //         }

  //         // Skip if kode_item is empty
  //         if (kodeItem == null || kodeItem.isEmpty) {
  //           skippedCount++;
  //           print('Skipped row $i: empty kode_item');
  //           continue;
  //         }

  //         // If kode_barcode is empty, use kode_item as barcode
  //         String finalKodeBarcode;
  //         if (kodeBarcode == null || kodeBarcode.isEmpty) {
  //           finalKodeBarcode = kodeItem;
  //         } else {
  //           finalKodeBarcode = kodeBarcode;
  //         }

  //         // Import ALL items - no duplicate checking
  //         final data = {
  //           'kode_item': kodeItem,
  //           'kode_barcode': finalKodeBarcode,
  //           'nama_item': namaItem ?? '-',
  //           'stok': (stok ?? '0').isEmpty ? '0' : stok,
  //           'waktu_scan': now,
  //           'created_at': now,
  //           'updated_at': now,
  //           'is_sync': 0,
  //         };

  //         try {
  //           await KasirHelper().createProdukGudang(data);
  //           importedCount++;
  //           print(
  //               'Imported #$importedCount: kode_item=$kodeItem, barcode=$finalKodeBarcode, nama=$namaItem');
  //           // Print first few items for debugging
  //           if (importedCount <= 5) {}
  //         } catch (e) {
  //           print('Error inserting row $i: $e');
  //           skippedCount++;
  //         }
  //       }

  //       await _loadImportedItems();

  //       if (importedCount > 0) {
  //         EasyLoading.showSuccess(
  //             '$importedCount item(s) imported, $skippedCount skipped');
  //       } else {
  //         EasyLoading.showError('No items imported. Check CSV format.');
  //       }
  //     }
  //   } catch (e) {
  //     print('CSV Import Error: $e');
  //     EasyLoading.showError('Error importing CSV: $e');
  //   }
  // }

  Future<void> _syncToMySQL() async {
    try {
      EasyLoading.show(status: 'Syncing to MySQL...');

      final unsyncItems = await KasirHelper().getUnsyncProdukGudang();

      if (unsyncItems.isEmpty) {
        EasyLoading.showSuccess('No items to sync!');
        return;
      }

      // TODO: Add your MySQL sync logic here
      // For now, just mark all as synced
      int successCount = 0;
      for (var item in unsyncItems) {
        try {
          await KasirHelper().syncProdukGudang(item['id']);
          successCount++;
        } catch (e) {
          print('Error syncing item ${item['id']}: $e');
        }
      }

      if (successCount > 0) {
        EasyLoading.showSuccess('$successCount item(s) synced to MySQL!');
        await _loadImportedItems();
      } else {
        EasyLoading.showError('Failed to sync items');
      }
    } catch (e) {
      EasyLoading.showError('Error: $e');
    }
  }

  // Future<void> _clearAllItems() async {
  //   try {
  //     bool confirm = await showDialog<bool>(
  //           context: context,
  //           builder: (context) => AlertDialog(
  //             title: const Text('Confirm'),
  //             content: const Text(
  //                 'Are you sure you want to clear all items?\nThis cannot be undone!'),
  //             actions: [
  //               TextButton(
  //                 onPressed: () => Navigator.pop(context, false),
  //                 child: const Text('Cancel'),
  //               ),
  //               TextButton(
  //                 onPressed: () => Navigator.pop(context, true),
  //                 child:
  //                     const Text('Clear', style: TextStyle(color: Colors.red)),
  //               ),
  //             ],
  //           ),
  //         ) ??
  //         false;

  //     if (confirm) {
  //       EasyLoading.show(status: 'Clearing...');
  //       await KasirHelper().clearAllProdukGudang();
  //       await _loadImportedItems();
  //       EasyLoading.showSuccess('All items cleared!');
  //     }
  //   } catch (e) {
  //     EasyLoading.showError('Error clearing: $e');
  //   }
  // }

  Future<void> _importAndReplace() async {
    try {
      bool confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Import & Replace'),
              content: const Text(
                  'This will clear all existing data before importing. Continue?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Continue',
                      style: TextStyle(color: Colors.orange)),
                ),
              ],
            ),
          ) ??
          false;

      if (confirm) {
        // Clear existing data first
        EasyLoading.show(status: 'Clearing old data...');
        await KasirHelper().clearAllProdukGudang();
        await _loadImportedItems();

        // Then import
        //await _importCsv();

        await importExcel();
      }
    } catch (e) {
      EasyLoading.showError('Error: $e');
    }
  }

  Future<void> _deleteItem(int id) async {
    try {
      await KasirHelper().deleteProdukGudang(id);
      await _loadImportedItems();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CSV Import'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadImportedItems,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffFF5F6D), Color(0xffFFC371)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Action buttons
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: importExcel,
                          icon: const Icon(Icons.file_upload),
                          label: const Text('Import CSV'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _importAndReplace,
                          icon: const Icon(Icons.swap_horiz),
                          label: const Text('Import & Replace'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _syncToMySQL,
                          icon: const Icon(Icons.save),
                          label: const Text('Sync MySQL'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      // const SizedBox(width: 10),
                      // IconButton(
                      //   icon: const Icon(Icons.delete_sweep),
                      //   onPressed: _clearAllItems,
                      //   color: Colors.red,
                      //   tooltip: 'Clear All',
                      //   iconSize: 30,
                      // ),
                    ],
                  ),
                ],
              ),
            ),
            // Statistics
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Items: ${_importedItems.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Unsynced: ${_importedItems.where((item) => item['is_sync'].toString() == '0').length}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // CSV Format Info
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                  // border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Format: kode_item, kode_barcode, nama_item, stok',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Items list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _importedItems.isEmpty
                      ? const Center(
                          child: Text(
                            'No imported items yet.\nClick "Import CSV" to start!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(10),
                          itemCount: _importedItems.length,
                          itemBuilder: (context, index) {
                            final item = _importedItems[index];
                            final isSynced = item['is_sync'].toString() == '1';
                            return Card(
                              child: ListTile(
                                leading: Icon(
                                  isSynced ? Icons.check_circle : Icons.pending,
                                  color:
                                      isSynced ? Colors.green : Colors.orange,
                                ),
                                title: Text(
                                  item['nama_item'] ?? 'Unknown',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('ID: ${item['kode_item'] ?? 'N/A'}'),
                                    Text(
                                        'Barcode: ${item['kode_barcode'] ?? 'N/A'}'),
                                    Text(
                                        'Scanned: ${item['waktu_scan'] ?? 'N/A'}'),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Stok: ${item['stok'] ?? '0'}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () => _deleteItem(item['id']),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
