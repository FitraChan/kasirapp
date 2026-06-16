import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:kasirapp/network_utils/api.dart';
import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';

class BarcodeScanScreen extends StatefulWidget {
  const BarcodeScanScreen({super.key});

  @override
  State<BarcodeScanScreen> createState() => _BarcodeScanScreenState();
}

class _BarcodeScanScreenState extends State<BarcodeScanScreen> {
  Barcode? _barcode;
  MobileScannerController controller = MobileScannerController(
    // Support semua format barcode: QR, EAN, UPC, Code128, Code39, dll
    detectionSpeed: DetectionSpeed.normal,
    autoStart: true,
  );

  final Map<int, TextEditingController> _controllers = {};
  bool _isScanning = true;
  String? _lastScannedBarcode;
  bool _canScan = true;
  List<Map<String, dynamic>> _scannedItems = [];

  @override
  void initState() {
    super.initState();
    initSession();
    _canScan = true;
    _loadScannedItems();
  }

  TextEditingController _getController(
    int id,
    String stok,
  ) {
    if (!_controllers.containsKey(id)) {
      _controllers[id] = TextEditingController(text: stok);
    }

    return _controllers[id]!;
  }

  Future<void> _saveManualStock(
    int id,
    String value,
    int index,
  ) async {
    try {
      // jumlah input baru
      final inputStock = int.tryParse(value) ?? 0;

      // stok lama
      final oldStock = int.tryParse(
            _scannedItems[index]['stok'].toString(),
          ) ??
          0;

      // total stok baru
      final totalStock = oldStock + inputStock;

      final now = DateTime.now().toString();

      await KasirHelper().updateProdukGudang(
        id,
        {
          'stok': totalStock.toString(),
          'updated_at': now,
          'is_sync': 0,
        },
      );

      setState(() {
        _scannedItems[index]['stok'] = totalStock.toString();

        _scannedItems[index]['updated_at'] = now;

        _scannedItems[index]['is_sync'] = 0;

        // reset input setelah save
        _controllers[id]?.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Stok berhasil ditambah +$inputStock',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> exportToCsv() async {
    try {
      final filteredItems = _scannedItems.where((item) {
        final stok = int.tryParse(item['stok'].toString()) ?? 0;
        return stok > 0;
      }).toList();

      List<List<dynamic>> rows = [];

      // Header

      // Data
      for (final item in filteredItems) {
        rows.add([
          item['kode_item']?.toString() ?? '',
          item['barcode_item']?.toString() ?? '',
          item['nama_item']?.toString() ?? '',
          item['stok']?.toString() ?? '0',
        ]);
      }

      String csvData = const ListToCsvConverter().convert(rows);

      final dir = await getApplicationDocumentsDirectory();

      final fileName =
          'stok_opname_${DateTime.now().millisecondsSinceEpoch}.csv';

      final file = File('${dir.path}/$fileName');

      await file.writeAsString(csvData);

      EasyLoading.showSuccess(
        '${filteredItems.length} item berhasil diexport',
      );

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Laporan Stok Opname CSV',
      );
    } catch (e) {
      EasyLoading.showError(e.toString());
    }
  }

  Future<void> exportToExcel() async {
    try {
      var excel = Excel.createExcel();

      // Ambil nama sheet default
      final defaultSheet = excel.getDefaultSheet();

      // Buat sheet yang akan digunakan
      Sheet sheet = excel['Stok Opname'];

      // Hapus sheet default agar tidak ada Sheet1 kosong
      if (defaultSheet != null && defaultSheet != 'Stok Opname') {
        excel.delete(defaultSheet);
      }

      // Header

      // Filter stok > 0
      final filteredItems = _scannedItems.where((item) {
        final stok = int.tryParse(item['stok'].toString()) ?? 0;
        return stok > 0;
      }).toList();

      // Data
      for (final item in filteredItems) {
        sheet.appendRow([
          TextCellValue(item['kode_item']?.toString() ?? ''),
          TextCellValue(item['barcode_item']?.toString() ?? ''),
          TextCellValue(item['nama_item']?.toString() ?? ''),
          IntCellValue(
            int.tryParse(item['stok'].toString()) ?? 0,
          ),
        ]);
      }

      final bytes = excel.encode();

      if (bytes == null) {
        EasyLoading.showError('Gagal membuat file Excel');
        return;
      }

      final dir = await getApplicationDocumentsDirectory();

      final fileName =
          'stok_opname_${DateTime.now().millisecondsSinceEpoch}.xlsx';

      final file = File('${dir.path}/$fileName');

      await file.writeAsBytes(bytes, flush: true);

      EasyLoading.showSuccess(
        '${filteredItems.length} item berhasil diexport',
      );

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Laporan Stok Opname',
      );
    } catch (e) {
      EasyLoading.showError(e.toString());
    }
  }

  Future<void> _loadScannedItems() async {
    final items = await KasirHelper().getAllProdukGudang();
    // Ensure we store a mutable copy — some DB helpers return read-only lists/maps.
    final mutableItems = List<Map<String, dynamic>>.from(items);
    if (mounted) {
      setState(() {
        _scannedItems = mutableItems;
      });
    }
  }

  // Convert barcode result to string
  String? getBarcodeString() {
    return _barcode?.displayValue;
  }

  var idUser;
  Future<void> initSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? sessionId = prefs.getInt('session_id');

    var user = jsonDecode(prefs.getString('user') ?? '');
    setState(() {
      idUser = user['id'] as int?;
    });

    if (sessionId == null) {
      // belum ada → buat baru
      await getSession();
    } else {
      print("Pakai session lama: $sessionId");
    }
  }

