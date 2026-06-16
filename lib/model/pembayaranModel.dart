class PembayaranModel {
  int? _id;
  int? _idTransaksi;
  int? _total;
  String? _createdAt;
  int? _dibayar;
  int? _kembalian;

  // String? _catatan;

  PembayaranModel(dynamic json) {
    _id = json['id'];
    _idTransaksi = json['id_transaksi'];
    _total = json['total'];
    _createdAt = json['created_at'];
    _dibayar = json['dibayar'];
    _kembalian = json['kembalian'];
  }
  PembayaranModel.fromMap(Map<String, dynamic> json) {
    _idTransaksi = json['id_transaksi'];
    _id = json['id'];
    _total = json['total'];
    _createdAt = json['created_at'];
  }

  int? get idTransaksi => _idTransaksi;
  int? get id => _id;
  int? get total => _total;
  String? get createdAt => _createdAt;

  // String? get catatan => _catatan;

  Map<String, dynamic> toMap() => {
        'id_transaksi': _idTransaksi,
        'id': _id,
        'total': _total,
        'created_at': _createdAt,
        'dibayar': _dibayar,
        'kembalian': _kembalian,
      };
}
