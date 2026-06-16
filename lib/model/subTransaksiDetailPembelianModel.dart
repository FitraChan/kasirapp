class SubTransaksiDetailPembelianModel {
  int? _idSubTransaksi;
  int? _idTransaksi;

  int? _idBarang;
  int? _harga;
  int? _qty;
  int? _status;
  String? _createdAt;

  //SubTransaksiDetailPembelianModel(Map<String, dynamic> map);

  // String? _catatan;

  SubTransaksiDetailPembelianModel(Map<String, dynamic> map) {
    _idSubTransaksi = map['id_sub_transaksi'];
    _idTransaksi = map['id_transaksi'];
    _idBarang = map['id_barang'];
    _harga = map['harga'];
    _qty = map['qty'];
    _status = map['status'];
    _createdAt = map['created_at'];
  }

  TransaksiDetailPembelianModel(dynamic json) {
    _idSubTransaksi = json['id_sub_transaksi'];
    _idTransaksi = json['id_transaksi'];
    _idBarang = json['id_barang'];
    _harga = json['harga'];
    _qty = json['qty'];
    // _diskon = json['diskon'];
    _status = json['status'];

    _createdAt = json['created_at'];
  }

  // String? get catatan => _catatan;

  Map<String, dynamic> toMap() => {
        'id_sub_transaksi': _idSubTransaksi,
        'id_transaksi': _idTransaksi,
        'id_barang': _idBarang,
        'harga': _harga,
        'qty': _qty,
        'status': _status,
        //'diskon': _diskon,

        'created_at': _createdAt,

        // 'kode': _kode,
      };
}
