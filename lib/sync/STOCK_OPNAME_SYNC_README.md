# Stock Opname Sync Service

## Overview
The `SyncServiceStockOpname` provides comprehensive synchronization functionality for stock opname data between local SQLite database and remote server.

## Location
`lib/sync/syncServiceStockOpname.dart`

## Features

### 1. **Download from Server**
- Incremental sync based on last update timestamp
- Handles deleted records
- Progress tracking with callbacks

### 2. **Upload to Server**
- Uploads locally created/updated records
- Tracks sync status per record
- Error handling for individual records

### 3. **Two-Way Sync**
- Combines download and upload
- Ensures data consistency
- Recommended for most use cases

### 4. **Progress Tracking**
- Real-time progress callbacks
- Detailed status messages
- UI integration support

## Usage Examples

### Basic Download
```dart
final syncService = SyncServiceStockOpname();

final success = await syncService.syncStockOpname(
  onProgress: (message, current, total) {
    print('$message: $current / $total');
  },
);
```

### Upload Local Data
```dart
final success = await syncService.syncToServer(
  onProgress: (message, current, total) {
    print('$message: $current / $total');
  },
);
```

### Two-Way Sync (Recommended)
```dart
final success = await syncService.syncTwoWay(
  onProgress: (message, current, total) {
    print('$message: $current / $total');
  },
);
```

### Force Full Sync
```dart
final success = await syncService.syncAll(
  onProgress: (message, current, total) {
    print('$message: $current / $total');
  },
);
```

## API Reference

### Methods

#### `getLastUpdate()`
Returns the last sync timestamp from local storage.

**Returns:** `Future<String>` - Date string in format `yyyy-MM-dd HH:mm:ss`

---

#### `saveLastUpdate(String value)`
Saves a new sync timestamp to local storage.

**Parameters:**
- `value`: Date string to save

**Returns:** `Future<void>`

---

#### `syncStockOpname({ProgressCallback? onProgress})`
Downloads new/updated data from server since last sync.

**Parameters:**
- `onProgress`: Optional callback for progress updates
  - `message`: Status message
  - `current`: Current progress count
  - `total`: Total items to process

**Returns:** `Future<bool>` - True if sync successful

---

#### `syncAll({ProgressCallback? onProgress})`
Force sync all data from server (ignores last sync timestamp).

**Parameters:**
- `onProgress`: Optional callback for progress updates

**Returns:** `Future<bool>`

---

#### `syncToServer({ProgressCallback? onProgress})`
Uploads locally unsynced data to server.

**Parameters:**
- `onProgress`: Optional callback for progress updates

**Returns:** `Future<bool>`

---

#### `syncTwoWay({ProgressCallback? onProgress})`
Performs two-way sync (download then upload).

**Parameters:**
- `onProgress`: Optional callback for progress updates

**Returns:** `Future<bool>`

---

#### `getSyncStats()`
Returns statistics about sync status.

**Returns:** `Future<Map<String, dynamic>>` with keys:
- `total`: Total local records
- `unsynced`: Number of unsynced records
- `synced`: Number of synced records
- `last_sync`: Last sync timestamp

**Example:**
```dart
final stats = await syncService.getSyncStats();
print('Total: ${stats['total']}');
print('Unsynced: ${stats['unsynced']}');
print('Last sync: ${stats['last_sync']}');
```

---

#### `hasUnsyncedData()`
Checks if there are any unsynced records.

**Returns:** `Future<bool>`

---

#### `resetSyncStatus()`
Resets the sync timestamp (forces full sync on next sync).

**Returns:** `Future<void>`

---

#### `clearLocalData()`
Clears all local stock opname data and resets sync status.

**Returns:** `Future<void>`

---

## Integration Example

### In Your Screen/Widget

