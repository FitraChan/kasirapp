class ShiftModel {
  int? _id;
  int? _userId;
  int? _saldoAwal;
  int? _saldoAkhir;
  int? _uangFisik;
  int? _selisih;
  String? _waktuBuka;
  String? _waktuTutup;
  String? _createdAt;

  // konstruktor versi 1
  ShiftModel(dynamic obj) {
    _id = obj['id'];
    _userId = obj['user_id'];
    _saldoAwal = obj['saldo_awal'];
    _saldoAkhir = obj['saldo_akhir'];
    _uangFisik = obj['uang_fisik'];
    _selisih = obj['selisih'];
    _waktuBuka = obj['waktu_buka'];
    _waktuTutup = obj['waktu_tutup'];
    _createdAt = obj['created_at'];
  }

  // konstruktor versi 2: konversi dari Map
  ShiftModel.fromMap(Map<String, dynamic> map) {
    _id = map['id'];
    _userId = map['user_id'];
    _saldoAwal = int.tryParse(map['saldo_awal']?.toString() ?? '0');
    _saldoAkhir = int.tryParse(map['saldo_akhir']?.toString() ?? '0');
    _uangFisik = int.tryParse(map['uang_fisik']?.toString() ?? '0');
    _selisih = int.tryParse(map['selisih']?.toString() ?? '0');
    _waktuBuka = map['waktu_buka'];
    _waktuTutup = map['waktu_tutup'];
    _createdAt = map['created_at'];
  }

  // Getter
  int? get id => _id;
  int? get userId => _userId;
  int? get saldoAwal => _saldoAwal;
  int? get saldoAkhir => _saldoAkhir;
  int? get uangFisik => _uangFisik;
  int? get selisih => _selisih;
  String? get waktuBuka => _waktuBuka;
  String? get waktuTutup => _waktuTutup;
  String? get created_at => _createdAt;

  // Konversi ke Map untuk SQLite
  Map<String, dynamic> toMap() => {
        'id': _id,
        'user_id': _userId,
        'saldo_awal': _saldoAwal,
        'saldo_akhir': _saldoAkhir,
        'uang_fisik': _uangFisik,
        'selisih': _selisih,
        'waktu_buka': _waktuBuka,
        'waktu_tutup': _waktuTutup,
        'created_at': _createdAt
      };
}

class ShiftModelMysql {
  ShiftModelMysql({
    required this.id,
    required this.userId,
    required this.saldoAwal,
    required this.saldoAkhir,
    required this.uangFisik,
    required this.selisih,
    required this.waktuBuka,
    required this.waktuTutup,
    required this.createdAt,
  });

  int id;
  int userId;
  String saldoAwal;
  String saldoAkhir;
  String uangFisik;
  String selisih;
  String? waktuBuka;
  String? waktuTutup;
  String? createdAt;

  factory ShiftModelMysql.fromJson(Map<String, dynamic> json) =>
      ShiftModelMysql(
        id: json["id"],
        userId: json["user_id"],
        saldoAwal: (json["saldo_awal"] ?? ''),
        saldoAkhir: (json["saldo_akhir"]),
        uangFisik: (json["uang_fisik"]),
        selisih: (json["selisih"]),
        waktuBuka: json["waktu_buka"],
        waktuTutup: json["waktu_tutup"],
        createdAt: json["created_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "saldo_awal": saldoAwal,
        "saldo_akhir": saldoAkhir,
        "uang_fisik": uangFisik,
        "selisih": selisih,
        "waktu_buka": waktuBuka,
        "waktu_tutup": waktuTutup,
        "created_at": createdAt,
      };
}
