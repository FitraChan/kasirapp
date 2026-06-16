class StockOpnameModel {
  int? _id;
  int? _produkId;
  String? _kodeProduk;
  String? _namaProduk;
  double? _stokSistem;
  double? _stokFisik;
  double? _selisih;
  String? _keterangan;
  String? _tanggal;
  String? _createdBy;
  String? _createdAt;
  String? _updatedAt;

  StockOpnameModel(dynamic json) {
    _id = json['id'];
    _produkId = json['produk_id'];
    _kodeProduk = json['kode_produk'];
    _namaProduk = json['nama_produk'];
    _stokSistem = json['stok_sistem'];
    _stokFisik = json['stok_fisik'];
    _selisih = json['selisih'];
    _keterangan = json['keterangan'];
    _tanggal = json['tanggal'];
    _createdBy = json['created_by'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
  }

  StockOpnameModel.fromMap(Map<String, dynamic> json) {
    _id = json['id'];
    _produkId = json['produk_id'];
    _kodeProduk = json['kode_produk'];
    _namaProduk = json['nama_produk'];
    _stokSistem = double.tryParse(json['stok_sistem']?.toString() ?? '0') ?? 0;
    _stokFisik = double.tryParse(json['stok_fisik']?.toString() ?? '0') ?? 0;
    _selisih = double.tryParse(json['selisih']?.toString() ?? '0') ?? 0;
    _keterangan = json['keterangan'];
    _tanggal = json['tanggal'];
    _createdBy = json['created_by'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
  }

  int? get id => _id;
  int? get produkId => _produkId;
  String? get kodeProduk => _kodeProduk;
  String? get namaProduk => _namaProduk;
  double? get stokSistem => _stokSistem;
  double? get stokFisik => _stokFisik;
  double? get selisih => _selisih;
  String? get keterangan => _keterangan;
  String? get tanggal => _tanggal;
  String? get createdBy => _createdBy;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'produk_id': _produkId,
        'kode_produk': _kodeProduk,
        'nama_produk': _namaProduk,
        'stok_sistem': _stokSistem.toString(),
        'stok_fisik': _stokFisik.toString(),
        'selisih': _selisih.toString(),
        'keterangan': _keterangan,
        'tanggal': _tanggal,
        'created_by': _createdBy,
        'created_at': _createdAt,
        'updated_at': _updatedAt,
      };
}

class StockOpnameModelMysql {
  StockOpnameModelMysql({
    required this.id,
    required this.produkId,
    required this.kodeProduk,
    required this.namaProduk,
    required this.stokSistem,
    required this.stokFisik,
    required this.selisih,
    this.keterangan,
    required this.tanggal,
    this.createdBy,
    required this.createdAt,
    this.updatedAt,
  });

  int id;
  int produkId;
  String kodeProduk;
  String namaProduk;
  String stokSistem;
  String stokFisik;
  String selisih;
  String? keterangan;
  String tanggal;
  String? createdBy;
  String createdAt;
  String? updatedAt;

  factory StockOpnameModelMysql.fromJson(Map<String, dynamic> json) =>
      StockOpnameModelMysql(
        id: json['id'],
        produkId: json['produk_id'],
        kodeProduk: json['kode_produk'],
        namaProduk: json['nama_produk'],
        stokSistem: json['stok_sistem'].toString(),
        stokFisik: json['stok_fisik'].toString(),
        selisih: json['selisih'].toString(),
        keterangan: json['keterangan'],
        tanggal: json['tanggal'],
        createdBy: json['created_by'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'produk_id': produkId,
        'kode_produk': kodeProduk,
        'nama_produk': namaProduk,
        'stok_sistem': stokSistem,
        'stok_fisik': stokFisik,
        'selisih': selisih,
        'keterangan': keterangan,
        'tanggal': tanggal,
        'created_by': createdBy,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}