  getSession() async {
    final response = await Network().getData_get('sessionStokOpname');
    var body = json.decode(response.body);

    if (response.statusCode == 200) {
      int sessionId = body['session'] as int;

      // 🔥 simpan ke local
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('session_id', sessionId);

      print("Session ID disimpan: $sessionId");
    } else {
      throw Exception('Failed to load session');
    }
  }

  Future<int?> getSessionId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getInt('session_id');
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (mounted && _isScanning && _canScan) {
      final List<Barcode> barcodes = capture.barcodes;
      if (barcodes.isNotEmpty) {
        final barcode = barcodes.first;
        final barcodeValue = barcode.displayValue;

        // Prevent scanning the same barcode repeatedly
        if (barcodeValue == null || barcodeValue.isEmpty) {
          return;
        }

        if (_lastScannedBarcode == barcodeValue) {
          return;
        }

        setState(() {
          _barcode = barcode;
          _lastScannedBarcode = barcodeValue;
          _canScan = false; // Temporarily disable scanning
        });

        // Save to Sqflite first
        _saveToSqflite(barcodeValue);

        // Show success feedback
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Barcode scanned successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
        }

        // Re-enable scanning after 1 second
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) {
            setState(() {
              _canScan = true;
              _lastScannedBarcode = null;
            });
          }
        });
      }
    }
  }

  void _saveToSqflite(String barcodeValue) async {
    try {
      final now = DateTime.now().toString();

      final existingItem = await KasirHelper().getProdukByBarcode(barcodeValue);

      if (existingItem != null) {
        final currentStock = int.tryParse(existingItem['stok'].toString()) ?? 0;

        final newStock = currentStock + 1;

        await KasirHelper().updateProdukGudang(
          existingItem['id'],
          {
            'stok': newStock.toString(),
            'waktu_scan': now,
            'updated_at': now,
            'is_sync': 0,
          },
        );

        if (mounted) {
          setState(() {
            final index = _scannedItems.indexWhere(
              (item) => item['id'] == existingItem['id'],
            );

            if (index != -1) {
              final updatedItem =
                  Map<String, dynamic>.from(_scannedItems[index]);

              updatedItem['stok'] = newStock.toString();
              updatedItem['waktu_scan'] = now;
              updatedItem['updated_at'] = now;
              updatedItem['is_sync'] = 0;

              _scannedItems[index] = updatedItem;

              final movedItem = _scannedItems.removeAt(index);
              _scannedItems.insert(0, movedItem);
            }
          });
        }
      } else {
        // INSERT DATA BARU
        final id = await KasirHelper().insertProdukGudang({
          'kode_item': barcodeValue,
          'kode_barcode': barcodeValue,
          'nama_item': '',
          'stok': '1',
          'waktu_scan': now,
          'created_at': now,
          'updated_at': now,
          'is_sync': 0,
        });

        if (mounted) {
          setState(() {
            _scannedItems.insert(0, {
              'id': id,
              'kode_item': barcodeValue,
              'kode_barcode': barcodeValue,
              'nama_item': '',
              'stok': '1',
              'waktu_scan': now,
              'created_at': now,
              'updated_at': now,
              'is_sync': 0,
            });
          });
        }
      }
    } catch (e) {
      print('Error saving to Sqflite: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _syncToMySQL() async {
    try {
      EasyLoading.show(status: 'Syncing...');

      final unsyncItems = await KasirHelper().getUnsyncProdukGudang();

      if (unsyncItems.isEmpty) {
        EasyLoading.showSuccess('No data');
        return;
      }

      final sessionId = await getSessionId();

      const chunkSize = 500;
      int successCount = 0;

      for (int i = 0; i < unsyncItems.length; i += chunkSize) {
        final chunk = unsyncItems.skip(i).take(chunkSize).toList();

        final payload = {
          "session_id": sessionId,
          "user_id": idUser,
          "data": chunk.map((item) {
            return {
              "kode_item": item['kode_item'],
              "stok": item['stok'],
            };
          }).toList()
        };

        final response =
            await Network().getData_post(payload, 'simpanProdukGudang');

        if (response.statusCode == 200) {
          // tandai chunk ini sudah sync
          // for (var item in chunk) {
          //   await KasirHelper().syncProdukGudang(item['id']);
          // }

          successCount += chunk.length;
        } else {
          print('Failed to sync chunk starting at index $i: ${response.body}');
          EasyLoading.showError('Gagal di chunk ke-${i ~/ chunkSize}');
          break;
        }
      }

      EasyLoading.showSuccess('$successCount data berhasil di-sync!');
      await _loadScannedItems();
    } catch (e) {
      EasyLoading.showError('Error: $e');
    }
  }

  void sendToMysql(barcode) async {
    // This method is now deprecated in favor of _syncToMySQL
    // Kept for backward compatibility if needed
  }

  Future<void> _deleteItem(int id) async {
    try {
      await KasirHelper().deleteProdukGudang(id);
      await _loadScannedItems();
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

  Future<void> _editItem(
      int id, String kodeItem, String namaItem, String stok) async {
    final kodeItemController = TextEditingController(text: kodeItem);
    final namaItemController = TextEditingController(text: namaItem);
    final stokController = TextEditingController(text: stok);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: kodeItemController,
                decoration: const InputDecoration(
                  labelText: 'Kode Item',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: namaItemController,
                decoration: const InputDecoration(
                  labelText: 'Nama Item',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: stokController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stok',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final now = DateTime.now().toString();
                await KasirHelper().updateProdukGudang(id, {
                  'kode_item': kodeItemController.text,
                  'kode_barcode': kodeItemController.text,
                  'nama_item': namaItemController.text,
                  'stok': stokController.text,
                  'updated_at': now,
                  'is_sync': 0,
                });
                await _loadScannedItems();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Item updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error updating: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllItems() async {
    try {
      await KasirHelper().clearAllProdukGudang();
      await _loadScannedItems();
      EasyLoading.showSuccess('All items cleared!');
    } catch (e) {
      EasyLoading.showError('Error clearing: $e');
    }
  }

  void _toggleTorch() {
    setState(() {
      controller.toggleTorch();
    });
  }

  void _switchCamera() {
    setState(() {
      controller.switchCamera();
    });
  }

  void _startScanning() {
    setState(() {
      _isScanning = true;
      _barcode = null;
      _lastScannedBarcode = null;
      _canScan = true;
    });
    controller.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.switch_camera),
            onPressed: _switchCamera,
            tooltip: 'Switch Camera',
          ),
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: _toggleTorch,
            tooltip: 'Toggle Flash',
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
            // Action buttons row
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _syncToMySQL,
                      icon: const Icon(Icons.save),
                      label: const Text('To Server'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: exportToExcel,
                      icon: const Icon(Icons.file_download),
                      label: const Text('Excel'),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: exportToCsv,
                      icon: const Icon(Icons.file_download),
                      label: const Text('Csv'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.delete_sweep),
                    onPressed: _clearAllItems,
                    color: Colors.red,
                    tooltip: 'Clear All',
                  ),
                ],
              ),
            ),
            // Camera preview
            Container(
              height: 250,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: MobileScanner(
                  controller: controller,
                  onDetect: _handleBarcode,
                ),
              ),
            ),
            // Scanned items count
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
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
                      'Scanned: ${_scannedItems.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Unsynced: ${_scannedItems.where((item) => item['is_sync'] == 0).length}',
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
            // Scanned items list
            Expanded(
                child: _scannedItems.isEmpty
                    ? const Center(
                        child: Text(
                          'No scanned items yet.\nStart scanning!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        itemCount: _scannedItems.length,
                        itemBuilder: (context, index) {
                          final item = _scannedItems[index];

                          final isSynced = item['is_sync'].toString() == '1';

                          final controller = _getController(
                            item['id'],
                            item['stok'].toString(),
                          );

                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        isSynced
                                            ? Icons.check_circle
                                            : Icons.pending,
                                        color: isSynced
                                            ? Colors.green
                                            : Colors.orange,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${item['kode_item'] ?? 'N/A'}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              'Nama: ${item['nama_item'] ?? '-'}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              'Stok: ${item['stok'] ?? '0'}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Colors.blue,
                                            ),
                                            onPressed: () => _editItem(
                                              item['id'],
                                              item['kode_item']?.toString() ??
                                                  '',
                                              item['nama_item']?.toString() ??
                                                  '-',
                                              item['stok']?.toString() ?? '0',
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed: () => _deleteItem(
                                              item['id'],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 10),

                                  // INPUT STOK
                                  TextField(
                                    controller: controller,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Input Jumlah Stok',
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  // BUTTON SAVE
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _saveManualStock(
                                          item['id'],
                                          controller.text,
                                          index,
                                        );
                                      },
                                      child: const Text(
                                        'SAVE',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        })),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();

    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
