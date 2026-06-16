class ProdukModel {
  int? _id;
  String? _namaBarang;
  String? _kode;
  int? _idKategori;
  int? _hargaJual;
  //int? _idDelivery;
  int? _hargaBeli;
  int? _stok;
  int? _hargaShoopeFood;
  int? _hargaGoFood;

  int? _harga;

  int? _idPk;

  // String? _satuan;
  String? _gambar;
  String? _createdAt;
  String? _keterangan;

  ProdukModel(dynamic json) {
    _id = json['id'];

    _idPk = json['id_pk'];
    // _idDelivery = json['id_delivery'];
    _hargaGoFood = json['harga_go_food'];
    _hargaShoopeFood = json['harga_shopee_food'];

    _namaBarang = json['nama_barang'];
    _kode = json['kode'];
    _harga = json['harga'];
    _idKategori = json['id_kategori'];
    //   _catatan = json['catatan'];
    _hargaBeli = json['harga_beli'];
    //  _hargaGrosir = json['harga_grosir'];
    _hargaJual = json['harga_jual'];
    // _satuan = json['satuan'];
    _stok = json['stok'];
    _gambar = json['gambar'];
    _createdAt = json['tanggal_sekarang'];
    _keterangan = json['keterangan'];
  }

  ProdukModel.fromMap(Map<String, dynamic> json) {
    _id = json['id'];

    //_idDelivery = json['id_delivery'];
    _hargaGoFood = int.tryParse(json['harga_go_food']?.toString() ?? '0');
    _hargaShoopeFood =
        int.tryParse(json['harga_shopee_food']?.toString() ?? '0');
    // _hargaGoFood = 0;
    // _hargaShoopeFood = 0;
    _namaBarang = json['nama_barang'];
    _kode = json['kode'];
    _harga = int.tryParse(json['harga']?.toString() ?? '0') ?? 0;
    0; //    this._catatan = json['catatan'];
    _hargaBeli = int.tryParse(json['harga_beli']?.toString() ?? '0') ?? 0;
    _hargaJual = int.tryParse(json['harga_jual']?.toString() ?? '0') ?? 0;

    _idPk = int.tryParse(json['id_pk']?.toString() ?? '0') ?? 0;

    _stok = int.tryParse(json['stok']?.toString() ?? '0') ?? 0;
    _gambar = json['gambar'];
    _createdAt = json['tanggal_sekarang'];
    _keterangan = json['keterangan'];
  }

  int? get id => _id;
  String? get namaBarang => _namaBarang;
  String? get kode => _kode;
  int? get idKategori => _idKategori;
  int? get hargaJual => _hargaJual;
//  int? get idDelivery => _idDelivery;
  int? get hargaShopeeFood => _hargaShoopeFood;
  int? get hargaGoFood => _hargaGoFood;
  int? get hargaBeli => _hargaBeli;
  int? get harga => _harga;
  int? get stok => _stok;
  int? get idPk => _idPk;
  String? get createdAt => _createdAt;
  String? get gambar => _gambar;
  String? get keterangan => _keterangan;
  Map<String, dynamic> toMap() => {
        'id': _id,
        'nama_barang': _namaBarang,
        'kode': _kode,
        'id_kategori': _idKategori,
        'harga_beli': _hargaBeli.toString(),
        'harga_jual': _hargaJual.toString(),
        'stok': _stok,
        'tanggal_sekarang': _createdAt,
        // 'id_delivery': _idDelivery,
        'harga_shopee_food': _hargaShoopeFood.toString(),
        'harga_go_food': _hargaGoFood.toString(),
        'gambar': _gambar,
        'keterangan': _keterangan,
        'id_pk': _idPk,
        //     'harga': _harga.toString(),
      };
}

class ProdukModelMysql {
  ProdukModelMysql({
    required this.id,
    required this.namaBarang,
    required this.kode,
    required this.idKategori,
    required this.hargaJual,
    // required this.idDelivery,
    required this.hargaGoFood,
    required this.hargaShopeeFood,
    required this.hargaBeli,
    required this.stok,
    required this.harga,
    required this.createdAt,
    required this.gambar,
    required this.keterangan,
    required this.idPk,
  });

  int id;
  String namaBarang;
  String kode;
  String idKategori;
  String hargaJual;
  String hargaBeli;
  String stok;
  //String idDelivery;
  String hargaShopeeFood;
  String hargaGoFood;
  String createdAt;
  String gambar;
  String harga;
  String keterangan;
  int? idPk;
  factory ProdukModelMysql.fromJson(Map<String, dynamic> json) =>
      ProdukModelMysql(
        id: json['id'],
        namaBarang: json['nama_barang'],
        kode: json['kode'],
        idKategori: json['id_kategori'].toString(),
        idPk: int.tryParse(json['id_pk']?.toString() ?? '0') ?? 0,
        // idDelivery: json['id_delivery'],
        hargaGoFood: json['harga_go_food'].toString(),
        hargaShopeeFood: json['harga_shopee_food'].toString(),
        //   _catatan : json['catatan'],
        hargaBeli: json['harga_beli'].toString(),
        //hargaGrosir: json['harga_grosir'],
        hargaJual: json['harga_jual'].toString(),
        //  satuan: json['satuan'],
        stok: json['stok'].toString(),
        gambar: json['gambar'],
        harga: json['harga'].toString(),
        // gambar: json['gambar'],
        createdAt: json['created_at'],
        keterangan: json['keterangan'] ?? '',
        // gambarMobile: json['gambar_mobile'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nama_barang': namaBarang,
        'kode': kode,
        'id_kategori': idKategori,
        'harga_beli': hargaBeli,
        'harga_jual': hargaJual,
        'stok': stok,
        'created_at': createdAt,
        'harga_go_food': hargaGoFood,
        'harga_shopee_food': hargaShopeeFood,
        'gambar': gambar,
        'keterangan': keterangan,
        'harga': harga,
        'id_pk': idPk,
      };
}
