class JamKerjaModel {
  int? _id;
  String? _nama;
  String? _jamMasuk;
  String? _jamPulang;
  int? _idMobile;
  int? _idHariMulai;
  int? _idHariSelesai;

  // konstruktor versi 1
  // KategoriModel(this._namaKategori);

  JamKerjaModel(dynamic obj) {
    _id = obj['id'];
    _nama = obj['nama'];
    _jamMasuk = obj['jam_masuk'];
    _jamPulang = obj['jam_pulang'];
    _idMobile = obj['id_mobile'];
    _idHariMulai = obj['id_hari_mulai'];
    _idHariSelesai = obj['id_hari_selesai'];
  }
  // konstruktor versi 2: konversi dari Map ke Contact
  JamKerjaModel.fromMap(Map<String, dynamic> map) {
    _id = map['id'];
    _nama = map['nama'];
    _jamMasuk = map['jam_masuk'];
    _jamPulang = map['jam_pulang'];
    _idMobile = map['id_mobile'];
    _idHariMulai = map['id_hari_mulai'];
    _idHariSelesai = map['id_hari_selesai'];
  }
  //getter dan setter (mengambil dan mengisi data kedalam object)
  // getter
  int? get id => _id;
  String? get nama => _nama;
  String? get jam_masuk => _jamMasuk;
  String? get jam_pulang => _jamPulang;
  int? get idMobile => _idMobile;
  int? get idHariMulai => _idHariMulai;
  int? get idHariSelesai => _idHariSelesai;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'nama': _nama,
        'jam_masuk': _jamMasuk,
        'jam_pulang': _jamPulang,
        'id_mobile': _idMobile,
        'id_hari_mulai': _idHariMulai,
        'id_hari_selesai': _idHariSelesai,
      };
}

class JamKerjaModelMysql {
  JamKerjaModelMysql({
    required this.id,
    required this.nama,
    required this.jamMasuk,
    required this.jamPulang,
    required this.idMobile,
    required this.idHariMulai,
    required this.idHariSelesai,
  });

  String id;
  String nama;
  String jamMasuk;
  String jamPulang;
  String idMobile;
  String idHariMulai;
  String idHariSelesai;

  factory JamKerjaModelMysql.fromJson(Map<String, dynamic> json) =>
      JamKerjaModelMysql(
        id: json["id"],
        nama: json["nama"],
        jamMasuk: json["jam_masuk"],
        jamPulang: json["jam_pulang"],
        idMobile: json["id_mobile"],
        idHariMulai: json["id_hari_mulai"],
        idHariSelesai: json["id_hari_selesai"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nama": nama,
        "jam_masuk": jamMasuk,
        "jam_pulang": jamPulang,
        'id_mobile': idMobile,
        "id_hari_mulai": idHariMulai,
        "id_hari_selesai": idHariSelesai,
      };
}
