class PengeluaranModel {
  int? _id;
  int? _nilai;
  String? _keterangan;

  int? _status;
  String? _createdAt;
  int? _shiftId;
  int? _isSync;

  // String? _catatan;

  PengeluaranModel(dynamic json) {
    _id = json['id'];
    _nilai = json['nilai'];
    _keterangan = json['keterangan'];
    _createdAt = json['created_at'];
    _status = json['status'];
    _shiftId = json['shift_id'];
    _isSync = json['is_sync'];
  }

  int? get id => _id;
  String? get keterangan => _keterangan;
  String? get created_at => _createdAt;
  int? get nilai => _nilai;
  int? get shift_id => _shiftId;
  int? get status => _status;
  int? get is_sync => _isSync;

  PengeluaranModel.fromMap(Map<String, dynamic> map) {
    _id = map['id'];
    _keterangan = map['keterangan'];
    _nilai = map['nilai'];
    _createdAt = map['created_at'];
    _shiftId = map['shift_id'];
    _status = map['status'];
    _isSync = map['is_sync'];
  }

  Map<String, dynamic> toMap() => {
        'id': _id,
        'nilai': _nilai,
        'keterangan': _keterangan,
        'created_at': _createdAt,
        'status': _status,
        'shift_id': _shiftId,
        'is_sync': _isSync,
        // 'catatan': _catatan,
      };
}
