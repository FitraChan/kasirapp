class TransaksiPembelianModel {
  int? _id;
  String? _keterangan;
  int? _total;
  String? _createdAt;
  int? _idPembeli;

  int? _statusBayar;
  int? _idDelivery;
  int? _idPelanggan;

  int? _totalHutang;
  int? _totalBayar;
  int? _sisaHutang;

  int? _shiftId;

  String? _kodeTransaksi;

  //  'total_hutang': allTotal,
  //     'bayar_dimuka': bayarDimuka,
  //     'sisa_hutang': sisaHutang,

  // String? _catatan;

  TransaksiPembelianModel(dynamic json) {
    _id = json['id'];
    _keterangan = json['keterangan'];
    _total = json['total'];
    _idPembeli = json['id_pembeli'];
    _createdAt = json['created_at'];
    _statusBayar = json['status_bayar'];
    _idDelivery = json['id_delivery'];
    _idPelanggan = json['id_pelanggan'];
    _totalHutang = json['total_hutang'];
    _totalBayar = json['total_bayar'];
    _sisaHutang = json['sisa_hutang'];
    _shiftId = json['shift_id'];
    _kodeTransaksi = json['kode_transaksi'];
    // _catatan = json['catatan'];
  }

  TransaksiPembelianModel.fromMap(Map<String, dynamic> json) {
    _id = json['id'];
    _keterangan = json['keterangan'];
    _total = json['total'];
    _createdAt = json['created_at'];
    _idPembeli = json['id_pembeli'];
    _statusBayar = json['status_bayar'];
    _idDelivery = json['id_delivery'];
    _idPelanggan = json['id_pelanggan'];
    _totalHutang = json['total_hutang'];
    _totalBayar = json['total_bayar'];
    _sisaHutang = json['sisa_hutang'];
    _shiftId = json['shift_id'];
    _kodeTransaksi = json['kode_transaksi'];
  }

  int? get id => _id;
  String? get keterangan => _keterangan;
  int? get total => _total;
  String? get createdAt => _createdAt;
  int? get idPembeli => _idPembeli;

  int? get statusBayar => _statusBayar;
  int? get idDelivery => _idDelivery;
  int? get idPelanggan => _idPelanggan;
  int? get shiftId => _shiftId;
  String? get kodeTransaksi => _kodeTransaksi;
  // String? get catatan => _catatan;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'keterangan': _keterangan,
        'total': _total,
        'created_at': _createdAt,
        'id_pembeli': _idPembeli,
        'status_bayar': _statusBayar,
        'id_delivery': _idDelivery,
        'id_pelanggan': _idPelanggan,
        'total_hutang': _totalHutang,
        'total_bayar': _totalBayar,
        'sisa_hutang': _sisaHutang,
        'shift_id': _shiftId,
        'kode_transaksi': _kodeTransaksi
      };
}
