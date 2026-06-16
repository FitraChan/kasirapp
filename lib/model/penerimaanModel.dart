class PenerimaanModel {
  int? _id;
  int? _nilai;
  String? _keterangan;
  String? _status;
  String? _createdAt;
  int? _shiftId;

  PenerimaanModel(dynamic json) {
    _id = json['id'];
    _nilai = json['nilai'];
    _keterangan = json['keterangan'];
    _createdAt = json['created_at'];
    _status = json['status'];
    _shiftId = json['shift_id'];
  }

  int? get id => _id;
  String? get keterangan => _keterangan;
  String? get created_at => _createdAt;
  int? get nilai => _nilai;
  int? get shift_id => _shiftId;

  PenerimaanModel.fromMap(Map<String, dynamic> map) {
    _id = map['id'];
    _keterangan = map['keterangan'];
    _nilai = map['nilai'];
    _createdAt = map['created_at'];
    _shiftId = map['shift_id'];
  }

  Map<String, dynamic> toMap() => {
        'id': _id,
        'nilai': _nilai,
        'keterangan': _keterangan,
        'created_at': _createdAt,
        'status': _status,
        'shift_id': _shiftId
      };
}
