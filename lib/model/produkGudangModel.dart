class ProdukGudangModel {
  int? _id;
  String? _kodeItem;
  String? _kodeBarcode;
  String? _namaItem;
  String? _stok;
  String? _waktuScan;
  String? _createdAt;
  String? _updatedAt;
  int? _isSync;

  ProdukGudangModel(dynamic json) {
    _id = json['id'];
    _kodeItem = json['kode_item'];
    _kodeBarcode = json['kode_barcode'];
    _namaItem = json['nama_item'];
    _stok = json['stok'];
    _waktuScan = json['waktu_scan'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _isSync = json['is_sync'] ?? 0;
  }

  ProdukGudangModel.fromMap(Map<String, dynamic> json) {
    _id = json['id'];
    _kodeItem = json['kode_item'];
    _kodeBarcode = json['kode_barcode'];
    _namaItem = json['nama_item'];
    _stok = json['stok'] ?? '0';
    _waktuScan = json['waktu_scan'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _isSync = json['is_sync'] ?? 0;
  }

  int? get id => _id;
  String? get kodeItem => _kodeItem;
  String? get kodeBarcode => _kodeBarcode;
  String? get namaItem => _namaItem;
  String? get stok => _stok;
  String? get waktuScan => _waktuScan;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  int? get isSync => _isSync;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'kode_item': _kodeItem,
        'kode_barcode': _kodeBarcode,
        'nama_item': _namaItem,
        'stok': _stok,
        'waktu_scan': _waktuScan,
        'created_at': _createdAt,
        'updated_at': _updatedAt,
        'is_sync': _isSync,
      };

  Map<String, dynamic> toMapForSync() => {
        'kode_item': _kodeItem,
        'kode_barcode': _kodeBarcode,
        'nama_item': _namaItem,
        'stok': _stok,
        'waktu_scan': _waktuScan,
      };
}
