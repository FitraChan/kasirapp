class BarangMasukModel {
  int? id;
  String? noTransaksi;
  String? tanggal;
  String? namaProduk;
  String? namaSupplier;
  String? kodeProduk;

  int? pelangganId;
  int? produkId;
  int? qty;
  double? hargaBeli;
  double? total;
  String? metodePembayaran;
  String? keterangan;
  int? userId;
  String? createdAt;
  String? updatedAt;

  BarangMasukModel({
    this.namaSupplier,
    this.kodeProduk,
    this.id,
    this.noTransaksi,
    this.tanggal,
    this.namaProduk,
    this.pelangganId,
    this.produkId,
    this.qty,
    this.hargaBeli,
    this.total,
    this.metodePembayaran,
    this.keterangan,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'no_transaksi': noTransaksi,
      'kodeProduk': kodeProduk,
      'tanggal': tanggal,
      'nama_barang': namaProduk,
      'nama_supplier': namaSupplier,
      'pelanggan_id': pelangganId,
      'produk_id': produkId,
      'qty': qty,
      'harga_beli': hargaBeli,
      'total': total,
      'metode_pembayaran': metodePembayaran,
      'keterangan': keterangan,
      'user_id': userId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory BarangMasukModel.fromMap(Map<String, dynamic> map) {
    return BarangMasukModel(
      id: map['id'],
      noTransaksi: map['no_transaksi'],
      kodeProduk: map['kode_produk'],
      tanggal: map['tanggal'],
      pelangganId: map['pelanggan_id'],
      namaProduk: map['nama_barang'],
      namaSupplier: map['nama_supplier'],
      produkId: map['produk_id'],
      qty: map['qty'],
      hargaBeli: map['harga_beli'],
      total: map['total'],
      metodePembayaran: map['metode_pembayaran'],
      keterangan: map['keterangan'],
      userId: map['user_id'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }
}
