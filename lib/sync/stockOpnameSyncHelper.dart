import 'package:flutter/material.dart';
import 'package:kasirapp/sync/syncServiceStockOpname.dart';

/// Helper class to simplify sync operations with built-in UI feedback
class StockOpnameSyncHelper {
  /// Perform a two-way sync with automatic UI feedback
  static Future<bool> syncWithFeedback(
    BuildContext context, {
    bool showSnackBar = true,
    bool showLoadingDialog = true,
  }) async {
    final syncService = SyncServiceStockOpname();

    // Check for internet connectivity (optional - add connectivity_plus package)
    // final connectivityResult = await Connectivity().checkConnectivity();
    // if (connectivityResult == ConnectivityResult.none) {
    //   if (showSnackBar) {
    //     _showSnackBar(context, 'No internet connection', Colors.red);
    //   }
    //   return false;
    // }

    if (showLoadingDialog) {
      _showSyncDialog(context, syncService);
    }

    final success = await syncService.syncTwoWay(
      onProgress: (message, current, total) {
        if (showLoadingDialog) {
          _updateSyncDialog(context, message, current, total);
        }
      },
    );

    if (showLoadingDialog) {
      Navigator.of(context).pop();
    }

    if (showSnackBar) {
      _showSnackBar(
        context,
        success ? 'Sync completed successfully' : 'Sync failed',
        success ? Colors.green : Colors.red,
      );
    }

    return success;
  }

  /// Download only with feedback
  static Future<bool> downloadWithFeedback(
    BuildContext context, {
    bool showSnackBar = true,
    bool showLoadingDialog = true,
  }) async {
    final syncService = SyncServiceStockOpname();

    if (showLoadingDialog) {
      _showSyncDialog(context, syncService);
    }

    final success = await syncService.syncStockOpname(
      onProgress: (message, current, total) {
        if (showLoadingDialog) {
          _updateSyncDialog(context, message, current, total);
        }
      },
    );

    if (showLoadingDialog) {
      Navigator.of(context).pop();
    }

    if (showSnackBar) {
      _showSnackBar(
        context,
        success ? 'Download completed' : 'Download failed',
        success ? Colors.green : Colors.red,
      );
    }

    return success;
  }

  /// Upload only with feedback
  static Future<bool> uploadWithFeedback(
    BuildContext context, {
    bool showSnackBar = true,
    bool showLoadingDialog = true,
  }) async {
    final syncService = SyncServiceStockOpname();

    final hasUnsynced = await syncService.hasUnsyncedData();
    if (!hasUnsynced) {
      if (showSnackBar) {
        _showSnackBar(context, 'No data to upload', Colors.orange);
      }
      return true;
    }

    if (showLoadingDialog) {
      _showSyncDialog(context, syncService);
    }

    final success = await syncService.syncToServer(
      onProgress: (message, current, total) {
        if (showLoadingDialog) {
          _updateSyncDialog(context, message, current, total);
        }
      },
    );

    if (showLoadingDialog) {
      Navigator.of(context).pop();
    }

    if (showSnackBar) {
      _showSnackBar(
        context,
        success ? 'Upload completed' : 'Upload failed',
        success ? Colors.green : Colors.red,
      );
    }

    return success;
  }

  /// Show sync statistics
  static Future<void> showSyncStats(BuildContext context) async {
    final syncService = SyncServiceStockOpname();
    final stats = await syncService.getSyncStats();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sync Statistics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatRow('Total Records', '${stats['total']}'),
            _buildStatRow('Synced', '${stats['synced']}', Colors.green),
            _buildStatRow(
              'Unsynced',
              '${stats['unsynced']}',
              stats['unsynced'] > 0 ? Colors.red : null,
            ),
            const Divider(height: 24),
            _buildStatRow('Last Sync', stats['last_sync']),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Quick sync button for AppBar
  static Widget syncAppBarButton(
    BuildContext context, {
    Color? color,
    double size = 24,
    VoidCallback? onComplete,
  }) {
    return ValueListenableBuilder(
      valueListenable: _syncInProgressNotifier,
      builder: (context, isSyncing, child) {
        return IconButton(
          icon: isSyncing
              ? SizedBox(
                  width: size,
                  height: size,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      color ?? Colors.white,
                    ),
                  ),
                )
              : Icon(
                  Icons.sync,
                  size: size,
                  color: color,
                ),
          onPressed: isSyncing
              ? null
              : () async {
                  _syncInProgressNotifier.value = true;
                  await syncWithFeedback(context);
                  _syncInProgressNotifier.value = false;
                  onComplete?.call();
                },
        );
      },
    );
  }

  /// Show unsynced warning if there are unsynced records
  static Future<void> warnIfUnsynced(BuildContext context) async {
    final syncService = SyncServiceStockOpname();
    final hasUnsynced = await syncService.hasUnsyncedData();

    if (hasUnsynced && context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unsynced Data'),
          content: const Text(
            'You have unsynced stock opname records. Would you like to sync now?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Later'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                syncWithFeedback(context);
              },
              child: const Text('Sync Now'),
            ),
          ],
        ),
      );
    }
  }

  // Private helper methods

  static final ValueNotifier<bool> _syncInProgressNotifier =
      ValueNotifier<bool>(false);

  static void _showSnackBar(
    BuildContext context,
    String message,
    Color color,
  ) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static void _showSyncDialog(
    BuildContext context,
    SyncServiceStockOpname syncService,
  ) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _SyncProgressDialog(syncService: syncService),
    );
  }

  static void _updateSyncDialog(
    BuildContext context,
    String message,
    int current,
    int total,
  ) {
    if (!context.mounted) return;

    // The dialog will listen to changes via the sync service
  }
}

class _SyncProgressDialog extends StatefulWidget {
  final SyncServiceStockOpname syncService;

  const _SyncProgressDialog({required this.syncService});

  @override
  State<_SyncProgressDialog> createState() => _SyncProgressDialogState();
}

class _SyncProgressDialogState extends State<_SyncProgressDialog> {
  String _message = 'Preparing sync...';
  int _current = 0;
  int _total = 0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              _message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            if (_total > 0) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: _total > 0 ? _current / _total : null,
                minHeight: 4,
              ),
              const SizedBox(height: 4),
              Text(
                '$_current / $_total',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Widget _buildStatRow(String label, String value, [Color? color]) {
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
