import 'package:flutter/material.dart';
import 'package:kasirapp/sync/syncServiceStockOpname.dart';

/// Example widget showing how to use SyncServiceStockOpname with progress tracking
class StockOpnameSyncExample extends StatefulWidget {
  const StockOpnameSyncExample({Key? key}) : super(key: key);

  @override
  _StockOpnameSyncExampleState createState() => _StockOpnameSyncExampleState();
}

class _StockOpnameSyncExampleState extends State<StockOpnameSyncExample> {
  final syncService = SyncServiceStockOpname();
  bool _isSyncing = false;
  String _syncMessage = 'Ready';
  int _syncProgress = 0;
  int _syncTotal = 0;
  Map<String, dynamic>? _syncStats;

  @override
  void initState() {
    super.initState();
    _loadSyncStats();
  }

  Future<void> _loadSyncStats() async {
    final stats = await syncService.getSyncStats();
    setState(() {
      _syncStats = stats;
    });
  }

  /// Example 1: Simple download sync
  Future<void> _downloadFromServer() async {
    setState(() {
      _isSyncing = true;
      _syncMessage = 'Memulai download...';
      _syncProgress = 0;
    });

    final success = await syncService.syncStockOpname(
      onProgress: (message, current, total) {
        setState(() {
          _syncMessage = message;
          _syncProgress = current;
          _syncTotal = total;
        });
      },
    );

    setState(() {
      _isSyncing = false;
      _syncMessage = success ? 'Download berhasil!' : 'Download gagal!';
    });

    _loadSyncStats();

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Download berhasil'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  /// Example 2: Upload local data to server
  Future<void> _uploadToServer() async {
    final hasUnsynced = await syncService.hasUnsyncedData();
    if (!hasUnsynced) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada data untuk diupload')),
      );
      return;
    }

    setState(() {
      _isSyncing = true;
      _syncMessage = 'Memulai upload...';
      _syncProgress = 0;
    });

    final success = await syncService.syncToServer(
      onProgress: (message, current, total) {
        setState(() {
          _syncMessage = message;
          _syncProgress = current;
          _syncTotal = total;
        });
      },
    );

    setState(() {
      _isSyncing = false;
      _syncMessage = success ? 'Upload berhasil!' : 'Upload gagal!';
    });

    _loadSyncStats();

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upload berhasil'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  /// Example 3: Two-way sync (recommended)
  Future<void> _twoWaySync() async {
    setState(() {
      _isSyncing = true;
      _syncMessage = 'Memulai two-way sync...';
      _syncProgress = 0;
    });

    final success = await syncService.syncTwoWay(
      onProgress: (message, current, total) {
        setState(() {
          _syncMessage = message;
          _syncProgress = current;
          _syncTotal = total;
        });
      },
    );

    setState(() {
      _isSyncing = false;
      _syncMessage = success ? 'Sync berhasil!' : 'Sync gagal!';
    });

    _loadSyncStats();

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sync berhasil'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  /// Example 4: Force full sync
  Future<void> _forceFullSync() async {
    // Show confirmation dialog
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text(
          'Force sync akan mendownload ulang semua data dari server. Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Lanjutkan'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isSyncing = true;
      _syncMessage = 'Memulai full sync...';
      _syncProgress = 0;
    });

    final success = await syncService.syncAll(
      onProgress: (message, current, total) {
        setState(() {
          _syncMessage = message;
          _syncProgress = current;
          _syncTotal = total;
        });
      },
    );

    setState(() {
      _isSyncing = false;
      _syncMessage = success ? 'Full sync berhasil!' : 'Full sync gagal!';
    });

    _loadSyncStats();

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Full sync berhasil'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Opname Sync'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sync Status Card
            if (_syncStats != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sync Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildStatRow('Total Data', '${_syncStats!['total']}'),
                      _buildStatRow('Synced', '${_syncStats!['synced']}',
                          color: Colors.green),
                      _buildStatRow('Unsynced', '${_syncStats!['unsynced']}',
                          color:
                              _syncStats!['unsynced'] > 0 ? Colors.red : null),
                      _buildStatRow('Last Sync', _syncStats!['last_sync']),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Progress Indicator
            if (_isSyncing) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: _syncTotal > 0 ? _syncProgress / _syncTotal : null,
                        minHeight: 8,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _syncMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14),
                      ),
                      if (_syncTotal > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          '$_syncProgress / $_syncTotal',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Sync Buttons
            const Text(
              'Sync Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _buildSyncButton(
              icon: Icons.cloud_download,
              label: 'Download from Server',
              description: 'Download data baru dari server',
              onPressed: _isSyncing ? null : _downloadFromServer,
              color: Colors.blue,
            ),

            const SizedBox(height: 8),

            _buildSyncButton(
              icon: Icons.cloud_upload,
              label: 'Upload to Server',
              description: 'Upload data lokal ke server',
              onPressed: _isSyncing ? null : _uploadToServer,
              color: Colors.orange,
            ),

            const SizedBox(height: 8),

            _buildSyncButton(
              icon: Icons.sync,
              label: 'Two-Way Sync (Recommended)',
              description: 'Download lalu upload',
              onPressed: _isSyncing ? null : _twoWaySync,
              color: Colors.green,
            ),

            const SizedBox(height: 8),

            _buildSyncButton(
              icon: Icons.refresh,
              label: 'Force Full Sync',
              description: 'Download ulang semua data',
              onPressed: _isSyncing ? null : _forceFullSync,
              color: Colors.deepOrange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700])),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncButton({
    required IconData icon,
    required String label,
    required String description,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              description,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
