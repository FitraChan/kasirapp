class TransaksiDetailPembelianModel {
  int? _idSubTransaksi;
  int? _idTransaksi;
  int? _idBarang;
  int? _harga;
  int? _qty;
  int? _diskon;
  String? _kode;
  String? _namaBarang;
  int? _hargaBarang;
  int? _status;
  int? _total;

  String? _catatan;
  String? _createdAt;
  String? _idDelivery;
  String? kodeTransaksi;

  // String? _catatan;

  TransaksiDetailPembelianModel(dynamic json) {
    kodeTransaksi = json['kode_transaksi'];
    _idSubTransaksi = json['id_sub_transaksi'];
    _idTransaksi = json['id_transaksi'];
    _idBarang = json['id_barang'];
    _harga = json['harga'];
    _qty = json['qty'];
    _diskon = json['diskon'];
    _status = json['status'];
    _kode = json['kode'];
    _hargaBarang = json['harga_jual'];
    _namaBarang = json['nama_barang'];
    _catatan = json['catatan'];
    _createdAt = json['created_at'];
    _idDelivery = json['id_delivery'];
    _total = json['total'];
  }

  // String? get catatan => _catatan;

  Map<String, dynamic> toMap() => {
        'id_sub_transaksi': _idSubTransaksi,
        'id_transaksi': _idTransaksi,
        'id_barang': _idBarang,
        'harga': _harga,
        'qty': _qty,
        'status': _status,
        'diskon': _diskon,
        'catatan': _catatan,
        'created_at': _createdAt,
        'id_delivery': _idDelivery,
        'kode_transaksi': kodeTransaksi,
        'total': _total,

        // 'kode': _kode,
      };

  TransaksiDetailPembelianModel.fromMap(Map<String, dynamic> json) {
    _idSubTransaksi = json['id_sub_transaksi'];
    _idTransaksi = json['id_transaksi'];
    _idBarang = json['id_barang'];
    _harga = json['harga'];
    _qty = json['qty'];
    _diskon = json['diskon'];
    _status = json['status'];
    _kode = json['kode'];
    _hargaBarang = json['harga_jual'];
    _namaBarang = json['nama_barang'];
    _catatan = json['catatan'];
    _createdAt = json['created_at'];
    _idDelivery = json['id_delivery'];
    kodeTransaksi = json['kode_transaksi'];
    _total = json['total'];
  }
}