```dart
class StockOpnameScreen extends StatefulWidget {
  @override
  _StockOpnameScreenState createState() => _StockOpnameScreenState();
}

class _StockOpnameScreenState extends State<StockOpnameScreen> {
  final syncService = SyncServiceStockOpname();
  bool _isSyncing = false;

  Future<void> _syncData() async {
    setState(() => _isSyncing = true);

    final success = await syncService.syncTwoWay(
      onProgress: (message, current, total) {
        // Update UI with progress
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      },
    );

    setState(() => _isSyncing = false);

    if (success) {
      _refreshData(); // Refresh your list
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sync successful!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: _isSyncing 
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(Icons.sync),
            onPressed: _isSyncing ? null : _syncData,
          ),
        ],
      ),
      // ... rest of your UI
    );
  }
}
```

### Pull-to-Refresh with Sync

```dart
RefreshIndicator(
  onRefresh: () async {
    await syncService.syncTwoWay(
      onProgress: (message, current, total) {
        // Handle progress
      },
    );
    await _loadData();
  },
  child: ListView.builder(
    // Your list
  ),
)
```

## Database Schema

### `tb_stock_opname` Table
```sql
CREATE TABLE tb_stock_opname (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  produk_id INTEGER NULL,
  kode_produk TEXT NULL,
  nama_produk TEXT NULL,
  stok_sistem REAL NULL,
  stok_fisik REAL NULL,
  selisih REAL NULL,
  keterangan TEXT,
  tanggal TEXT NULL,
  created_by TEXT NULL,
  is_sync INTEGER DEFAULT 0,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT DEFAULT CURRENT_TIMESTAMP
)
```

**Key Fields:**
- `is_sync`: 0 = not synced, 1 = synced
- `deleted_at`: If not null, record should be deleted locally

## Server API Endpoints

### Download Endpoint
- **Route:** `stockOpnameSync`
- **Method:** POST
- **Request:**
  ```json
  {
    "last_update": "2024-01-01 00:00:00"
  }
  ```
- **Response:**
  ```json
  {
    "data": [
      {
        "id": 1,
        "produk_id": 100,
        "kode_produk": "PRD001",
        "nama_produk": "Product A",
        "stok_sistem": 100,
        "stok_fisik": 95,
        "selisih": -5,
        "keterangan": "Some notes",
        "tanggal": "2024-01-15",
        "created_by": "admin",
        "created_at": "2024-01-15 10:30:00",
        "updated_at": "2024-01-15 10:30:00",
        "deleted_at": null
      }
    ],
    "last_update": "2024-01-15 10:30:00"
  }
  ```

### Upload Endpoint
- **Route:** `createStockOpname`
- **Method:** POST
- **Request:**
  ```json
  {
    "id": "1",
    "produk_id": "100",
    "kode_produk": "PRD001",
    "nama_produk": "Product A",
    "stok_sistem": "100",
    "stok_fisik": "95",
    "selisih": "-5",
    "keterangan": "Some notes",
    "tanggal": "2024-01-15",
    "created_by": "admin",
    "created_at": "2024-01-15 10:30:00"
  }
  ```

## Best Practices

1. **Use Two-Way Sync**: For most scenarios, use `syncTwoWay()` to ensure data consistency
2. **Progress Feedback**: Always provide visual feedback to users during sync
3. **Error Handling**: Check return values and handle failures gracefully
4. **Initial Load**: Call `syncAll()` on first app launch or when local data is empty
5. **Regular Sync**: Use `syncStockOpname()` for regular incremental updates
6. **Conflict Resolution**: Server data takes precedence during download

## Error Handling

All sync methods return `bool` indicating success/failure. Errors are logged to console. For production:

```dart
try {
  final success = await syncService.syncTwoWay();
  if (!success) {
    // Show user-friendly error message
  }
} catch (e) {
  // Handle unexpected errors
  print('Sync error: $e');
}
```

## Related Files

- `lib/transaksi/stockOpname.dart` - UI screen
- `lib/transaksi/tambahStockOpname.dart` - Add/Edit screen
- `lib/helpers/dbkasir.dart` - Database helper
- `lib/sync/stockOpnameSyncExample.dart` - Complete usage example

## Notes

- Sync status is stored in SharedPreferences
- Timestamp format: `yyyy-MM-dd HH:mm:ss`
- Local timezone is used for all timestamps
- Deleted records are handled via `deleted_at` field
