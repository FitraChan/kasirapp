class KategoriModel {
  int? _id;
  String? _namaKategori;

  String? _kode;

  String? _createdAt;

  // konstruktor versi 1
  // KategoriModel(this._namaKategori);

  KategoriModel(dynamic obj) {
    _id = obj['id'];
    _namaKategori = obj['nama_kategori'];
    _kode = obj['kode'];
    _createdAt = obj['created_at'];
  }
  // konstruktor versi 2: konversi dari Map ke Contact
  KategoriModel.fromMap(Map<String, dynamic> map) {
    _id = map['id'];
    _namaKategori = map['nama_kategori'];
    _kode = map['kode'];

    _createdAt = map['created_at'];
  }
  //getter dan setter (mengambil dan mengisi data kedalam object)
  // getter
  int? get id => _id;
  String? get nama => _namaKategori;
  String? get created_at => _createdAt;
  String? get kode => _kode;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'nama_kategori': _namaKategori,
        'created_at': _createdAt,
        'kode': _kode
      };
}

class KategoriModelMysql {
  KategoriModelMysql({
    required this.id,
    required this.namaKategori,
    required this.createdAt,
    required this.kode,
  });

  int id;
  String namaKategori;

  String createdAt;

  String kode;

  factory KategoriModelMysql.fromJson(Map<String, dynamic> json) =>
      KategoriModelMysql(
        id: json["id"],
        namaKategori: json["nama_kategori"],
        createdAt: json["created_at"],
        kode: json["kode"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nama_kategori": namaKategori,
        "created_at": createdAt,
        "kode": kode,
      };
}
