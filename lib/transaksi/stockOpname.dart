import 'package:flutter/material.dart';
import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:kasirapp/screen/home.dart';
import 'package:kasirapp/sync/stockOpnameSyncHelper.dart';
import 'package:kasirapp/sync/syncServiceStockOpname.dart';
import 'package:kasirapp/transaksi/tambahStockOpname.dart';

class StockOpname extends StatefulWidget {
  const StockOpname({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _StockOpnameState createState() => _StockOpnameState();
}

class _StockOpnameState extends State<StockOpname> {
  KasirHelper? helper;
  bool _isLoading = true;
  bool _isSyncing = false;
  var allStockOpname = [];
  var items = [];
  Map<String, dynamic>? _syncStats;

  final syncServiceStockOpname = SyncServiceStockOpname();

  @override
  void initState() {
    super.initState();
    helper = KasirHelper();
    _refreshStockOpname();
    _initData();
    _loadSyncStats();
  }

  Future<void> _initData() async {
    final count = await helper!.countStockOpname();
    if (count == 0) {
      setState(() {
        _isSyncing = true;
      });

      final success = await syncServiceStockOpname.syncAll(
        onProgress: (message, current, total) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                duration: const Duration(seconds: 1),
                backgroundColor: Colors.blue[700],
              ),
            );
          }
        },
      );

      setState(() {
        _isSyncing = false;
      });

      if (success) {
        _refreshStockOpname();
        _loadSyncStats();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sync awal berhasil'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  Future<void> _loadSyncStats() async {
    final stats = await syncServiceStockOpname.getSyncStats();
    if (mounted) {
      setState(() {
        _syncStats = stats;
      });
    }
  }

  Future<void> _syncData() async {
    if (_isSyncing) return;

    setState(() {
      _isSyncing = true;
    });

    final success = await StockOpnameSyncHelper.syncWithFeedback(
      context,
      showSnackBar: false,
      showLoadingDialog: true,
    );

    setState(() {
      _isSyncing = false;
    });

    if (success) {
      _refreshStockOpname();
      _loadSyncStats();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sync berhasil'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _showSyncStatsDialog() async {
    await StockOpnameSyncHelper.showSyncStats(context);
    _loadSyncStats();
  }

  void _refreshStockOpname() {
    if (helper != null) {
      helper!.allStockOpname().then((data) {
        setState(() {
          allStockOpname = data;
          items = allStockOpname;
          _isLoading = false;
        });
      });
    }
  }

  void _deleteStockOpname(int id) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Data'),
        content: const Text(
            'Apakah Anda yakin ingin menghapus data stock opname ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await helper!.deleteStockOpname(id);
      _refreshStockOpname();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data berhasil dihapus')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Stock Opname',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Home(title: '')),
              );
            },
          ),
          actions: [
            // Sync stats indicator
            if (_syncStats != null && !_isSyncing)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GestureDetector(
                  onTap: _showSyncStatsDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _syncStats!['unsynced'] > 0
                          ? Colors.orange.withOpacity(0.2)
                          : Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _syncStats!['unsynced'] > 0
                              ? Icons.cloud_off
                              : Icons.cloud_done,
                          size: 14,
                          color: _syncStats!['unsynced'] > 0
                              ? Colors.orange
                              : Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_syncStats!['synced']}/${_syncStats!['total']}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _syncStats!['unsynced'] > 0
                                ? Colors.orange
                                : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            // Sync button
            IconButton(
              icon: _isSyncing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    )
                  : const Icon(Icons.cloud_sync),
              onPressed: _isSyncing ? null : _syncData,
            ),
            // Refresh button
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _isSyncing ? null : _refreshStockOpname,
            ),
          ],
        ),
        backgroundColor: Colors.grey[300],
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : allStockOpname.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada data Stock Opname',
                          style:
                              TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const TambahStockOpname()),
                            ).then((_) => _refreshStockOpname());
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Tambah Stock Opname'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      await _syncData();
                      _refreshStockOpname();
                    },
                    child: Column(
                      children: [
                        // Summary Cards
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ringkasan Stock Opname',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildSummaryCard(
                                      'Total Items',
                                      allStockOpname.length.toString(),
                                      Colors.blue,
                                      Icons.inventory,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildSummaryCard(
                                      'Selisih Minus',
                                      allStockOpname
                                          .where((item) =>
                                              double.parse(
                                                  item['selisih'].toString()) <
                                              0)
                                          .length
                                          .toString(),
                                      Colors.red,
                                      Icons.trending_down,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildSummaryCard(
                                      'Selisih Plus',
                                      allStockOpname
                                          .where((item) =>
                                              double.parse(
                                                  item['selisih'].toString()) >
                                              0)
                                          .length
                                          .toString(),
                                      Colors.green,
                                      Icons.trending_up,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // List
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: allStockOpname.length,
                            itemBuilder: (context, index) {
                              final item = allStockOpname[index];
                              double selisih =
                                  double.parse(item['selisih'].toString());
                              Color selisihColor = selisih < 0
                                  ? Colors.red
                                  : selisih > 0
                                      ? Colors.green
                                      : Colors.grey;

                              return Card(
                                elevation: 2,
                                margin: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  leading: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: selisihColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      selisih < 0
                                          ? Icons.trending_down
                                          : selisih > 0
                                              ? Icons.trending_up
                                              : Icons.check_circle,
                                      color: selisihColor,
                                      size: 28,
                                    ),
                                  ),
                                  title: Text(
                                    item['nama_produk'] ?? 'N/A',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(
                                        'Kode: ${item['kode_produk'] ?? '-'}',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600]),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              'Sistem: ${item['stok_sistem']}',
                                              style:
                                                  const TextStyle(fontSize: 12),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Text('→',
                                              style: TextStyle(fontSize: 12)),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              'Fisik: ${item['stok_fisik']}',
                                              style:
                                                  const TextStyle(fontSize: 12),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Selisih: ${selisih.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: selisihColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // IconButton(
                                      //   icon: const Icon(Icons.edit,
                                      //       color: Colors.blue),
                                      //   onPressed: () {
                                      //     Navigator.push(
                                      //       context,
                                      //       MaterialPageRoute(
                                      //         builder: (context) =>
                                      //             TambahStockOpname(
                                      //           stockOpnameData: item,
                                      //         ),
                                      //       ),
                                      //     ).then((_) => _refreshStockOpname());
                                      //   },
                                      // ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () =>
                                            _deleteStockOpname(item['id']),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    _showDetailDialog(item);
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const TambahStockOpname()),
            ).then((_) => _refreshStockOpname());
          },
          backgroundColor: Colors.deepOrange,
          icon: const Icon(Icons.add),
          label: const Text('Tambah'),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(fontSize: 11, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showDetailDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detail Stock Opname'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Nama Produk', item['nama_produk'] ?? '-'),
              _buildDetailRow('Kode Produk', item['kode_produk'] ?? '-'),
              _buildDetailRow('Stok Sistem', item['stok_sistem'].toString()),
              _buildDetailRow('Stok Fisik', item['stok_fisik'].toString()),
              _buildDetailRow('Selisih', item['selisih'].toString()),
              _buildDetailRow('Tanggal', item['tanggal'] ?? '-'),
              _buildDetailRow('Keterangan', item['keterangan'] ?? '-'),
              _buildDetailRow('Created By', item['created_by'] ?? '-'),
              _buildDetailRow('Created At',
                  item['created_at']?.toString().substring(0, 19) ?? '-'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Text(': '),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
