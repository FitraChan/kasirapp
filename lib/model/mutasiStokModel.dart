class MutasiStokModel {
  final String tanggal;
  final String namaBarang;
  final String kode;
  final String namaPk;

  final int stokMasuk;
  final int stokKeluar;
  final int stokSebelum;
  final int stokSesudah;

  MutasiStokModel({
    required this.namaPk,
    required this.tanggal,
    required this.namaBarang,
    required this.kode,
    required this.stokMasuk,
    required this.stokKeluar,
    required this.stokSebelum,
    required this.stokSesudah,
  });

  factory MutasiStokModel.fromJson(Map<String, dynamic> json) {
    return MutasiStokModel(
      tanggal: json['tanggal'] ?? '',
      namaPk: json['nama_pk'] ?? '',
      namaBarang: json['nama_barang'] ?? '',
      kode: json['kode'] ?? '',
      stokMasuk: int.tryParse(json['stok_masuk'].toString()) ?? 0,
      stokKeluar: int.tryParse(json['stok_keluar'].toString()) ?? 0,
      stokSebelum: int.tryParse(json['stok_sebelum'].toString()) ?? 0,
      stokSesudah: int.tryParse(json['stok_sesudah'].toString()) ?? 0,
    );
  }
}
