import 'dart:async';

import 'package:kasirapp/model/shiftModel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'package:intl/intl.dart';
import 'package:kasirapp/model/jamKerjaModel.dart';
import 'package:kasirapp/model/kategoriModel.dart';
import 'package:kasirapp/model/pembayaranModel.dart';
import 'package:kasirapp/model/penerimaanModel.dart';
import 'package:kasirapp/model/pengeluaranModel.dart';
import 'package:kasirapp/model/produkModel.dart';
import 'package:kasirapp/model/subTransaksiDetailPembelianModel.dart';
import 'package:kasirapp/model/transaksiDetailPembelianModel.dart';
import 'package:kasirapp/model/transaksiPembelianModel.dart';

//keterangan status penting :
//1 = pembelian temporary
//2 = barang sudah di beli
//3 = pengembalian barang
//4 = pengeluaran barang

//keterangan status detail pembelian
//1 : belum lunas, 2 : telah lunas 3 : sudah pesan tapi belum lunas, 4: barang retur, 5: Hutang

class KasirHelper {
  static final KasirHelper instance = KasirHelper.internal();
  factory KasirHelper() => instance;

  KasirHelper.internal();
  static Database? db;

  static const tb_kategori = 'tb_kategori';

  void _createDb(Database db, int version) async {
    await db.execute('''
    CREATE TABLE $tb_kategori(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_kategori TEXT DEFAULT NULL,
        kode varchar(20) DEFAULT NULL,
        created_at DATE DEFAULT NULL,
        is_sync INTEGER DEFAULT NULL,
        deleted_at TEXT DEFAULT NULL           
      )
      ''');

    await db.execute('''
      CREATE TABLE tb_produk(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kode varchar(20) DEFAULT NULL,
        nama_barang varchar(100) DEFAULT NULL,
        id_kategori INTEGER DEFAULT NULL,
        id_pk INTEGER DEFAULT NULL,
        harga_jual INTEGER DEFAULT NULL,
        harga_grosir INTEGER DEFAULT NULL,
        harga_beli INTEGER DEFAULT NULL,
        harga_shopee_food INTEGER DEFAULT NULL,
        harga_go_food INTEGER DEFAULT NULL,
        stok INTEGER DEFAULT NULL,
        satuan varchar(20) DEFAULT NULL,
        gambar varchar(200) DEFAULT NULL,
        created_at DATE DEFAULT NULL,
        tanggal_sekarang DATETIME NULL,
        is_sync INTEGER DEFAULT NULL,
        keterangan TEXT DEFAULT NULL,   
        updated_at TEXT DEFAULT NULL,      
   
        deleted_at TEXT DEFAULT NULL               
                     
      )
    ''');

    await db.execute('''
      CREATE TABLE tb_transaksi_pembelian(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        keterangan varchar(100) DEFAULT NULL,
        total INTEGER DEFAULT NULL,    
        id_pembeli INTEGER DEFAULT NULL,          
        status_bayar INTEGER DEFAULT NULL,
        id_delivery INTEGER DEFAULT NULL,
        created_at DATETIME DEFAULT NULL,
        is_sync INTEGER DEFAULT NULL,
        id_pelanggan INTEGER DEFAULT NULL,
        total_hutang INTEGER DEFAULT NULL,
        total_bayar INTEGER DEFAULT NULL,
        sisa_hutang INTEGER DEFAULT NULL,
        kode_transaksi varchar(100) DEFAULT NULL,
        shift_id INTEGER DEFAULT NULL


      )
    ''');

    await db.execute('''
      CREATE TABLE tb_detail_transaksi_pembelian(        
        id_transaksi INTEGER DEFAULT NULL,
        id_sub_transaksi INTEGER DEFAULT NULL,    
        id_barang varchar(100) DEFAULT NULL,  
        harga INTEGER DEFAULT NULL,
        diskon INTEGER DEFAULT NULL,
        status INTEGER DEFAULT NULL,     
        total INTEGER DEFAULT NULL,           
        qty INTEGER DEFAULT NULL,
        id_delivery INTEGER DEFAULT NULL,
        created_at DATETIME DEFAULT NULL,
        catatan varchar(100) DEFAULT NULL,
        is_sync INTEGER DEFAULT NULL,       
        kode_transaksi varchar(100) DEFAULT NULL,  
        id_komisi INTEGER DEFAULT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE tb_pembayaran(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dibayar INTEGER DEFAULT NULL,
        kembalian INTEGER DEFAULT NULL,       
        total INTEGER DEFAULT NULL,    
        id_transaksi INTEGER DEFAULT NULL,         
        created_at DATETIME DEFAULT NULL             
      )
    ''');
    await db.execute('''
      CREATE TABLE tb_pengeluaran(        
        id INTEGER PRIMARY KEY AUTOINCREMENT,      
        nilai INTEGER DEFAULT NULL,
        keterangan INTEGER DEFAULT NULL,
        status INTEGER DEFAULT NULL,        
        created_at DATETIME DEFAULT NULL,
        is_sync INTEGER DEFAULT NULL,
         shift_id INTEGER DEFAULT NULL   
      )
    ''');

    await db.execute('''
      CREATE TABLE tb_penerimaan(        
        id INTEGER PRIMARY KEY AUTOINCREMENT,      
        nilai INTEGER DEFAULT NULL,
        keterangan INTEGER DEFAULT NULL,
        status INTEGER DEFAULT NULL,        
        created_at DATETIME DEFAULT NULL,
        is_sync INTEGER DEFAULT NULL,
        shift_id INTEGER DEFAULT NULL   
            
      )
    ''');
// tipe 1 = keluar, 2 = masuk
    await db.execute('''
      CREATE TABLE tb_kas_harian (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tanggal TEXT NULL,
        tipe INTEGER NULL, 
        kategori INTEGER NULL,
        referensi_id varchar(100) NULL,
        sumber TEXT NULL,
        keterangan TEXT NULL,
        jumlah REAL NULL,
        is_sync INTEGER DEFAULT NULL,
        metode_pembayaran TEXT NULL, 
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        deleted_at TEXT
      );
      ''');

    await db.execute('''
      CREATE TABLE tb_jam_kerja(        
        id INTEGER PRIMARY KEY AUTOINCREMENT,      
        nama varchar(100) DEFAULT NULL,
        id_hari_mulai INTEGER DEFAULT NULL,
        id_hari_selesai INTEGER DEFAULT NULL,
        jam_masuk varchar(100) DEFAULT NULL,
        jam_pulang varchar(100) DEFAULT NULL,
        id_mobile INTEGER DEFAULT NULL 
        
      )
    ''');

    await db.execute('''
      CREATE TABLE tb_sub_detail_transaksi_pembelian(  
        id_sub_transaksi INTEGER DEFAULT NULL,
        id_transaksi INTEGER DEFAULT NULL,            
        id_barang INTEGER DEFAULT NULL,  
        harga INTEGER DEFAULT NULL,
        diskon INTEGER DEFAULT NULL,
        status INTEGER DEFAULT NULL,        
        qty INTEGER DEFAULT NULL,   
        created_at DATETIME DEFAULT NULL,
        is_sync INTEGER DEFAULT NULL
               
      )
    ''');

    await db.execute('''
  CREATE TABLE tb_pengembalian (
    id INTEGER PRIMARY KEY,
    kode TEXT DEFAULT NULL,
    id_transaksi INTEGER DEFAULT NULL,
    id_pelanggan INTEGER DEFAULT NULL,
    total INTEGER DEFAULT NULL,
    keterangan TEXT DEFAULT NULL,
    created_at TEXT DEFAULT NULL,
    updated_at TEXT DEFAULT NULL
  )
''');

    await db.execute('''
      CREATE TABLE tb_detail_pengembalian (   
        id_pengembalian INTEGER DEFAULT NULL,
        id_produk INTEGER DEFAULT NULL,
        jumlah INTEGER DEFAULT NULL,
        harga INTEGER DEFAULT NULL,
        sub_total INTEGER DEFAULT NULL,
        created_at TEXT DEFAULT NULL,
        updated_at TEXT DEFAULT NULL
      )
    ''');

    await db.execute('''
              CREATE TABLE pelanggan (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama TEXT DEFAULT NULL,
            no_hp TEXT DEFAULT NULL,
            alamat TEXT DEFAULT NULL,
            kode TEXT DEFAULT NULL,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP,
            updated_at TEXT DEFAULT CURRENT_TIMESTAMP
          )
      ''');

    await db.execute('''
      CREATE TABLE tb_hutang(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total_hutang INTEGER DEFAULT NULL,
        total_bayar INTEGER DEFAULT NULL,       
        sisa_hutang INTEGER DEFAULT NULL,    
        id_transaksi INTEGER DEFAULT NULL,    
        is_sync INTEGER DEFAULT NULL,     
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP            
             
      )
    ''');

    await db.execute('''
  CREATE TABLE konfigurasi(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nama TEXT DEFAULT NULL,
    kode_toko varchar(100) DEFAULT NULL,
    status INTEGER DEFAULT NULL,
    created_at DATE DEFAULT NULL
  )
''');

    await db!.execute('''
      CREATE TABLE tb_stok_mutasi (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        produk_id INTEGER NULL,
        tipe TEXT NULL, -- masuk / keluar
        sumber TEXT NULL, -- penjualan / barang_masuk / retur
        ref_id varchar(100) NULL,
        qty REAL NULL,
        stok_sebelum REAL NULL,
        stok_sesudah REAL NULL,
        is_sync INTEGER DEFAULT NULL,
        tanggal TEXT NULL,
        created_at created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
      ''');

    await db.execute('''
      CREATE TABLE tb_komisi_penjualan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_transaksi INTEGER DEFAULT NULL,
        id_user INTEGER DEFAULT NULL,
        total_transaksi INTEGER DEFAULT NULL,
        persen_komisi INTEGER DEFAULT 0,
        nominal_komisi INTEGER DEFAULT NULL,
        status_bayar INTEGER DEFAULT 0,
        is_sync INTEGER DEFAULT NULL,  
        shift_id INTEGER DEFAULT NULL,     
   

        created_at TEXT DEFAULT (datetime('now','localtime'))
      )
    ''');

    await db!.execute('''
    CREATE TABLE tb_pk_ac(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT DEFAULT NULL,       
        created_at DATE DEFAULT NULL,
        updated_at TEXT DEFAULT NULL           
      )
      ''');

    await db.execute('''
CREATE TABLE barang_masuk (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    no_transaksi TEXT DEFAULT NULL,
    tanggal TEXT DEFAULT NULL,   
    produk_id INTEGER DEFAULT NULL,
    qty INTEGER DEFAULT NULL,
    harga_beli REAL DEFAULT NULL,
    total REAL DEFAULT NULL,
    metode_pembayaran INTEGER DEFAULT NULL,
    keterangan TEXT DEFAULT NULL,
    is_sync INTEGER DEFAULT NULL,   
    kode_supplier TEXT DEFAULT NULL, 
    kode_produk varchar(100) DEFAULT NULL,
  

    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP     
)
''');

    await db.execute('''
          CREATE TABLE supplier (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          kode_supplier TEXT NULL UNIQUE,
          nama TEXT DEFAULT NULL,
          kontak_person TEXT DEFAULT NULL,
          no_hp TEXT DEFAULT NULL,
          email TEXT DEFAULT NULL,
          alamat TEXT DEFAULT NULL,
          kota TEXT DEFAULT NULL,
          id_toko INTEGER DEFAULT NULL,
          is_sync INTEGER DEFAULT 0,
          created_at TEXT DEFAULT NULL,
          updated_at TEXT DEFAULT NULL,
          deleted_at TEXT DEFAULT NULL
      );
      ''');

    await db.transaction((txn) async {
      await txn.insert(
          'konfigurasi', {'nama': 'field kategori', 'status': 1, 'id': 1});
      await txn.insert('konfigurasi',
          {'nama': 'field pencarian produk', 'status': 1, 'id': 2});

      await txn.insert('konfigurasi', {'nama': 'stok', 'status': 1, 'id': 3});
      await txn.insert('konfigurasi',
          {'nama': 'kategori dalam container', 'status': 1, 'id': 4});
    });

    await db.execute('''
      CREATE TABLE tb_shift(        
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER,
          saldo_awal DECIMAL(15,2) DEFAULT 0.00,
          saldo_akhir DECIMAL(15,2) DEFAULT 0.00,
          uang_fisik DECIMAL(15,2) DEFAULT 0.00,
          selisih DECIMAL(15,2) DEFAULT 0.00,
          
          waktu_buka DATETIME DEFAULT CURRENT_TIMESTAMP,
          waktu_tutup DATETIME DEFAULT CURRENT_TIMESTAMP,
          created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
          updated_at DATETIME DEFAULT CURRENT_TIMESTAMP     
            )
    ''');

    await db!.execute('''

CREATE TABLE tb_hutang_supplier (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    barang_masuk_id INTEGER  NULL,
    kode_supplier TEXT  NULL,
    kode_hutang TEXT  NULL,
    total REAL  NULL,
    dibayar REAL DEFAULT 0,
    sisa REAL  NULL,
    status TEXT DEFAULT 'hutang', 
    jatuh_tempo TEXT,
    is_sync INTEGER DEFAULT NULL,
    created_at TEXT NULL,
    updated_at TEXT NULL
);

    ''');

    await db!.execute('''
CREATE TABLE tb_bayar_hutang_supplier (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    hutang_id INTEGER  NULL,
    kode_hutang TEXT  NULL,
    tanggal TEXT  NULL,
    jumlah_bayar REAL  NULL,
    keterangan TEXT,
    is_sync INTEGER DEFAULT NULL,
    created_at TEXT NULL,
    updated_at TEXT NULL
)

    ''');

    await db!.execute('''
      CREATE TABLE tb_stock_opname (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        produk_id INTEGER NULL,
        kode_produk TEXT NULL,
        nama_produk TEXT NULL,
        stok_sistem REAL NULL,
        stok_fisik REAL NULL,
        selisih REAL NULL,
        keterangan TEXT,
        tanggal TEXT NULL,
        created_by TEXT NULL,
        is_sync INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE stok_opname (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nama_karyawan TEXT,
          nama_rak TEXT,
          tanggal TEXT,
          is_sync INTEGER DEFAULT 0,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE produk_gudang (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_stok_opname INTEGER DEFAULT NULL,
        kode_item TEXT DEFAULT NULL,
        kode_barcode TEXT DEFAULT NULL,
        nama_item TEXT DEFAULT NULL,
        stok TEXT DEFAULT '0',
        waktu_scan TEXT DEFAULT NULL,
        is_sync INTEGER DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  Future<Database?> createDatabase() async {
    if (db != null) {
      // deleteDatabase('kasir.db');
      return db;
    }
    //define the path to the database
    String path = join(await getDatabasesPath(), 'kasir.db');
    print(path);
    db = await openDatabase(path, version: 2, onCreate: _createDb,
        onUpgrade: (Database db, int oldV, int newV) async {
      if (oldV < 2) {
        await db.execute('''
      CREATE TABLE IF NOT EXISTS stok_opname (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nama_karyawan TEXT,
          nama_rak TEXT,
          tanggal TEXT,
          is_sync INTEGER DEFAULT 0,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

        var columns = await db.rawQuery("PRAGMA table_info(produk_gudang)");

        bool exists = columns.any(
          (col) => col['name'] == 'id_stok_opname',
        );

        if (!exists) {
          await db.execute(
            "ALTER TABLE produk_gudang ADD COLUMN id_stok_opname INTEGER DEFAULT NULL",
          );
        }
      }
    });
    return db;
  }

  Future<String> generateKodeKategori() async {
    Database? db = await createDatabase();

    final result = await db!.rawQuery(
      "SELECT kode FROM tb_kategori ORDER BY id DESC LIMIT 1",
    );

    if (result.isEmpty) {
      return "KTG001";
    }

    String lastKode = result.first['kode'].toString();

    int number = int.parse(lastKode.replaceAll('KTG', ''));

    number++;

    return 'KTG${number.toString().padLeft(3, '0')}';
  }

  Future<int> createKategori(KategoriModel kat) async {
    Database? db = await createDatabase();

    return db!.insert('tb_kategori', kat.toMap());
  }

  Future<int> createShift(ShiftModel kat) async {
    Database? db = await createDatabase();

    return db!.insert('tb_shift', kat.toMap());
  }

  Future<int> createProduk(ProdukModel kat) async {
    Database? db = await createDatabase();

    return db!.insert('tb_produk', kat.toMap());
  }

  Future<int> createTransaksiPembelian(TransaksiPembelianModel kat) async {
    Database? db = await createDatabase();

    int id = await db!.insert('tb_transaksi_pembelian', kat.toMap());

    await db.insert('tb_kas_harian', {
      'tipe': 2,
      'sumber': 'barang_keluar',
      'referensi_id': id,
      'jumlah': kat.total,
      'keterangan': 'Penjualan Barang',
      'tanggal': DateTime.now().toString(),
    });

    return id;
  }

  Future<List> idPembelian() async {
    Database? db = await createDatabase();

    return db!.rawQuery('select max(id) as id from tb_transaksi_pembelian');
    //  print(db?.path);
    // return db!.query('tb_transaksi_pembelian');
  }

  Future<List> pembayaran(idTrans) async {
    Database? db = await createDatabase();

    return db!.rawQuery(
        'select * from tb_pembayaran where id_transaksi = ?', [idTrans]);
    //  print(db?.path);
    // return db!.query('tb_transaksi_pembelian');
  }

  Future<List> listTransaksi(tanggal) async {
    Database? db = await createDatabase();

    // await db!.execute('''
    //   CREATE TABLE tb_pengeluaran(
    //     id_transaksi INTEGER DEFAULT NULL,

    //     nilai INTEGER DEFAULT NULL,
    //     keterangan INTEGER DEFAULT NULL,
    //     status INTEGER DEFAULT NULL,
    //     created_at DATETIME DEFAULT NULL
    //   )
    // ''');

    // db!.rawQuery('delete from tb_detail_transaksi_pembelian');
    // db.rawQuery('delete from tb_transaksi_pembelian');
    // db.rawQuery('delete from tb_pembayaran');
    //   db!.rawQuery("ALTER TABLE tb_produk IF EXISTS DROP COLUMN gambar");

    // db!.rawQuery(
    //     "ALTER TABLE tb_produk ADD COLUMN gambar varchar(100) DEFAULT NULL");

    if (tanggal != null) {
      var mulai = tanggal + " 00:00:00";

      var selesai = tanggal + " 23:59:59";
      return db!.rawQuery(
          "select a.total,  a.id , a.created_at, b.status,c.nama_barang, b.catatan from tb_transaksi_pembelian a left join tb_detail_transaksi_pembelian b on a.id = b.id_transaksi  LEFT JOIN tb_produk c on c.kode = b.id_barang  where a.created_at BETWEEN '$mulai' and '$selesai' group by a.id");
    } else {
      var date = DateTime.parse(DateTime.now().toString());

      var tanggalNow = DateFormat('yyyy-MM-dd').format(date);
      var mulaiNow = "$tanggalNow 00:00:00";
      var selesaiNow = "$tanggalNow 23:59:59";

      return db!.rawQuery(
          "select a.total,  a.id , a.created_at, b.status,c.nama_barang, b.catatan from tb_transaksi_pembelian a left join tb_detail_transaksi_pembelian b on a.id = b.id_transaksi  LEFT JOIN tb_produk c on c.kode = b.id_barang where a.created_at BETWEEN '$mulaiNow' and '$selesaiNow' group by a.id");
    }
  }

  Future<List> listTransaksiPemesananDidepan(tanggal) async {
    Database? db = await createDatabase();

    if (tanggal != null) {
      var mulai = tanggal + " 00:00:00";

      var selesai = tanggal + " 23:59:59";
      return db!.rawQuery(
          "select a.total,  a.id , a.created_at, b.status,b.harga ,c.nama_barang,b.id_delivery ,b.catatan,status,a.keterangan from tb_transaksi_pembelian a left join tb_detail_transaksi_pembelian b on a.id = b.id_transaksi  LEFT JOIN tb_produk c on c.kode = b.id_barang  where a.created_at BETWEEN '$mulai' and '$selesai' and status = 3 group by a.id");
    } else {
      var date = DateTime.parse(DateTime.now().toString());

      var tanggalNow = DateFormat('yyyy-MM-dd').format(date);
      var mulaiNow = "$tanggalNow 00:00:00";
      var selesaiNow = "$tanggalNow 23:59:59";

      return db!.rawQuery('''
          select a.total, a.status_bayar , a.id , a.created_at,b.harga ,b.status,c.nama_barang, b.catatan, status, a.keterangan from tb_transaksi_pembelian a left join tb_detail_transaksi_pembelian b on a.id = b.id_transaksi  LEFT JOIN tb_produk c on c.id = b.id_barang where a.created_at BETWEEN '$mulaiNow' and '$selesaiNow' and  status = 3 group by a.id
          ''');
    }
  }

  Future<List> listDetailTransaksi(id) async {
    Database? db = await createDatabase();

    return db!.rawQuery(
        "select a.total,b.qty, c.harga_jual,b.harga, harga_shopee_food,harga_go_food, a.id , a.created_at, b.status,c.nama_barang,b.id_delivery, b.catatan,a.keterangan,b.id_sub_transaksi, b.id_transaksi from tb_transaksi_pembelian a left join tb_detail_transaksi_pembelian b on a.id = b.id_transaksi  LEFT JOIN tb_produk c on c.id = b.id_barang where b.id_transaksi = '$id' ");

    // return db!.rawQuery(
    //     "select sum(b.harga) as total ,b.qty, c.harga_jual, b.id_transaksi , b.created_at, b.status,c.nama_barang, b.catatan from tb_detail_transaksi_pembelian b LEFT JOIN tb_produk c on c.id = b.id_barang here b.id_transaksi = '$id' ");
  }

  Future<List> listPengeluaran(tanggal) async {
    Database? db = await createDatabase();

    // db!.rawQuery('delete from tb_detail_transaksi_pembelian');
    // db.rawQuery('delete from tb_transaksi_pembelian');
    // db.rawQuery('delete from tb_pembayaran');

    if (tanggal != null) {
      var mulai = tanggal + " 00:00:00";

      var selesai = tanggal + " 23:59:59";
      return db!.rawQuery(
          "select a.total,  a.id , a.created_at, b.status from tb_transaksi_pembelian a left join tb_detail_transaksi_pembelian b on a.id = b.id_transaksi  where a.created_at BETWEEN '$mulai' and '$selesai' and b.status = 4");
    } else {
      var date = DateTime.parse(DateTime.now().toString());

      var tanggalNow = DateFormat('yyyy-MM-dd').format(date);
      var mulaiNow = "$tanggalNow 00:00:00";
      var selesaiNow = "$tanggalNow 23:59:59";

      return db!.rawQuery(
          "select a.total,  a.id , a.created_at, b.status from tb_transaksi_pembelian a left join tb_detail_transaksi_pembelian b on a.id = b.id_transaksi where a.created_at BETWEEN '$mulaiNow' and '$selesaiNow' and b.status = 4");
    }
  }

  Future<List> listPenjualanToday(tanggalMulai, tanggalSelesai) async {
    Database? db = await createDatabase();

    //if (tanggal != null) {
    var mulai = tanggalMulai + " 00:00:00";

    var selesai = tanggalSelesai + " 23:59:59";
    return db!.rawQuery(
        "select sum(a.total) as total, a.created_at from tb_transaksi_pembelian a where a.created_at between '$mulai' and '$selesai' group by strftime('%Y-%m-%d',a.created_at)");
    //}

    //  else {
    //   var date = DateTime.parse(DateTime.now().toString());

    //   var tanggalNow = DateFormat('yyyy-MM-dd').format(date);
    //   var mulaiNow = tanggalNow + " 00:00:00";
    //   var selesaiNow = tanggalNow + " 23:59:59";

    //   return db!.rawQuery(
    //       "select sum(a.total) as total,  a.id , a.created_at from tb_transaksi_pembelian a where a.created_at BETWEEN '$mulaiNow' and '$selesaiNow' group by strftime('%Y/%m/%d','a.created_at')");
    // }
  }

  //  Future<int> tapTotalPembelian(id) async {
  //   final List<Map<String, dynamic>> result = await db!
  //       .rawQuery("SELECT  total FROM tb_transaksi_pembelian where id = '$id'");

  //   return result[0]['total'] ?? 0;
  // }

  Future<int> totPenjualanHariIni(tglSearch, statusBayar) async {
    Database? db = await createDatabase();

    var mulaiNow;
    var selesaiNow;

    if (tglSearch != null) {
      mulaiNow = tglSearch + " 00:00:00";
      selesaiNow = tglSearch + " 23:59:59";
    } else {
      var date = DateTime.parse(DateTime.now().toString());
      var tanggalNow = DateFormat('yyyy-MM-dd').format(date);
      mulaiNow = "$tanggalNow 00:00:00";
      selesaiNow = "$tanggalNow 23:59:59";
    }

    final List<Map<String, dynamic>> result;

    if (statusBayar == 0) {
      result = await db!.rawQuery(
          "select sum(qty * harga_jual) as tot_harga from tb_detail_transaksi_pembelian a left join tb_produk b on a.id_barang = b.id left join tb_transaksi_pembelian c on c.id = a.id_transaksi where c.created_at between '$mulaiNow' and '$selesaiNow'");
    } else {
      result = await db!.rawQuery(
          "select sum(qty * harga_jual) as tot_harga from tb_detail_transaksi_pembelian a left join tb_produk b on a.id_barang = b.id left join tb_transaksi_pembelian c on c.id = a.id_transaksi where c.created_at between '$mulaiNow' and '$selesaiNow' and c.status_bayar = '$statusBayar'");
    }

    return result[0]['tot_harga'] ?? 0;
  }

  Future<List> totPenjualanBulanIni(bulan) async {
    Database? db = await createDatabase();
    // db!.rawQuery('delete from tb_detail_transaksi_pembelian');
    // db.rawQuery('delete from tb_transaksi_pembelian');
    // db.rawQuery('delete from tb_pembayaran');
    // db.rawQuery('delete from tb_pengeluaran');
    // db.rawQuery('delete from tb_penerimaan');

    String month;
    if (bulan != null) {
      var date = DateTime.parse(bulan);

      month = DateFormat('yyyy-MM').format(date);
    } else {
      var date = DateTime.parse(DateTime.now().toString());

      month = DateFormat('yyyy-MM').format(date);
    }

    return db!.rawQuery(
        "select a.harga, a.id_barang, a.qty,a.status,a.diskon ,b.kode,b.stok, b.nama_barang,b.harga_jual,sum(qty * harga_jual) as tot_harga from tb_detail_transaksi_pembelian a left join tb_produk b on a.id_barang = b.id left join tb_transaksi_pembelian c on c.id = a.id_transaksi where strftime('%Y-%m',c.created_at) = '$month'");
    // }
  }

  Future<List> totPenjualanTerbanyakBulanIni(bulan) async {
    Database? db = await createDatabase();

    String month;
    if (bulan != null) {
      var date = DateTime.parse(bulan);

      month = DateFormat('yyyy-MM').format(date);
    } else {
      var date = DateTime.parse(DateTime.now().toString());

      month = DateFormat('yyyy-MM').format(date);
    }

    return db!.rawQuery(
        "SELECT  b.id_barang, gambar, sum(qty), harga_jual FROM tb_detail_transaksi_pembelian b left join tb_produk c on c.id = b.id_barang  where strftime('%Y-%m',c.created_at) = '$month' group by id_barang order by sum(qty) desc");
    // }
  }

  Future<List> totPengeluaran(tglSearch) async {
    Database? db = await createDatabase();

    var mulaiNow;
    var selesaiNow;

    // db!.rawQuery('delete from tb_pengeluaran');
    // db.rawQuery('delete from tb_penerimaan');

    if (tglSearch != null) {
      var date = DateTime.parse(tglSearch.toString());
      var tanggalCari = DateFormat('dd-MM-yyyy').format(date);
      mulaiNow = tanggalCari;
      selesaiNow = tanggalCari + " 23:59:59";
    } else {
      var date = DateTime.parse(DateTime.now().toString());

      var tanggalNow = DateFormat('dd-MM-yyyy').format(date);
      mulaiNow = "$tanggalNow";
      selesaiNow = "$tanggalNow 23:59:59";
    }

    return db!.rawQuery(
        "select sum(nilai) as tot, keterangan, created_at from tb_pengeluaran where created_at between '$mulaiNow' and '$selesaiNow'");

    //return db!.rawQuery("select * from tb_pengeluaran");
  }

  Future<List> laporanListPengeluaran(tglSearch) async {
    Database? db = await createDatabase();

    var mulaiNow;
    var selesaiNow;

    // db!.rawQuery('delete from tb_pengeluaran');
    // db.rawQuery('delete from tb_penerimaan');

    if (tglSearch != null) {
      mulaiNow = tglSearch + " 00:00:00";
      selesaiNow = tglSearch + " 23:59:59";
    } else {
      var date = DateTime.parse(DateTime.now().toString());

      var tanggalNow = DateFormat('yyyy-MM-dd').format(date);
      mulaiNow = "$tanggalNow 00:00:00";
      selesaiNow = "$tanggalNow 23:59:59";
    }

    return db!.rawQuery(
        "select * from tb_pengeluaran where created_at between '$mulaiNow' and '$selesaiNow'");

    //return db!.rawQuery("select * from tb_pengeluaran");
  }

  Future<List> totPengeluaranBulanIni(bulan) async {
    Database? db = await createDatabase();

    String month;
    if (bulan != null) {
      var date = DateTime.parse(bulan);

      month = DateFormat('MM-yyyy').format(date);
    } else {
      var date = DateTime.parse(DateTime.now().toString());

      month = "%${DateFormat('MM-yyyy').format(date)}%";
    }

    final pengeluaran = await db!.rawQuery('''
    SELECT keterangan,
      SUM(nilai) as tot,
      DATE(created_at) as tanggal
    FROM tb_pengeluaran
    WHERE created_at LIKE ?
  
    ORDER BY tanggal ASC
  ''', [month]);

    return pengeluaran;

    // return db!.rawQuery(
    //     "select sum(nilai) as tot, keterangan, created_at from tb_pengeluaran where strftime('%Y-%m',created_at) = '$month'");
  }

  Future<List> totPenerimaan(tglSearch) async {
    Database? db = await createDatabase();

    var mulaiNow;
    var selesaiNow;

    if (tglSearch != null) {
      var date = DateTime.parse(tglSearch.toString());
      var tanggalCari = DateFormat('dd-MM-yyyy').format(date);
      mulaiNow = tanggalCari;
      selesaiNow = tanggalCari + " 23:59:59";
    } else {
      var date = DateTime.parse(DateTime.now().toString());

      var tanggalNow = DateFormat('dd-MM-yyyy').format(date);
      mulaiNow = "$tanggalNow";
      selesaiNow = "$tanggalNow 23:59:59";
    }

    return db!.rawQuery(
        "select sum(nilai) as tot, keterangan, created_at from tb_penerimaan where created_at between '$mulaiNow' and '$selesaiNow'");
  }

  Future<List> totPenerimaanBulanIni(bulan) async {
    Database? db = await createDatabase();

    String month;
    if (bulan != null) {
      var date = DateTime.parse(bulan);

      month = DateFormat('MM-yyyy').format(date);
    } else {
      var date = DateTime.parse(DateTime.now().toString());

      month = "%${DateFormat('MM-yyyy').format(date)}%";
    }

    final penerimaan = await db!.rawQuery('''
    SELECT keterangan,
      SUM(nilai) as tot,
      DATE(created_at) as tanggal
    FROM tb_penerimaan
    WHERE created_at LIKE ?
  
    ORDER BY tanggal ASC
  ''', [month]);

    return penerimaan;

    // return db!.rawQuery(
    //     "select sum(nilai) as tot, keterangan, created_at from tb_penerimaan where  created_at like '%$month%'");
  }

  Future<List> listPenjualanHariIni(tglSearch, statusBayar) async {
    Database? db = await createDatabase();

    var mulaiNow;
    var selesaiNow;

    if (tglSearch != null) {
      mulaiNow = tglSearch + " 00:00:00";
      selesaiNow = tglSearch + " 23:59:59";
    } else {
      var date = DateTime.parse(DateTime.now().toString());

      var tanggalNow = DateFormat('yyyy-MM-dd').format(date);
      mulaiNow = "$tanggalNow 00:00:00";
      selesaiNow = "$tanggalNow 23:59:59";
    }

    if (statusBayar == 0) {
      return db!.rawQuery(
          "select status_bayar, a.kode_transaksi, sum(a.qty) as qty,b.nama_barang,sum(qty * harga_jual) as tot_harga, a.created_at from tb_detail_transaksi_pembelian a left join tb_transaksi_pembelian c on c.id = a.id_transaksi left join  tb_produk b on a.id_barang = b.id   where c.created_at between '$mulaiNow' and '$selesaiNow' group by id_transaksi, a.id_barang");
    } else {
      // return db!.rawQuery(
      //     "select a.harga, a.id_barang,  sum(a.qty) as qty,a.status,a.diskon ,b.kode,b.stok, b.nama_barang,b.harga_jual,(qty * harga_jual) as tot_harga from tb_detail_transaksi_pembelian a left join tb_transaksi_pembelian c on c.id = a.id_transaksi left join  tb_produk b on a.id_barang = b.id   where c.created_at between '$mulaiNow' and '$selesaiNow'");

      return db!.rawQuery(
          "select status_bayar, a.kode_transaksi, sum(a.qty) as qty,b.nama_barang,sum(qty * harga_jual) as tot_harga, a.created_at from tb_detail_transaksi_pembelian a left join tb_transaksi_pembelian c on c.id = a.id_transaksi left join  tb_produk b on a.id_barang = b.id   where c.created_at between '$mulaiNow' and '$selesaiNow'  and c.status_bayar = '$statusBayar' group by id_transaksi,a.id_barang");
    }
  }

  Future<List> listPenjualanBulanIni(bulan) async {
    Database? db = await createDatabase();

    String month;
    if (bulan != null) {
      var date = DateTime.parse(bulan);

      month = DateFormat('yyyy-MM').format(date);
    } else {
      var date = DateTime.parse(DateTime.now().toString());

      month = DateFormat('yyyy-MM').format(date);
    }

    return db!.rawQuery(
        "select  sum((b.harga_jual - b.harga_beli) * qty) as total,sum(qty * b.harga_jual) as nilai ,strftime('%d-%m-%Y',c.created_at) as tanggal  from tb_detail_transaksi_pembelian a left join tb_transaksi_pembelian c on c.id = a.id_transaksi left join  tb_produk b on a.id_barang = b.id   where strftime('%Y-%m',c.created_at) = '$month'  and a.status = 2  group by strftime('%Y-%m-%d',c.created_at)");
    // }
  }

  Future<List> listKeuntunganToday(tanggalMulai, tanggalSelesai) async {
    Database? db = await createDatabase();

    //if (tanggal != null) {
    var mulai = tanggalMulai + " 00:00:00";

    var selesai = tanggalSelesai + " 23:59:59";
    return db!.rawQuery(
        "select sum((b.harga_jual - b.harga_beli) * qty) as total, a.created_at from tb_transaksi_pembelian a left join   tb_detail_transaksi_pembelian c on c.id_transaksi = a.id  left join tb_produk b on b.id = c.id_barang where a.created_at between '$mulai' and '$selesai' group by strftime('%Y-%m-%d',a.created_at)");
  }

  Future<List> listKeuntunganHariIni(tglSearch) async {
    Database? db = await createDatabase();

    var mulaiNow;
    var selesaiNow;

    if (tglSearch != null) {
      mulaiNow = tglSearch + " 00:00:00";
      selesaiNow = tglSearch + " 23:59:59";
    } else {
      var date = DateTime.parse(DateTime.now().toString());

      var tanggalNow = DateFormat('yyyy-MM-dd').format(date);
      mulaiNow = "$tanggalNow 00:00:00";
      selesaiNow = "$tanggalNow 23:59:59";
    }

    return db!.rawQuery(
        "select sum((b.harga_jual - b.harga_beli) * qty) as total, a.created_at from tb_transaksi_pembelian a left join   tb_detail_transaksi_pembelian c on c.id_transaksi = a.id  left join tb_produk b on b.id = c.id_barang where a.created_at between '$mulaiNow' and '$selesaiNow' and c.status = 2 group by strftime('%Y-%m-%d',a.created_at)");
  }

  Future<List> listKeuntunganBulanIni(bulan) async {
    Database? db = await createDatabase();

    String month;
    if (bulan != null) {
      var date = DateTime.parse(bulan);

      month = DateFormat('yyyy-MM').format(date);
    } else {
      var date = DateTime.parse(DateTime.now().toString());

      month = DateFormat('yyyy-MM').format(date);
    }

    return db!.rawQuery(
        "select sum((b.harga_jual - b.harga_beli) * qty) as total, a.created_at from tb_transaksi_pembelian a left join   tb_detail_transaksi_pembelian c on c.id_transaksi = a.id  left join tb_produk b on b.id = c.id_barang  where strftime('%Y-%m',a.created_at) = '$month'");
  }

  Future<List> idProd() async {
    Database? db = await createDatabase();

    //if (tanggal != null) {

    return db!.rawQuery("select id from tb_produk order by id desc limit 1 ");
  }

  Future<List> listPembayaranToday(tanggalMulai, tanggalSelesai) async {
    Database? db = await createDatabase();

    //if (tanggal != null) {
    var mulai = tanggalMulai + " 00:00:00";

    var selesai = tanggalSelesai + " 23:59:59";
    return db!.rawQuery(
        "select sum( c.harga ) as total, a.created_at from tb_transaksi_pembelian a left join   tb_detail_transaksi_pembelian c on c.id_transaksi = a.id  left join tb_produk b on b.id = c.id_barang where a.created_at between '$mulai' and '$selesai' group by strftime('%Y-%m-%d',a.created_at)");
  }

  Future<int> createDetailTransaksiPembelian(
      TransaksiDetailPembelianModel kat) async {
    Database? db = await createDatabase();

    return db!.insert('tb_detail_transaksi_pembelian', kat.toMap());
  }

  Future<int> createSubDetailTransaksiPembelian(
      SubTransaksiDetailPembelianModel kat) async {
    Database? db = await createDatabase();

    return db!.insert('tb_sub_detail_transaksi_pembelian', kat.toMap());
  }

  Future<int> updateListDetailTransaksiPembelian(
      idTrx, kode, qty, harga, note) async {
    Database? db = await createDatabase();

    return db!.rawUpdate(
        'update tb_detail_transaksi_pembelian set qty = ?, harga = ?, catatan = ? where id_barang = ? and id_transaksi = ?',
        [qty, harga, note, kode, idTrx]);

    // return db!.insert('tb_detail_transaksi_pembelian', kat.toMap());
  }

  Future<int> updateListDetailTransaksiPembelianTunai(
      idTrx, kode, qty, harga, note) async {
    Database? db = await createDatabase();

    return db!.rawUpdate(
        'update tb_detail_transaksi_pembelian set qty = ?, harga = ?, catatan = ? where id_barang = ? and status = ?',
        [qty, harga, note, kode, 1]);

    // return db!.insert('tb_detail_transaksi_pembelian', kat.toMap());
  }

  Future<int> updateListSubDetailTransaksiPembelianTunai(
      idTrx, kode, qty, harga, note) async {
    Database? db = await createDatabase();

    return db!.rawUpdate(
        'update tb_sub_detail_transaksi_pembelian set qty = ?, harga = ? where id_barang = ? and status = ?',
        [qty, harga, kode, 1]);

    // return db!.insert('tb_detail_transaksi_pembelian', kat.toMap());
  }

  Future<int> createPembayaran(PembayaranModel kat) async {
    Database? db = await createDatabase();

    return db!.insert('tb_pembayaran', kat.toMap());
  }

  Future<List> createKomisi(idTransaksi) async {
    Database? db = await createDatabase();

    return db!.rawQuery('''
                  INSERT INTO tb_komisi_penjualan (id_transaksi, status_bayar)
                                 VALUES ('${idTransaksi}','0')
              ''');
  }

  Future<int> createPengeluaran(PengeluaranModel kat) async {
    Database? db = await createDatabase();

    return await db!.transaction((txn) async {
      // 1️⃣ Insert ke tb_penerimaan dulu
      int id = await txn.insert(
        'tb_pengeluaran',
        kat.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 2️⃣ Jika bukan hutang, catat ke kas harian

      await prosesKasHarian(
        txn: txn,
        tipe: 1, // 1 = keluar (karena pengeluaran kas)
        sumber: 'pengeluaran_biaya',
        referensiId: id.toString(),
        jumlah: kat.nilai ?? 0,
        keterangan: kat.keterangan ?? 'Pengeluaran kas',
      );

      return id;
    });
  }

  Future<int> createPenerimaan(PenerimaanModel penerimaan) async {
    Database? db = await createDatabase();

    return await db!.transaction((txn) async {
      // 1️⃣ Insert ke tb_penerimaan dulu
      int id = await txn.insert(
        'tb_penerimaan',
        penerimaan.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 2️⃣ Jika bukan hutang, catat ke kas harian

      await prosesKasHarian(
        txn: txn,
        tipe: 2, // 2 = masuk (karena penerimaan kas)
        sumber: 'penerimaan_masuk',
        referensiId: id.toString(),
        jumlah: penerimaan.nilai ?? 0,
        keterangan: penerimaan.keterangan ?? 'Penerimaan kas',
      );

      return id;
    });
  }

  Future<Map<String, dynamic>> insertBarangMasuk(
      Map<String, dynamic> data) async {
    Database? db = await createDatabase();

    return await db!.transaction((txn) async {
      int id = await txn.insert(
        'barang_masuk',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      String noTransaksi = 'BM-${id.toString().padLeft(6, '0')}';

      await txn.update(
        'barang_masuk',
        {'no_transaksi': noTransaksi},
        where: 'id = ?',
        whereArgs: [id],
      );

      await prosesMutasiStok(
        txn: txn,
        produkId: data['produk_id'],
        qty: data['qty'],
        tipe: 'masuk',
        sumber: 'barang_masuk',
        refId: noTransaksi,
      );

      if (data['metode_pembayaran'] != 'hutang') {
        await prosesKasHarian(
          txn: txn,
          tipe: 1,
          sumber: 'barang_masuk',
          referensiId: noTransaksi,
          jumlah: data['total'],
          keterangan: 'Pembelian stok',
        );
      }

      int hutangId = 0;
      String? kodeHutang;

      if (data['metode_pembayaran'] == 'hutang') {
        hutangId = await txn.insert('tb_hutang_supplier', {
          'barang_masuk_id': id,
          'kode_supplier': data['kode_supplier'], // pastikan benar
          'total': data['total'],
          'sisa': data['total'],
          'status': 'belum_lunas',
          'created_at': DateTime.now().toString(),
          'updated_at': DateTime.now().toString(),
        });

        kodeHutang = "HTG-${hutangId.toString().padLeft(6, '0')}";

        await txn.update(
          'tb_hutang_supplier',
          {'kode_hutang': kodeHutang},
          where: 'id = ?',
          whereArgs: [hutangId],
        );
      }

      // ✅ RETURN 2 VALUE
      return {
        'id': id,
        'kode_hutang': kodeHutang,
      };
    });
  }

  Future<int> updateBarangMasuk(Map<String, dynamic> data) async {
    Database? db = await createDatabase();

    return await db!.transaction((txn) async {
      await txn.update(
        'barang_masuk',
        data,
        where: 'id = ?',
        whereArgs: [data['id']],
      );

      return data['id'];
    });
  }

  Future<void> prosesKasHarian({
    required Transaction txn,
    required int tipe, // 1 = keluar, 2 = masuk
    required String sumber,
    required String referensiId,
    required int jumlah,
    required String keterangan,
  }) async {
    if (jumlah <= 0) return;

    await txn.insert('tb_kas_harian', {
      'tipe': tipe,
      'sumber': sumber,
      'referensi_id': referensiId,
      'jumlah': jumlah,
      'keterangan': keterangan,
      'tanggal': DateTime.now().toString(),
    });
  }

  Future<void> prosesMutasiStok({
    required Transaction txn,
    required int produkId,
    required int qty,
    required String tipe, // masuk / keluar
    required String sumber,
    required String refId,
  }) async {
    final result = await txn.query(
      'tb_produk',
      where: 'id = ?',
      whereArgs: [produkId],
      limit: 1,
    );

    if (result.isEmpty) return;

    int stokLama = result.first['stok'] as int;
    int stokBaru = tipe == 'masuk' ? stokLama + qty : stokLama - qty;

    await txn.update(
      'tb_produk',
      {'stok': stokBaru},
      where: 'id = ?',
      whereArgs: [produkId],
    );

    await txn.insert('tb_stok_mutasi', {
      'produk_id': produkId,
      'tipe': tipe,
      'sumber': sumber,
      'ref_id': refId,
      'qty': qty,
      'stok_sebelum': stokLama,
      'stok_sesudah': stokBaru,
      'tanggal': DateTime.now().toString(),
    });
  }

  Future<Map<String, dynamic>> getById(String table, int id) async {
    Database? db = await createDatabase();

    final result = await db!.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );

    return result.first;
  }

  // Read all items (journals)

  Future<List> allCategori() async {
    Database? db = await createDatabase();

    return db!.query('tb_kategori');
  }

  Future<List> allPkAc() async {
    Database? db = await createDatabase();

    return db!.query('tb_pk_ac');
  }

  Future<List<Map<String, dynamic>>> cariProdukById(int id) async {
    Database? db = await createDatabase();
    return await db!.query(
      "tb_produk",
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List> cariKategori(int id) async {
    Database? db = await createDatabase();
    return db!.query("tb_produk", where: 'id_kategori = ?', whereArgs: [id]);
  }

  Future<List> allProduk() async {
    Database? db = await createDatabase();

    return db!.query('tb_produk');
  }

  Future<List<Map<String, dynamic>>> allProdukAutoComplete() async {
    Database? db = await createDatabase();

    return db!.query('tb_produk');
  }

  Future<List> allPkAutoComplete() async {
    Database? db = await createDatabase();

    return db!.query('tb_pk_ac');
  }

  Future<List> kategori() async {
    Database? db = await createDatabase();

    return db!.query('tb_kategori');
  }

  Future<List> allNamaProduk() async {
    Database? db = await createDatabase();

    return db!.rawQuery(
        'select kode, nama_barang from tb_produk group by nama_barang');
  }

  Future<int> countProduk() async {
    final db = await createDatabase();

    final result =
        await db!.rawQuery("SELECT COUNT(id) as jumlah FROM tb_produk");

    return (result.isNotEmpty ? result.first['jumlah'] : 0) as int? ?? 0;
  }

  Future<List> countProdukList() async {
    final db = await createDatabase();

    return await db!.rawQuery("SELECT COUNT(id) as jumlah FROM tb_produk");
  }

  Future<List> countPkAcList() async {
    final db = await createDatabase();

    return await db!.rawQuery("SELECT COUNT(id) as jumlah FROM tb_pk_ac");
  }

  Future<int> countPenerimaan() async {
    final db = await createDatabase();

    final result =
        await db!.rawQuery("SELECT COUNT(id) as jumlah FROM tb_penerimaan");

    return (result.isNotEmpty ? result.first['jumlah'] : 0) as int? ?? 0;
  }

  Future<int> countPengeluaran() async {
    final db = await createDatabase();

    final result =
        await db!.rawQuery("SELECT COUNT(id) as jumlah FROM tb_pengeluaran");

    return (result.isNotEmpty ? result.first['jumlah'] : 0) as int? ?? 0;
  }

  Future<int> countKategori() async {
    final db = await createDatabase();

    final result =
        await db!.rawQuery("SELECT COUNT(id) as jumlah FROM tb_kategori");

    return (result.isNotEmpty ? result.first['jumlah'] : 0) as int? ?? 0;
  }

  Future<int> countSupplier() async {
    final db = await createDatabase();

    final result =
        await db!.rawQuery("SELECT COUNT(id) as jumlah FROM supplier");

    return (result.isNotEmpty ? result.first['jumlah'] : 0) as int? ?? 0;
  }

  Future<int> countPkAc() async {
    Database? db = await createDatabase();

    final result =
        await db!.rawQuery("select count(id) as jumlah from tb_pk_ac");

    if (result.isNotEmpty) {
      return result.first['jumlah'] as int? ?? 0;
    }

    return 0;
  }

  Future<int> countBarangMasuk() async {
    final db = await createDatabase();

    final result =
        await db!.rawQuery("SELECT COUNT(id) as jumlah FROM barang_masuk");

    return (result.isNotEmpty ? result.first['jumlah'] : 0) as int? ?? 0;
  }

  Future<int> countHutangSupplier() async {
    final db = await createDatabase();

    final result = await db!
        .rawQuery("SELECT COUNT(id) as jumlah FROM tb_hutang_supplier");

    return (result.isNotEmpty ? result.first['jumlah'] : 0) as int? ?? 0;
  }

  Future<int> countBayarHutangSupplier() async {
    final db = await createDatabase();

    final result = await db!
        .rawQuery("SELECT COUNT(id) as jumlah FROM tb_bayar_hutang_supplier");

    return (result.isNotEmpty ? result.first['jumlah'] : 0) as int? ?? 0;
  }

  Future<List<Map<String, dynamic>>> allProdukPage(
    int limit,
    int offset,
    int kat,
  ) async {
    Database? db = await createDatabase();
    // print(db?.query('tb_produk', offset: offset, limit: limit));

    if (kat == 0) {
      return await db!
          .query('tb_produk', offset: offset, limit: limit, orderBy: 'id DESC');
    } else {
      return await db!.query('tb_produk',
          where: 'id_kategori = ?',
          whereArgs: [kat.toString()],
          offset: offset,
          limit: limit,
          orderBy: 'id DESC');
    }
  }

  Future<List<Map<String, dynamic>>> allProdukPageKeyword(
      int limit, int offset, int kat, String? keyword, String produk) async {
    Database? db = await createDatabase();

// jadi mau join tb_produk dan tb_detail_transaksi_pembelian harus id on id_barang
    // Siapkan kondisi WHERE dan argumen
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (kat != 0) {
      whereClause += 'id_kategori = ? or id_pk = ?';
      whereArgs.add(kat);
      whereArgs.add(kat);
    }

    if (produk != "") {
      final List<Map<String, dynamic>> result2 = await db!
          .rawQuery("SELECT nama_barang from tb_produk where kode = '$produk'");

      var nama = result2[0]['nama_barang'];

      if (kat != 0) {
        whereClause += 'and a.nama_barang LIKE ?';
        whereArgs.add('%$nama%');
      } else {
        whereClause += ' a.nama_barang LIKE ?';
        whereArgs.add('%$nama%');
      }
    }

    if (keyword != null && keyword.isNotEmpty) {
      if (whereClause.isNotEmpty) {
        whereClause += ' AND ';
      }
      whereClause += ' nama_barang LIKE ?';
      whereArgs.add('%$keyword%');
    }

    String finalWhere = whereClause.isNotEmpty ? 'WHERE $whereClause' : '';

    String query = '''
    SELECT a.*, IFNULL(SUM(b.qty), 0) as jml,qty,IFNULL((id_barang), 0) as id_barang,c.nama_kategori,d.nama as nama_pk,id_pk, harga_jual, harga_beli, gambar, a.kode,b.harga
    FROM tb_produk a
    LEFT JOIN tb_detail_transaksi_pembelian b ON a.id = b.id_barang
    LEFT JOIN tb_kategori c ON a.id_kategori = c.id
    LEFT JOIN tb_pk_ac d ON a.id_pk = d.id

    $finalWhere
    GROUP BY a.kode
    ORDER BY a.kode ASC
    LIMIT ? OFFSET ?
  ''';

    print(query);

    return await db!.rawQuery(query, [...whereArgs, limit, offset]);
  }

  Future<List> allTransaksiPembelian() async {
    Database? db = await createDatabase();
    return db!.rawQuery('select status from tb_detail_transaksi_pembelian');
    //  print(db?.path);
    // return db!.query('tb_transaksi_pembelian');
  }

  Future<List> allDetailTransaksiPembelian() async {
    Database? db = await createDatabase();

    //  print(db?.path);
    return db!.query('tb_detail_transaksi_pembelian');
  }

  Future<List> allPembayaran() async {
    Database? db = await createDatabase();
    //db.rawQuery('select * from courses');
    //  print(db?.path);
    return db!.query('tb_pembayaran');
  }

  Future<List> showPembelian() async {
    Database? db = await createDatabase();

    //db!.execute("DROP TABLE IF EXISTS tb_sub_detail_transaksi_pembelian");

    return db!.rawQuery(
        'select a.harga, a.id_barang, a.qty,a.status,a.catatan, a.diskon ,b.kode,b.stok, b.nama_barang,b.harga_jual,b.harga_go_food,b.harga_shopee_food, a.id_transaksi from tb_detail_transaksi_pembelian a left join tb_produk b on a.id_barang = b.id where a.status = 1');
  }

  ubahHarga(harga, idBarang, delivery) async {
    Database? db = await createDatabase();

    return db!.rawQuery(
        "update tb_detail_transaksi_pembelian set harga = '$harga', id_delivery = '$delivery' where id_barang = '$idBarang' and status = 1");
  }

  Future<List> showPembelianPemesanan(id) async {
    Database? db = await createDatabase();

    return db!.rawQuery(
        'select a.harga, a.id_barang, a.qty,a.status,a.catatan, a.diskon ,b.kode,b.stok, b.nama_barang,b.harga_jual, a.id_transaksi from tb_detail_transaksi_pembelian a left join tb_produk b on a.id_barang = b.id where a.id_transaksi = $id');
  }

  Future<List> showJumlahTransaksi(tanggal) async {
    Database? db = await createDatabase();

    var current = DateTime.parse(tanggal);

    var currentString = DateFormat('yyyy-MM-dd').format(current);

    var mulai = "$currentString 00:00:00";

    var selesai = "$currentString 23:59:59";

    // db!.rawQuery("DROP TABLE IF EXISTS tb_sub_detail_transaksi_pembelian");

    // db!.rawQuery(
    //     "ALTER TABLE tb_produk ADD harga_shopee_food INTEGER DEFAULT NULL");

    return db!.rawQuery('''
      select * from tb_detail_transaksi_pembelian  where status in (1,3) and created_at between '$mulai' and '$selesai' group by id_transaksi
      ''');
  }

  Future<List> showPembelianPemesananDidepan(id) async {
    Database? db = await createDatabase();

    return db!.rawQuery(
        'select a.harga, a.id_barang, a.qty,a.status,a.catatan, a.diskon ,b.kode,b.stok, b.nama_barang,b.harga_jual,b.harga_go_food,b.harga_shopee_food, a.id_transaksi, a.id_sub_transaksi from tb_detail_transaksi_pembelian a left join tb_produk b on a.id_barang = b.id  where a.id_transaksi = $id');
  }

  Future<List> updateDetailTransaksiPembelian(id) async {
    Database? db = await createDatabase();

    db!.rawUpdate('''
    UPDATE tb_detail_transaksi_pembelian 
    SET id_transaksi = ?
    WHERE status = 1
    ''', [id]);

    return db.rawQuery(
        'update tb_detail_transaksi_pembelian set status = 2 where status = 1');
  }

  Future<bool> updateDetailTransaksiPembelianHutang(id) async {
    Database? db = await createDatabase();

    db!.rawUpdate('''
    UPDATE tb_detail_transaksi_pembelian 
    SET id_transaksi = ?
    WHERE status = 1
    ''', [id]);

    db.rawQuery(
        'update tb_detail_transaksi_pembelian set status = 5 where status = 1');

    return true;
  }

  Future<List> updateDetailTransaksiPembelianPembayaranDidepan(
      id, statusBayar) async {
    Database? db = await createDatabase();

    db!.rawQuery(
        'update tb_sub_detail_transaksi_pembelian set status = 2 where status = 3 and id_transaksi = $id');

    db.rawQuery(
        "update tb_transaksi_pembelian set status_bayar = '$statusBayar' where id = '$id' ");

    return db.rawQuery(
        'update tb_detail_transaksi_pembelian set status = 2 where status = 3 and id_transaksi = $id');
  }

  Future<List> updateDetailTransaksiPembelianPemesanan(id) async {
    Database? db = await createDatabase();

    db!.rawUpdate('''
    UPDATE tb_detail_transaksi_pembelian 
    SET id_transaksi = ?
    WHERE status = 1
    ''', [id]);

    db.rawUpdate('''
    UPDATE tb_sub_detail_transaksi_pembelian 
    SET id_transaksi = ?
    WHERE status = 1
    ''', [id]);

    db.rawQuery(
        'update tb_sub_detail_transaksi_pembelian set status = 3 where status = 1');

    return db.rawQuery(
        'update tb_detail_transaksi_pembelian set status = 3 where status = 1');
  }

  Future<List> updateDetailTransaksiPembelianUntukPengembalianBarang(id) async {
    Database? db = await createDatabase();

    db!.rawUpdate('''
    UPDATE tb_detail_transaksi_pembelian 
    SET id_transaksi = ?
    WHERE status = 1
    ''', [id]);

    return db.rawQuery(
        'update tb_detail_transaksi_pembelian set status = 3 where status = 1');
  }

  Future<List> updateDetailTransaksiUntukPengeluaranBarang(id) async {
    Database? db = await createDatabase();

    db!.rawUpdate('''
    UPDATE tb_detail_transaksi_pembelian 
    SET id_transaksi = ?
    WHERE status = 1
    ''', [id]);

    return db.rawQuery(
        'update tb_detail_transaksi_pembelian set status = 4 where status = 1');
  }

  Future<List> selectDetailTransaksiPembelian(id) async {
    Database? db = await createDatabase();

    return db!.rawQuery(
        'select a.harga, a.id_barang, a.qty,a.status,a.diskon, a.catatan,a.id_transaksi,b.kode,b.stok, b.nama_barang,b.harga_jual, b.harga_go_food, b.harga_shopee_food,a.id_delivery from tb_detail_transaksi_pembelian a left join tb_produk b on a.id_barang = b.id WHERE a.id_transaksi=?',
        [id]);
  }

  Future<List> selectSubDetailTransaksiPembelian(id) async {
    Database? db = await createDatabase();

    return db!.rawQuery(
        'select a.harga, a.id_barang, a.qty,a.status,a.diskon,a.id_transaksi,b.kode,b.stok, b.nama_barang,b.harga_jual, b.harga_go_food, b.harga_shopee_food from tb_sub_detail_transaksi_pembelian a left join tb_produk b on a.id_barang = b.id WHERE a.id_transaksi=?',
        [id]);
  }

  Future<List> selectProdukScan(kode) async {
    Database? db = await createDatabase();

    return db!.rawQuery('select * from tb_produk where kode=?', [kode]);
  }

  Future<bool> truncatePemesanan() async {
    Database? db = await createDatabase();

    db!.rawQuery('delete from tb_detail_transaksi_pembelian');
    await db.execute(
        "DELETE FROM sqlite_sequence WHERE name='tb_detail_transaksi_pembelian'");

    db.rawQuery('delete from tb_pembayaran');

    await db.execute(
        "DELETE FROM sqlite_sequence WHERE name='tb_detail_transaksi_pembelian'");

    db.rawQuery('delete from tb_sub_detail_transaksi_pembelian');

    await db.execute(
        "DELETE FROM sqlite_sequence WHERE name='tb_sub_detail_transaksi_pembelian'");

    db.rawQuery('delete from tb_hutang');
    await db.execute("DELETE FROM sqlite_sequence WHERE name='tb_hutang'");
    db.rawQuery('delete from tb_komisi_penjualan');
    await db.execute(
        "DELETE FROM sqlite_sequence WHERE name='tb_komisi_penjualan'");

    db.rawQuery('delete from tb_transaksi_pembelian');

    await db.execute(
        "DELETE FROM sqlite_sequence WHERE name='tb_transaksi_pembelian'");

    return true;
  }

  Future<bool> truncateInOut() async {
    Database? db = await createDatabase();

    db!.rawQuery('delete from tb_penerimaan');

    await db.execute("DELETE FROM sqlite_sequence WHERE name='tb_penerimaan'");

    //db.rawQuery('delete from tb_pembayaran');

    db.rawQuery('delete from tb_pengeluaran');

    await db.execute("DELETE FROM sqlite_sequence WHERE name='tb_pengeluaran'");

    return true;
  }

  Future<int> updateStok(idBarang, stok, jum, idTrx) async {
    Database? db = await createDatabase();

    var jumStok = stok - jum;

    await db!.insert('tb_stok_mutasi', {
      'produk_id': idBarang,
      'tipe': 'keluar',
      'sumber': 'barang_masuk',
      'ref_id': idTrx,
      'qty': jum,
      'stok_sebelum': stok,
      'stok_sesudah': jumStok,
      'tanggal': DateTime.now().toString(),
    });

    return db.rawUpdate(
        'UPDATE tb_produk SET stok = ? WHERE id = ?', [jumStok, idBarang]);
  }

  Future<int> updateStokDetailPemesanan(
      idBarang, stok, jum, idTrans, hargaJual) async {
    Database? db = await createDatabase();

    var jumStok = stok - jum;

    var harga = hargaJual * jumStok;

    // db!.rawUpdate(
    //     'UPDATE tb_produk SET stok = ? WHERE id = ?', [jumStok, idBarang]);

    db!.rawUpdate(
        'UPDATE tb_detail_transaksi_pembelian SET qty = ?, harga = ? WHERE id_transaksi = ? and id_barang = ?',
        [jumStok, harga, idTrans, idBarang]);

    return db.rawUpdate(
        'delete from tb_detail_transaksi_pembelian where qty = ?', [0]);
  }

  Future<int> updateStokSubDetailPemesanan(
      idBarang, stok, jum, idTrx, idSubTrans, hargaJual) async {
    Database? db = await createDatabase();

    var jumStok = stok - jum;

    var harga = hargaJual * jumStok;

    // db!.rawUpdate(
    //     'UPDATE tb_produk SET stok = ? WHERE id = ?', [jumStok, idBarang]);

    db!.rawUpdate(
        'UPDATE tb_sub_detail_transaksi_pembelian SET qty = ?, harga = ? WHERE id_transaksi = ? and id_sub_transaksi = ? and id_barang = ?',
        [jumStok, harga, idTrx, idSubTrans, idBarang]);

    //db!.rawQuery('UPDATE tb_sub_detail_transaksi_pembelian SET qty = $jumStok, harga = $harga WHERE id_transaksi = $idTrx and id_sub_transaksi and id_barang = ?');

    return db.rawUpdate(
        'delete from tb_detail_transaksi_pembelian where qty = ?', [0]);
  }

  Future<int> updateStokPengembalianBarang(idBarang, stok, jum) async {
    Database? db = await createDatabase();

    var jumStok = stok + jum;

    return db!.rawUpdate(
        'UPDATE tb_produk SET stok = ? WHERE id = ?', [jumStok, idBarang]);
  }

  idBarang(id) async {
    Database? db = await createDatabase();

    return db!.rawQuery('SELECT stok FROM tb_barang WHERE id=?', [id]);
  }

  Future<List> hitungPembelian() async {
    Database? db = await createDatabase();

    return db!.rawQuery(
        "SELECT SUM(total) AS total, qty FROM tb_detail_transaksi_pembelian WHERE status = 1 order by created_at desc limit 1 ");

    // return db!.rawQuery(
    //     "select sum(harga_1) as harga from ( select sum(a.harga) as harga_1,a.status,a.created_at from tb_sub_detail_transaksi_pembelian a where a.status = 1 UNION ALL select sum(b.harga) as harga_1,b.status,b.created_at from tb_detail_transaksi_pembelian b where b.status = 1 ) as TotalAll");
  }

  Future<List> hitungPembelianPemesananDiDepan(id) async {
    Database? db = await createDatabase();

    return db!.rawQuery(
        "select sum(harga_1) as harga from (select sum(b.harga) as harga_1,b.status,b.created_at from tb_detail_transaksi_pembelian b where b.id_transaksi = '$id' ) as TotalAll");
  }

  Future<List> hitungSubPembelian() async {
    Database? db = await createDatabase();
    return db!.rawQuery(
        "select sum(harga) as harga,status,created_at from tb_sub_detail_transaksi_pembelian where status = 1");
    //  print(db?.path);
    // return db!.rawQuery('delete from tb_detail_transaksi_pembelian');
  }

  Future<List> hitungPembelianPemesananDidepan(id) async {
    Database? db = await createDatabase();

    return db!.rawQuery(
        "select sum(harga_1) as harga from ( select sum(a.harga) as harga_1,a.status,a.created_at from tb_sub_detail_transaksi_pembelian a where a.id_transaksi = $id UNION ALL select sum(b.harga) as harga_1,b.status,b.created_at from tb_detail_transaksi_pembelian b where b.id_transaksi = $id ) as TotalAll");

    // return db!.rawQuery(
    //     "select sum(harga) as harga,created_at from tb_detail_transaksi_pembelian where id_transaksi = $id");
    //  print(db?.path);
    // return db!.rawQuery('delete from tb_detail_transaksi_pembelian');
  }

  Future<List> totPembelian(idTrans) async {
    Database? db = await createDatabase();

    // db!.rawQuery(
    //     "select sum(harga_1) as harga from ( select sum(a.harga) as harga_1,a.status,a.created_at from tb_sub_detail_transaksi_pembelian a where a.status = 1 UNION ALL select sum(b.harga) as harga_1,b.status,b.created_at from tb_detail_transaksi_pembelian b where b.status = 1 ) as TotalAll");
    return db!.rawQuery(
      "select sum(harga_1) as harga from ( select sum(a.harga) as harga_1,a.status,a.created_at from tb_sub_detail_transaksi_pembelian a where a.id_transaksi = '$idTrans' UNION ALL select sum(b.harga) as harga_1,b.status,b.created_at from tb_detail_transaksi_pembelian b where b.id_transaksi = '$idTrans' ) as TotalAll",
    );

    //  print(db?.path);
    // return db!.rawQuery('delete from tb_detail_transaksi_pembelian');
  }

  Future<int> prosesTransaksiPembelian(
      TransaksiDetailPembelianModel kat) async {
    Database? db = await createDatabase();
    return await db!.update('tb_detail_transaksi_pembelian', kat.toMap(),
        where: 'status = ?', whereArgs: [2]);

    //  print(db?.path);
    // return db!.rawQuery('delete from tb_detail_transaksi_pembelian');
  }

  // Read a single item by id
  // The app doesn't use this method but I put here in case you want to see it

  // Update an item by id

  Future<List> updateKategori(kode, namaKategori) async {
    Database? db = await createDatabase();
    return await db!.rawQuery(
        "update tb_kategori set nama_kategori = '$namaKategori' where kode = '$kode' ");
  }

  Future<List> updateShift(id, uangFisik, saldoAwal, saldoAkhir) async {
    Database? db = await createDatabase();
    return await db!.rawQuery(
        "update tb_shift set uang_fisik = '$uangFisik', saldo_awal ='$saldoAwal', saldo_akhir = '$saldoAkhir' where id = '$id' ");
  }

  Future<int> tambahShift(uangFisik, saldoAwal, saldoAkhir) async {
    final db = await createDatabase();

    return await db!.rawInsert(
      '''
    INSERT INTO tb_shift (uang_fisik, saldo_awal, saldo_akhir, created_at)
    VALUES (?, ?, ?, ?)
    ''',
      [
        uangFisik,
        saldoAwal,
        saldoAkhir,
        DateTime.now().toIso8601String(),
      ],
    );
  }

  Future<int> updateProduk(ProdukModel kat) async {
    Database? db = await createDatabase();
    return await db!
        .update('tb_produk', kat.toMap(), where: 'id = ?', whereArgs: [kat.id]);
  }

  // Delete

  Future<int> deleteKategori(kode) async {
    Database? db = await createDatabase();
    return db!.delete('tb_kategori', where: 'kode = ?', whereArgs: [kode]);
  }

  Future<int> deleteShift(int id) async {
    Database? db = await createDatabase();
    return db!.delete('tb_shift', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteProduk(int id) async {
    Database? db = await createDatabase();
    return db!.delete('tb_produk', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteDetailPembelian(int id, int idSubTrans) async {
    Database? db = await createDatabase();

    db!.delete('tb_sub_detail_transaksi_pembelian',
        where: 'id_sub_transaksi = ? and status = ?',
        whereArgs: [idSubTrans, 1]);

    return db.delete('tb_detail_transaksi_pembelian',
        where: 'id_barang = ? and status = ?', whereArgs: [id, 1]);
  }

  Future<int> deleteDetailPembelianPemesanan(
      int idBarang, int idTransaksi) async {
    Database? db = await createDatabase();
    return db!.delete('tb_detail_transaksi_pembelian',
        where: 'id_barang = ? and id_transaksi = ?',
        whereArgs: [idBarang, idTransaksi]);
  }

  Future<List<String>> selectItems() async {
    var db = KasirHelper.db;
    final usersData = await db!.query("tb_kategori");
    return usersData.map((Map<String, dynamic> row) {
      return row["nama_kategori"] as String;
    }).toList();
  }

  Future<List<KategoriModelMysql>> fetchAllKategori() async {
    final dbClient = KasirHelper.db;
    List<KategoriModelMysql> kategori = [];
    try {
      final maps = await dbClient?.query("tb_kategori");
      for (var item in maps!) {
        kategori.add(KategoriModelMysql.fromJson(item));
      }
    } catch (e) {
      print(e.toString());
    }
    return kategori;
  }

  Future<List> totTransaksi(idTrans) async {
    Database? db = await createDatabase();
    return db!.rawQuery(
        "select sum(harga) as harga from tb_detail_transaksi_pembelian where id_transaksi = ?",
        [idTrans]);
    //  print(db?.path);
    // return db!.rawQuery('delete from tb_detail_transaksi_pembelian');
  }

  Future<List> backUpTrans(tanggal) async {
    Database? db = await createDatabase();

    var current = DateTime.parse(tanggal);

    var currentString = DateFormat('yyyy-MM-dd').format(current);

    var mulai = tanggal;

    var selesai = "$currentString 23:59:59";

    return db!.rawQuery(
        "select * from tb_transaksi_pembelian where created_at BETWEEN '$mulai' and '$selesai'");
  }

  Future<Map<String, dynamic>?> getKode(kode) async {
    Database? db = await createDatabase();
    //return db!.rawQuery("select kode from tb_produk where kode = ?", [kode]);

    final List<Map<String, dynamic>> data =
        await db!.query('tb_produk', where: 'kode = ?', whereArgs: [kode]);

    if (data.isNotEmpty) {
      return data.first;
    } else {
      return null; // Return null if no data is found.
    }
    //  print(db?.path);
    // return db!.rawQuery('delete from tb_detail_transaksi_pembelian');
  }

  Future<List> pembayaranLast() async {
    Database? db = await createDatabase();
    return db!.rawQuery("select * from tb_pembayaran order by id desc limit 1");
  }

  Future<List> allPenerimaan() async {
    Database? db = await createDatabase();

    return db!
        .rawQuery('select * from tb_penerimaan order by id desc limit 200');
  }

  Future<List> allPengeluaran() async {
    Database? db = await createDatabase();

    return db!
        .rawQuery('select * from tb_pengeluaran order by id desc limit 200');
  }

  Future<List> allBarangMasuk() async {
    Database? db = await createDatabase();

    return db!
        .rawQuery('select * from barang_masuk order by id desc limit 200');
  }

  Future<List> allKas() async {
    Database? db = await createDatabase();

    return db!
        .rawQuery('select * from tb_kas_harian order by id desc limit 200');
  }

  Future<List> updatePenerimaan(id, nama, nilai) async {
    Database? db = await createDatabase();
    await db!.rawQuery(
        "update tb_kas_harian set keterangan = '$nama', jumlah = '$nilai' where referensi_id = '$id' ");

    return await db.rawQuery(
        "update tb_penerimaan set keterangan = '$nama', nilai = '$nilai' where id = '$id' ");
  }

  Future<List> updatePengeluaran(id, nama, nilai) async {
    Database? db = await createDatabase();
    // return await db!.update('tb_pengeluaran', kat.toMap(),
    //     where: 'id = ?', whereArgs: [kat.id]);

    await db!.rawQuery(
        "update tb_kas_harian set keterangan = '$nama', jumlah = '$nilai' where referensi_id = '$id' ");

    return await db.rawQuery(
        "update tb_pengeluaran set keterangan = '$nama', nilai = '$nilai' where id = '$id' ");
  }

  Future<int> deletePenerimaan(int id) async {
    Database? db = await createDatabase();

    await db!.delete('tb_kas_harian',
        where: 'referensi_id = ? AND tipe = ?', whereArgs: [id, 2]);
    return db.delete('tb_penerimaan', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deletePengeluaran(int id) async {
    Database? db = await createDatabase();
    await db!.delete('tb_kas_harian',
        where: 'referensi_id = ? AND tipe = ?', whereArgs: [id, 1]);
    return db.delete('tb_pengeluaran', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteBarangMasuk(noTrans) async {
    Database? db = await createDatabase();

    // Ambil data barang_masuk dulu untuk kurangi stok
    final barangMasuk = await db!.query(
      'barang_masuk',
      where: 'no_transaksi = ?',
      whereArgs: [noTrans],
    );

    if (barangMasuk.isNotEmpty) {
      final item = barangMasuk.first;
      final kodeProduk = item['kode_produk'];
      final qty = item['qty'] as int;

      // Kurangi stok produk
      final produk = await db.query(
        'tb_produk',
        where: 'kode = ?',
        whereArgs: [kodeProduk],
        limit: 1,
      );

      if (produk.isNotEmpty) {
        int stokLama = produk.first['stok'] as int;
        int stokBaru = stokLama - qty;

        await db.update(
          'tb_produk',
          {'stok': stokBaru},
          where: 'kode = ?',
          whereArgs: [kodeProduk],
        );
      }
    }

    // Hapus data terkait
    await db.delete('tb_kas_harian',
        where: 'referensi_id = ? AND tipe = ?', whereArgs: [noTrans, 1]);
    await db
        .delete('tb_stok_mutasi', where: 'ref_id = ?', whereArgs: [noTrans]);

    return db.delete('barang_masuk',
        where: 'no_transaksi = ?', whereArgs: [noTrans]);
  }

  Future<List> getProduk(kode) async {
    Database? db = await createDatabase();

    return db!.rawQuery("select * from tb_produk where kode ='$kode'");
    //  print(db?.path);
    // return db!.query('tb_transaksi_pembelian');
  }

  Future<List> jamKerja() async {
    Database? db = await createDatabase();

    return db!.query('tb_jam_kerja');
  }

  Future<int> updateJamKerja(JamKerjaModel kat) async {
    Database? db = await createDatabase();
    return await db!.update('tb_jam_kerja', kat.toMap(),
        where: 'id = ?', whereArgs: [kat.id]);
  }

  Future<int> createJamKerja(JamKerjaModel kat) async {
    Database? db = await createDatabase();
    return db!.insert('tb_jam_kerja', kat.toMap());
  }

  Future<int> deleteJamKerja(int id) async {
    Database? db = await createDatabase();

    return db!.delete('tb_jam_kerja', where: 'id = ?', whereArgs: [id]);
  }

  Future<String> _getTotal() async {
    // Melakukan query untuk mendapatkan data
    Database? db = await createDatabase();

    final List<Map<String, dynamic>> data = await db!.query(
        "select sum(harga) as harga,created_at from tb_detail_transaksi_pembelian where status = 1");

    // Mengambil data pertama (jika ada)
    if (data.isNotEmpty) {
      var a = data.first['value'].toString();

      return a;
    } else {
      return 'Tidak ada data';
    }
  }

  Future<List> getAllTotalNormal() async {
    // Melakukan query untuk mendapatkan data
    Database? db = await createDatabase();

    // final List<Map<String, dynamic>> data = await db!.rawQuery(
    //     "select sum(b.harga_jual) as total from tb_detail_transaksi_pembelian a left join tb_produk b on a.id_barang = b.id where  a.status = 1");
    return db!.rawQuery(
        "select sum(a.harga) as total, qty from tb_detail_transaksi_pembelian a left join tb_produk b on a.id_barang = b.id where  a.status = 1");

    // Mengambil data pertama (jika ada)
    // debugPrint(data.first['total'].toString());
    // if (data.isNotEmpty) {
    //   var a = data.first['total'].toString();

    //   return a;
    // } else {
    //   return 'Tidak ada data';
    // }
  }

  Future<List> getAllTotalGoFood() async {
    // Melakukan query untuk mendapatkan data
    Database? db = await createDatabase();

    return await db!.rawQuery(
        "select sum(a.harga) as total, qty from tb_detail_transaksi_pembelian a left join tb_produk b on a.id_barang = b.id where  a.status = 1");

    // Mengambil data pertama (jika ada)
    // debugPrint(data.first['total'].toString());
    // if (data.isNotEmpty) {
    //   var a = data.first['total'].toString();

    //   return a;
    // } else {
    //   return 'Tidak ada data';
    // }
  }

  Future<List> getAllTotalShopee() async {
    // Melakukan query untuk mendapatkan data
    Database? db = await createDatabase();

    return await db!.rawQuery(
        "select sum(a.harga) as total, qty from tb_detail_transaksi_pembelian a left join tb_produk b on a.id_barang = b.id where  a.status = 1");
  }

  Future<List<Map<String, dynamic>>> allPengeluaranPage(
      int limit, int offset) async {
    Database? db = await createDatabase();
    // print(db?.query('tb_produk', offset: offset, limit: limit));
    return await db!.query('tb_pengeluaran',
        offset: offset, limit: limit, orderBy: 'id DESC');
  }

  Future<List<Map<String, dynamic>>> allBarangMasukPage(
      int limit, int offset) async {
    Database? db = await createDatabase();

    return await db!.rawQuery('''
  SELECT 
    bm.*, 
    p.nama_barang AS nama_barang,
    s.nama AS nama_supplier
  FROM barang_masuk bm
  LEFT JOIN supplier s
    ON s.kode_supplier = bm.kode_supplier  
  LEFT JOIN tb_produk p
    ON TRIM(p.kode) = TRIM(bm.kode_produk)
  GROUP BY bm.no_transaksi
  ORDER BY bm.id DESC
  LIMIT ? OFFSET ?
''', [limit, offset]);
  }

  Future<List<Map<String, dynamic>>> getBarangMasukWithProduk() async {
    Database? db = await createDatabase();

    return await db!.rawQuery('''
    SELECT 
      bm.*, 
      p.nama_barang
    FROM barang_masuk bm
    LEFT JOIN tb_produk p ON bm.produk_id = p.id
    ORDER BY bm.id DESC
  ''');
  }

  Future<List<Map<String, dynamic>>> allPenerimaanPage(
      int limit, int offset) async {
    Database? db = await createDatabase();
    // print(db?.query('tb_produk', offset: offset, limit: limit));
    return await db!.query('tb_penerimaan',
        offset: offset, limit: limit, orderBy: 'id DESC');
  }

  Future<bool> truncateProduk() async {
    Database? db = await createDatabase();

    //  db!.rawQuery('delete from tb_penerimaan');

    db!.rawQuery('delete from supplier');
    db.execute("DELETE FROM sqlite_sequence WHERE name='supplier'");

    db!.rawQuery('delete from tb_kategori');
    db.execute("DELETE FROM sqlite_sequence WHERE name='tb_kategori'");

    db!.rawQuery('delete from tb_pk_ac');
    db.execute("DELETE FROM sqlite_sequence WHERE name='tb_pk_ac'");

    db!.rawQuery('delete from tb_produk');

    await db.execute("DELETE FROM sqlite_sequence WHERE name='tb_produk'");
    return true;
  }

  Future<bool> truncateBarangMasuk() async {
    Database? db = await createDatabase();

    db!.rawQuery('delete from barang_masuk');

    await db.execute("DELETE FROM sqlite_sequence WHERE name='barang_masuk'");

    return true;
  }

  Future<bool> truncateMutasiAndKas() async {
    Database? db = await createDatabase();

    db!.rawQuery('delete from tb_kas_harian');

    await db.execute("DELETE FROM sqlite_sequence WHERE name='tb_kas_harian'");

    db.rawQuery('delete from tb_stok_mutasi');

    await db.execute("DELETE FROM sqlite_sequence WHERE name='tb_stok_mutasi'");

    db.rawQuery('delete from tb_hutang_supplier');

    await db
        .execute("DELETE FROM sqlite_sequence WHERE name='tb_hutang_supplier'");

    db.rawQuery('delete from tb_bayar_hutang_supplier');

    await db.execute(
        "DELETE FROM sqlite_sequence WHERE name='tb_bayar_hutang_supplier'");

    return true;
  }

  Future<List> showPembelianAndToping() async {
    Database? db = await createDatabase();

    return db!.rawQuery(
        'select a.harga, a.id_barang, a.qty,a.status,a.catatan, a.diskon ,b.kode,b.stok, b.nama_barang,b.harga_jual,b.harga_go_food,b.harga_shopee_food, a.id_transaksi, a.id_sub_transaksi , a.created_at from tb_detail_transaksi_pembelian a left join tb_produk b on a.id_barang = b.id  where a.status = 1');
  }

  Future<List> showPembelianAndTopingFront(id) async {
    Database? db = await createDatabase();

    return db!.rawQuery(
        'select a.harga, a.id_barang, a.qty,a.status,a.catatan, a.diskon ,b.kode,b.stok, b.nama_barang,b.harga_jual,b.harga_go_food,b.harga_shopee_food, a.id_transaksi, a.id_sub_transaksi from tb_detail_transaksi_pembelian a left join tb_produk b on a.id_barang = b.id  where a.id_transaksi = ?',
        [id]);
  }

  Future<List> showPembelianAndTopingPrint() async {
    Database? db = await createDatabase();

    return db!.rawQuery(
        'select a.harga, a.id_barang, a.qty,a.status,a.diskon ,b.kode,b.stok, b.nama_barang,b.harga_jual,b.harga_go_food,b.harga_shopee_food, a.id_transaksi from tb_detail_transaksi_pembelian a left join tb_produk b on a.id_barang = b.id where a.status = 1 UNION ALL select a.harga,a.harga, a.id_barang, a.qty,a.status, a.diskon ,b.kode,b.stok, b.nama_barang,b.harga_jual,b.harga_go_food,b.harga_shopee_food, a.id_transaksi from tb_sub_detail_transaksi_pembelian a left join tb_produk b on a.id_barang = b.id where a.status = 1');
  }

  Future<List> showPembelianAndTopingPrintFront(id) async {
    Database? db = await createDatabase();

    return db!.rawQuery(
        'select c.id_pelanggan,d.nama, a.harga, a.id_barang, a.qty,a.status,a.catatan, a.diskon ,b.kode,b.stok, b.nama_barang,b.harga_jual,b.harga_go_food,b.harga_shopee_food, a.id_transaksi, a.id_sub_transaksi , a.created_at from tb_detail_transaksi_pembelian a left join tb_produk b on a.id_barang = b.id left join tb_transaksi_pembelian c on c.id = a.id_transaksi left join pelanggan d on d.id = c.id_pelanggan  where a.id_transaksi = $id');
  }

  Future<List> listSubDetailTransaksi(id) async {
    Database? db = await createDatabase();

    return db!.rawQuery(
        "select d.qty,c.kode,d.id_barang ,c.harga_jual,b.harga, harga_shopee_food,harga_go_food, b.status,c.nama_barang, b.catatan from tb_detail_transaksi_pembelian b LEFT JOIN tb_sub_detail_transaksi_pembelian d on d.id_sub_transaksi = b.id_sub_transaksi left join tb_produk c on c.id = d.id_barang where d.id_sub_transaksi = '$id' and d.status = 1  and b.status = 1 order by d.id_sub_transaksi desc");
  }

  Future<List> listSubDetailTransaksiFront(id) async {
    Database? db = await createDatabase();

    return db!.rawQuery(
        "select d.qty,d.id_barang, c.harga_jual,b.harga, harga_shopee_food,harga_go_food, b.status,c.nama_barang,b.id_sub_transaksi, b.catatan from tb_detail_transaksi_pembelian b LEFT JOIN tb_sub_detail_transaksi_pembelian d on d.id_sub_transaksi = b.id_sub_transaksi left join tb_produk c on c.id = d.id_barang where d.id_sub_transaksi = '$id' and d.status = 3  and b.status = 3 order by d.id_sub_transaksi desc");
  }

  Future<List> listSubDetailTransaksiDidepan(id) async {
    Database? db = await createDatabase();

    return db!.rawQuery(
        "select d.qty, c.harga_jual,b.harga, harga_shopee_food,harga_go_food, b.status,c.nama_barang, b.catatan from tb_detail_transaksi_pembelian b LEFT JOIN tb_sub_detail_transaksi_pembelian d on d.id_sub_transaksi = b.id_sub_transaksi left join tb_produk c on c.id = d.id_barang where d.id_sub_transaksi = '$id' and d.status = 3  and b.status = 3 order by d.id_sub_transaksi desc");
  }

  Future<List> sync(id, namaColumn, table) async {
    Database? db = await createDatabase();
    //  jadi logika nya begini di setiap table saya ada column is_sync, kalau data sudah masuk ke server mysql
    //   maka is_sync = 1, waktu saya mau singkron, saya kumpulkan table yang is_sync = null,
    //   trus bagaimana cara supaya table yang is_sync == null itu mau insert ke table yang ada di mysql

    await db!.rawUpdate(
        "UPDATE $table SET is_sync = ? WHERE $namaColumn = ? AND (is_sync IS NULL OR is_sync = ?)",
        [1, id, 0]);

    return [];
  }

  Future<List<Map<String, dynamic>>> daftarPesanan(
      tanggal, int limit, int offset, status) async {
    Database? db = await createDatabase();
    if (status == 2) {
      return db!.rawQuery(
          "select * from tb_transaksi_pembelian a left join tb_detail_transaksi_pembelian b on a.id = b.id_transaksi where b.status = 4  order by id desc limit '$limit' offset '$offset' ");
    } else if (status == 3) {
      return db!.rawQuery(
          "select * from tb_transaksi_pembelian a left join tb_detail_transaksi_pembelian b on a.id = b.id_transaksi where b.status = 5  order by id desc limit '$limit' offset '$offset' ");
    } else {
      return db!.rawQuery(
          "select * from tb_transaksi_pembelian a left join tb_detail_transaksi_pembelian b on a.id = b.id_transaksi  order by id desc limit '$limit' offset '$offset' ");
    }
  }

  Future<List<Map<String, dynamic>>> orderBelumSync(idTransaksi, status) async {
    Database? db = await createDatabase();

// status 1 = daftar order semua ; status 2 = daftar order barang yang di retur
    if (status == 2) {
      return db!.rawQuery(
          "select a.harga, a.id_barang, a.qty,a.status,a.catatan, a.diskon ,b.kode,b.stok, b.nama_barang,b.harga_jual,b.harga_go_food,b.harga_shopee_food, a.id_transaksi, a.id_sub_transaksi , a.created_at from tb_detail_transaksi_pembelian a left join tb_produk b on a.id_barang = b.id where status = 4 and id_transaksi = $idTransaksi  order by a.id_transaksi desc  ");
    } else {
      return db!.rawQuery(
          "select a.harga, a.id_barang, a.qty,a.status,a.catatan, a.diskon ,b.kode,b.stok, b.nama_barang,b.harga_jual,b.harga_go_food,b.harga_shopee_food, a.id_transaksi, a.id_sub_transaksi , a.created_at from tb_detail_transaksi_pembelian a left join tb_produk b on a.id_barang = b.id where id_transaksi = $idTransaksi   order by a.id_transaksi desc  ");
    }
  }

  Future<List> subOrderBelumSync(idTrx, tanggal) async {
    Database? db = await createDatabase();

    var mulai = tanggal + " 00:00:00";

    var selesai = tanggal + " 23:59:59";

    return db!.rawQuery(
        "select d.qty, c.harga_jual,b.harga, harga_shopee_food,harga_go_food, b.status,c.nama_barang, b.catatan from tb_detail_transaksi_pembelian b LEFT JOIN tb_sub_detail_transaksi_pembelian d on d.id_sub_transaksi = b.id_sub_transaksi left join tb_produk c on c.id = d.id_barang where d.id_sub_transaksi = '$idTrx' and b.created_at between '$mulai' and '$selesai' order by d.id_sub_transaksi desc");
  }

  Future<List> showJumlahTransaksiNotSync(tanggal) async {
    Database? db = await createDatabase();

    var mulai = "$tanggal 00:00:00";

    var selesai = "$tanggal 23:59:59";

    return db!.rawQuery('''
      select a.harga, a.id_barang, a.qty,a.status,a.catatan, a.diskon ,b.kode,b.stok, b.nama_barang,b.harga_jual,b.harga_go_food,b.harga_shopee_food, a.id_transaksi, a.id_sub_transaksi , a.created_at from tb_detail_transaksi_pembelian a left join tb_produk b on a.id_barang = b.id  where a.created_at between '$mulai' and '$selesai' and a.is_sync is null
      ''');
  }

  Future<List> hitungPembelianNotSync(tanggal) async {
    Database? db = await createDatabase();

    var mulai = "$tanggal 00:00:00";

    var selesai = "$tanggal 23:59:59";

    return db!.rawQuery(
        "select sum(harga_1) as harga from ( select sum(a.harga) as harga_1,a.status,a.created_at from tb_sub_detail_transaksi_pembelian a where a.is_sync is null and a.created_at between '$mulai' and '$selesai' UNION ALL select sum(b.harga) as harga_1,b.status,b.created_at from tb_detail_transaksi_pembelian b where b.is_sync is null and b.created_at between '$mulai' and '$selesai') as TotalAll");
  }

  Future<List> subTransaksiNotSync(idTrx) async {
    Database? db = await createDatabase();

    // db!.rawQuery("DROP TABLE IF EXISTS tb_sub_detail_transaksi_pembelian");

    // db!.rawQuery(
    //     "ALTER TABLE tb_produk ADD harga_shopee_food INTEGER DEFAULT NULL");

    return db!.rawQuery('''
      select b.kode, a.qty, a.harga from tb_sub_detail_transaksi_pembelian a left join tb_produk b on a.id_barang = b.id where id_sub_transaksi = '$idTrx' and a.is_sync is null
      ''');
  }

  Future<List> pengembalian(
      idTransaksi, kode, keterangan, idPelanggan, kodePengembalian) async {
    Database? db = await createDatabase();

    final now = DateTime.now().toIso8601String();

    // 1. Update status pada detail transaksi

    final List<Map<String, dynamic>> produk = await db!.query(
      'tb_produk',
      where: 'kode = ?',
      whereArgs: [kode],
      limit: 1,
    );

    final produkData = produk.first;

    await db.update(
      'tb_detail_transaksi_pembelian',
      {'status': 4},
      where: 'id_barang = ? AND id_transaksi = ?',
      whereArgs: [produkData['id'], idTransaksi],
    );

    // 2. Ambil data transaksi yang akan diretur
    final List<Map<String, dynamic>> trans = await db.query(
      'tb_detail_transaksi_pembelian',
      where: 'id_barang = ? AND id_transaksi = ?',
      whereArgs: [produkData['id'], idTransaksi],
      limit: 1,
    );

    if (trans.isEmpty) {
      return []; // Jika tidak ada data, kembalikan list kosong
    }
    final transaksi = trans.first;

    var stok = produkData['stok'] + transaksi['qty'];

    // 3. Update stok produk
    await db.update(
      'tb_produk',
      {'stok': stok},
      where: 'kode = ?',
      whereArgs: [kode],
    );

    // 3. Simpan ke tb_pengembalian

    int pengembalianId = await db.insert('tb_pengembalian', {
      'kode': kodePengembalian,
      'id_transaksi': idTransaksi,
      'id_pelanggan': idPelanggan,
      'total': transaksi['harga'],
      'keterangan': keterangan ?? '',
      'created_at': now,
      'updated_at': now,
    });

    // 4. Simpan detail pengembalian
    await db.insert('tb_detail_pengembalian', {
      'id_pengembalian': pengembalianId,
      'id_produk': produkData['id'],
      'jumlah': transaksi['qty'],
      'harga': produkData['harga_jual'],
      'sub_total': transaksi['harga'],
      'created_at': now,
      'updated_at': now,
    });

    return [];
  }

  Future<bool> createPelanggan(nama, noHp, alamat, kode) async {
    Database? db = await createDatabase();
    db!.rawQuery('''
                  INSERT INTO pelanggan (nama, no_hp,alamat,kode)
                                 VALUES ('$nama','$noHp' ,'$alamat','$kode')
              ''');
    return true;
  }

  Future<bool> createSupplier(nama, noHp, alamat, kode) async {
    Database? db = await createDatabase();
    db!.rawQuery('''
                  INSERT INTO supplier (nama, no_hp,alamat,kode_supplier)
                                 VALUES ('$nama','$noHp' ,'$alamat','$kode')
              ''');
    return true;
  }

  Future<bool> updatePelanggan(id, nama, noHp, alamat, kode) async {
    Database? db = await createDatabase();
    db!.rawQuery('''
                  UPDATE pelanggan SET nama='$nama',no_hp='$noHp',alamat='$alamat' WHERE kode='$kode'
              ''');
    return true;
  }

  Future<bool> updateSupplier(id, nama, noHp, alamat, kode) async {
    Database? db = await createDatabase();
    db!.rawQuery('''
                  UPDATE supplier SET nama='$nama',no_hp='$noHp',alamat='$alamat' WHERE kode_supplier='$kode'
              ''');
    return true;
  }

  Future<List> pelanggan() async {
    Database? db = await createDatabase();

    return db!.query('pelanggan');
  }

  Future<List> supplier() async {
    Database? db = await createDatabase();

    return db!.query('supplier');
  }

  Future<bool> deletePelanggan(kode) async {
    Database? db = await createDatabase();
    db!.delete('pelanggan', where: 'kode = ?', whereArgs: [kode]);
    return true;
  }

  Future<bool> deleteSupplier(kode) async {
    Database? db = await createDatabase();
    db!.delete('supplier', where: 'kode_supplier = ?', whereArgs: [kode]);
    return true;
  }

  Future<String> generateCustomerCode(table, kolom) async {
    Database? db = await createDatabase();

    // Ambil pelanggan terakhir berdasarkan ID DESC
    final List<Map<String, dynamic>> result =
        await db!.rawQuery("SELECT * FROM $table ORDER BY id DESC LIMIT 1");

    int lastNumber;

    if (result.isNotEmpty) {
      final lastCode = result[0][kolom]; // Misalnya 'PLG0012'
      final numberPart =
          lastCode.replaceAll(RegExp(r'[^0-9]'), ''); // Ambil angka: '0012'
      lastNumber = int.tryParse(numberPart) ?? 0;
    } else {
      lastNumber = 0; // Kalau belum ada data, mulai dari 0
    }

    final newNumber = lastNumber + 1;
    final formattedNumber = newNumber.toString().padLeft(4, '0'); // Jadi '0001'
    final newCode = 'PLG$formattedNumber';

    return newCode;
  }

  Future<List> detailPemesanan(id) async {
    Database? db = await createDatabase();

    return db!.rawQuery('''
      select a.*, nama from tb_transaksi_pembelian a left join pelanggan b on a.id_pelanggan = b.id WHERE a.id = '$id'  ''');
  }

  Future<List<Map<String, dynamic>>> daftarDetailPemesanan(id) async {
    Database? db = await createDatabase();

    return db!.rawQuery('''
      select b.nama_barang,id_barang, kode,harga_jual, qty,harga,catatan from tb_detail_transaksi_pembelian a left join tb_produk b on a.id_barang = b.id WHERE id_transaksi = '$id'  ''');
  }

  Future<bool> insertHutang(idTrx, totalHutang, totalBayar, sisaHutang) async {
    Database? db = await createDatabase();
    db!.rawQuery('''
                  INSERT INTO tb_hutang (total_hutang, total_bayar,sisa_hutang,id_transaksi)
                                 VALUES ('$totalHutang','$totalBayar' ,'$sisaHutang','$idTrx')
              ''');
    return true;
  }

  Future<List<Map<String, dynamic>>> daftarHutang(id) async {
    Database? db = await createDatabase();

    return db!.rawQuery('''
      SELECT b.total_bayar, b.created_at FROM tb_transaksi_pembelian a left JOIN tb_hutang b on a.id = b.id_transaksi where id_transaksi = '$id' order by b.created_at desc ''');
  }

  Future<List> hitungAllPembelian(id) async {
    Database? db = await createDatabase();

    return db!.rawQuery(
        "select sum(b.harga) as harga_1,b.status,b.created_at from tb_detail_transaksi_pembelian b where b.id_transaksi = '$id' ");
  }

  Future<Map<String, String>> sisaHutang(id, bayar) async {
    Database? db = await createDatabase();

    final List<Map<String, dynamic>> result = await db!.rawQuery(
        "SELECT * FROM tb_hutang where id_transaksi = '$id' ORDER BY id DESC LIMIT 1");

    final List<Map<String, dynamic>> result2 = await db!.rawQuery(
        "SELECT sum(total_bayar) as total_bayar FROM tb_hutang where id_transaksi = '$id'");

    var pay = int.parse(bayar);
    var totalHutang = result[0]['total_hutang'];
    final sisaHutang = result[0]['sisa_hutang'] - pay;

    var totalBayar = result2[0]['total_bayar'];

    db.rawQuery(
        "update tb_transaksi_pembelian set  sisa_hutang = '$sisaHutang' , total_bayar = '$totalBayar' where id = '$id' ");

    if (sisaHutang <= 0) {
      db.rawQuery(
          "update tb_detail_transaksi_pembelian set  status = 2  where id_transaksi = '$id' ");
    }

    return {
      'total_hutang': totalHutang.toString(),
      'sisa_hutang': sisaHutang.toString(),
    };
  }

  Future<int> tapTotalPembelian(id) async {
    final List<Map<String, dynamic>> result = await db!
        .rawQuery("SELECT  total FROM tb_transaksi_pembelian where id = '$id'");

    return result[0]['total'] ?? 0;
  }

  Future<Map<String, dynamic>> getPenerimaanPengeluaranLaporan(
      String tglSearch) async {
    Database? db = await createDatabase();

    // final String mulai = '$tanggal';
    // final String selesai = '$tanggal 23:59:59';

    var mulaiNow;
    var selesaiNow;

    if (tglSearch != null) {
      var date = DateTime.parse(tglSearch.toString());
      var tanggalCari = DateFormat('dd-MM-yyyy').format(date);
      mulaiNow = tanggalCari;
      selesaiNow = tanggalCari + " 23:59:59";
    } else {
      var date = DateTime.parse(DateTime.now().toString());

      var tanggalNow = DateFormat('dd-MM-yyyy').format(date);
      mulaiNow = "$tanggalNow";
      selesaiNow = "$tanggalNow 23:59:59";
    }

    // Query penerimaan
    final List<Map<String, dynamic>> penerimaan = await db!.query(
      'tb_penerimaan',
      where: 'created_at = ?',
      whereArgs: [mulaiNow],
    );

    // Query pengeluaran
    final List<Map<String, dynamic>> pengeluaran = await db.query(
      'tb_pengeluaran',
      where: 'created_at = ?',
      whereArgs: [mulaiNow],
    );

    return {
      'penerimaan': penerimaan,
      'pengeluaran': pengeluaran,
    };
  }

  Future<List<Map<String, dynamic>>> listLaporanBulanan(
      String bulan, int status) async {
    Database? db = await createDatabase();

    // Format bulan: yyyy-MM
    final month = int.parse(bulan.substring(5, 7));
    final year = int.parse(bulan.substring(0, 4));

    // Query dari tb_detail_transaksi_pembelian
    final detailQuery = '''
    SELECT DATE(a.created_at) as tanggal,
           SUM((b.harga_jual - b.harga_beli) * a.qty) as laba,
           SUM(b.harga_jual * a.qty) as omset,
           d.created_at
    FROM tb_detail_transaksi_pembelian a
    LEFT JOIN tb_produk b ON a.id_barang = b.kode
    LEFT JOIN tb_transaksi_pembelian d ON a.id_transaksi = d.id
    WHERE strftime('%m', a.created_at) = ? 
      AND strftime('%Y', a.created_at) = ? 
      AND a.status = 2
      ${status != 0 ? 'AND d.status_bayar = ?' : ''}
    GROUP BY DATE(a.created_at)
  ''';

    // Query dari tb_sub_detail_transaksi_pembelian
    final subDetailQuery = '''
    SELECT DATE(a.created_at) as tanggal,
           SUM((b.harga_jual - b.harga_beli) * a.qty) as laba,
           SUM(b.harga_jual * a.qty) as omset,
           d.created_at
    FROM tb_sub_detail_transaksi_pembelian a
    LEFT JOIN tb_produk b ON a.id_barang = b.kode
    LEFT JOIN tb_transaksi_pembelian d ON a.id_transaksi = d.id
    WHERE strftime('%m', a.created_at) = ? 
      AND strftime('%Y', a.created_at) = ? 
      AND a.status = 2
      ${status != 0 ? 'AND d.status_bayar = ?' : ''}
    GROUP BY DATE(a.created_at)
  ''';

    // Parameter untuk bind query
    final params = status != 0
        ? [bulan.substring(5, 7), bulan.substring(0, 4), status]
        : [bulan.substring(5, 7), bulan.substring(0, 4)];

    // Jalankan kedua query
    final result1 = await db!.rawQuery(detailQuery, params);
    final result2 = await db.rawQuery(subDetailQuery, params);

    // Gabungkan hasil (union all)
    final combined = [...result1, ...result2];

    // Gabungkan per tanggal manual
    final Map<String, Map<String, dynamic>> grouped = {};

    for (var row in combined) {
      String tanggal = row['tanggal'].toString();
      if (!grouped.containsKey(tanggal)) {
        grouped[tanggal] = {
          'tanggal': tanggal,
          'laba': row['laba'] ?? 0,
          'omset': row['omset'] ?? 0,
        };
      } else {
        grouped[tanggal]!['laba'] += row['laba'] ?? 0;
        grouped[tanggal]!['omset'] += row['omset'] ?? 0;
      }
    }

    // Sort descending by tanggal
    final hasil = grouped.values.toList()
      ..sort((a, b) => b['tanggal'].compareTo(a['tanggal']));

    return hasil;
  }

  Future<Map<String, List<Map<String, dynamic>>>>
      getPenerimaanPengeluaranLaporanBulanan(
    String bulan, // format: YYYY-MM
  ) async {
    Database? db = await createDatabase();

    final bulanDate = DateTime.parse(bulan);
    final month = bulanDate.month;
    final year = bulanDate.year;

    // Format LIKE '2025-06%'
    final bulanFilter = '%${month.toString().padLeft(2, '0')}-$year%';

    // Penerimaan Harian dalam Bulan
    final penerimaan = await db!.rawQuery('''
    SELECT 
      MAX(id) as id,
      SUM(nilai) as nilai,
      DATE(created_at) as tanggal
    FROM tb_penerimaan
    WHERE created_at LIKE ?
    GROUP BY DATE(created_at)
    ORDER BY tanggal ASC
  ''', [bulanFilter]);

    // Pengeluaran Harian dalam Bulan
    final pengeluaran = await db.rawQuery('''
    SELECT 
      MAX(id) as id,
      SUM(nilai) as nilai,
      DATE(created_at) as tanggal
    FROM tb_pengeluaran
    WHERE created_at LIKE ?
    GROUP BY DATE(created_at)
    ORDER BY tanggal ASC
  ''', [bulanFilter]);

    return {
      'penerimaan': penerimaan,
      'pengeluaran': pengeluaran,
    };
  }

  Future<Map<String, dynamic>> laporanBulanan(String bulan, int status) async {
    Database? db = await createDatabase();

    final bulanDate = DateTime.parse(bulan);
    final month = bulanDate.month;
    final year = bulanDate.year;

    // Laba
    final labaQuery = await db!.rawQuery(
        '''
    SELECT SUM((b.harga_jual - b.harga_beli) * a.qty) AS total
    FROM tb_detail_transaksi_pembelian a
    LEFT JOIN tb_produk b ON a.id_barang = b.id
    LEFT JOIN tb_transaksi_pembelian c ON a.id_transaksi = c.id
    WHERE a.status = 2
      AND strftime('%m', a.created_at) = ?
      AND strftime('%Y', a.created_at) = ?
      ${status != 0 ? 'AND c.status_bayar = ?' : ''}
  ''',
        status != 0
            ? [month.toString().padLeft(2, '0'), year.toString(), status]
            : [month.toString().padLeft(2, '0'), year.toString()]);

    final resultLaba = labaQuery.first['total'] ?? 0;

    // Omzet
    final omsetQuery = await db.rawQuery(
        '''
    SELECT SUM(a.harga) as tot_harga
    FROM tb_detail_transaksi_pembelian a
    LEFT JOIN tb_produk b ON a.id_barang = b.id
    LEFT JOIN tb_transaksi_pembelian c ON c.id = a.id_transaksi
    WHERE a.status = 2
      AND strftime('%m', c.created_at) = ?
      AND strftime('%Y', c.created_at) = ?
      ${status != 0 ? 'AND c.status_bayar = ?' : ''}
  ''',
        status != 0
            ? [month.toString().padLeft(2, '0'), year.toString(), status]
            : [month.toString().padLeft(2, '0'), year.toString()]);

    final resultOmset = omsetQuery.first['tot_harga'] ?? 0;

    // Pemasukan
    final pemasukanQuery = await db.rawQuery('''
    SELECT SUM(nilai) as tot
    FROM tb_penerimaan
    WHERE strftime('%m', created_at) = ?
      AND strftime('%Y', created_at) = ?
  ''', [month.toString().padLeft(2, '0'), year.toString()]);

    final resultMasuk = pemasukanQuery.first['tot'] ?? 0;

    // Pengeluaran
    final pengeluaranQuery = await db.rawQuery('''
    SELECT SUM(nilai) as tot
    FROM tb_pengeluaran
    WHERE strftime('%m', created_at) = ?
      AND strftime('%Y', created_at) = ?
  ''', [month.toString().padLeft(2, '0'), year.toString()]);

    final resultKeluar = pengeluaranQuery.first['tot'] ?? 0;

    // Hitung laba bersih & total pemasukan
    final labaBersihTot =
        (resultLaba as num) + (resultMasuk as num) - (resultKeluar as num);
    final allIncome = (resultLaba as num) + (resultMasuk as num);

    return {
      'result_omset': resultOmset,
      'result_laba': resultLaba,
      'result_masuk': resultMasuk,
      'result_keluar': resultKeluar,
      'laba_bersih_tot': labaBersihTot,
      'all_income': allIncome,
    };
  }

  Future<List> konfigurasi() async {
    Database? db = await createDatabase();

    return db!.query('konfigurasi');
  }

  Future<List> updateKonfigurasi(status, nama) async {
    Database? db = await createDatabase();

    return db!.rawQuery(
        "update konfigurasi set  status = '$status'  where nama = '$nama' ");
  }

  Future<int> konfigurasiId1() async {
    // kategori  dan produk
    Database? db = await createDatabase();

    final List<Map<String, dynamic>> result =
        await db!.rawQuery("SELECT  * FROM konfigurasi where id = 1 ");

    return result[0]['status'] ?? 0;
  }

  Future<int> konfigurasiId2() async {
    // pencarian nama produk
    Database? db = await createDatabase();

    final List<Map<String, dynamic>> result =
        await db!.rawQuery("SELECT  * FROM konfigurasi where id = 2 ");

    return result[0]['status'] ?? 0;
  }

  Future<int> konfigurasiId3() async {
    // stok
    // pencarian nama produk
    Database? db = await createDatabase();

    final List<Map<String, dynamic>> result =
        await db!.rawQuery("SELECT  * FROM konfigurasi where id = 3 ");

    return result[0]['status'] ?? 0;
  }

  Future<int> konfigurasiId4() async {
    // stok
    // pencarian nama produk
    Database? db = await createDatabase();

    final List<Map<String, dynamic>> result =
        await db!.rawQuery("SELECT  * FROM konfigurasi where id = 4 ");

    return result[0]['status'] ?? 0;
  }

  Future<int?> getLastShiftId() async {
    Database? db = await createDatabase();

    final List<Map<String, dynamic>> result =
        await db!.rawQuery('SELECT id FROM tb_shift ORDER BY id DESC LIMIT 1');

    if (result.isNotEmpty) {
      return result.first['id'] as int;
    }
    return null;
  }

  Future<int> insertShift(idUser) async {
    Database? db = await createDatabase();

    final List<Map<String, dynamic>> result = await db!.rawQuery(
      'SELECT * FROM tb_shift ORDER BY id DESC LIMIT 1',
    );

    int saldoAwal = 0;

    if (result.isNotEmpty) {
      var lastShift = result.first;
      var saldoAkhir = lastShift['saldo_akhir'] as int?;
      var saldoSebelum = lastShift['saldo_awal'] as int? ?? 0;

      saldoAwal =
          (saldoAkhir == null || saldoAkhir == 0) ? saldoSebelum : saldoAkhir;
    }

    Map<String, dynamic> data = {
      'saldo_awal': saldoAwal,
      'waktu_buka': DateTime.now().toIso8601String(),
      'user_id': idUser,
    };

    return await db.insert('tb_shift', data);
  }

  Future<List> getSaldo() async {
    Database? db = await createDatabase();

    // db!.rawQuery('delete from tb_produk');
    return db!.rawQuery('select * from tb_shift order by id desc limit 5');
  }

  Future<double> getTotalHargaPembelian(int shiftId) async {
    final db = await createDatabase();

    // 1. Ambil tanggal dari transaksi pembelian
    final trans = await db!.rawQuery(
      'SELECT DATE(created_at) as tanggal FROM tb_transaksi_pembelian WHERE shift_id = ? LIMIT 1',
      [shiftId],
    );

    if (trans.isEmpty) return 0.0;

    final tanggal = trans.first['tanggal'] as String;
    final mulai = '$tanggal 00:00:00';
    final selesai = '$tanggal 23:59:59';

    // 2. Hitung total harga
    final result = await db.rawQuery('''
    SELECT SUM(b.harga) as tot_harga
    FROM tb_transaksi_pembelian a
    LEFT JOIN tb_detail_transaksi_pembelian b
      ON b.id_transaksi = a.id
    WHERE b.status = 2
      AND a.shift_id = ?
      AND b.created_at BETWEEN ? AND ?
  ''', [shiftId, mulai, selesai]);

    final totHarga = result.first['tot_harga'] ?? 0;
    return (totHarga as num).toDouble();
  }

  Future<List> updateSaldoAkhir(userId) async {
    Database? db = await createDatabase();

    final List<Map<String, dynamic>> result = await db!.rawQuery(
      'SELECT * FROM tb_shift ORDER BY id DESC LIMIT 1',
    );
//  var saldoAkhir = result.isNotEmpty ? (result.first['saldo_akhir'] ?? 0) : 0;
    var id = result.isNotEmpty ? (result.first['id'] ?? 0) : 0;

    var uangFisik = result.isNotEmpty ? (result.first['uang_fisik'] ?? 0) : 0;

    // Total pengeluaran
    final pengeluaranResult = await db.rawQuery(
      'SELECT SUM(nilai) as nilai FROM tb_pengeluaran WHERE shift_id = ?',
      [id],
    );

    // Total penerimaan
    final penerimaanResult = await db.rawQuery(
      'SELECT SUM(nilai) as nilai FROM tb_penerimaan WHERE shift_id = ?',
      [id],
    );

    final pengeluaran = pengeluaranResult.isNotEmpty
        ? (pengeluaranResult.first['nilai'] ?? 0)
        : 0;
    final penerimaan = penerimaanResult.isNotEmpty
        ? (penerimaanResult.first['nilai'] ?? 0)
        : 0;

    var saldoAwal = result.isNotEmpty ? (result.first['saldo_awal'] ?? 0) : 0;

    final totalHargaPembelian = await getTotalHargaPembelian(id);

    var saldoAkhir =
        (saldoAwal + penerimaan + totalHargaPembelian) - pengeluaran;

    var selisih = (uangFisik > 0) ? (uangFisik - saldoAkhir) : 0;

    return db.rawQuery(
        "update tb_shift set saldo_akhir = '$saldoAkhir', selisih = '$selisih' , waktu_tutup = datetime('now'), user_id = '$userId'  where id = '$id'");
  }

  Future<List> listSaldo(tanggal) async {
    Database? db = await createDatabase();

    final mulai = '$tanggal';

    final result = await db!.rawQuery('''
      SELECT saldo_awal, saldo_akhir, uang_fisik, selisih, DATE(created_at) as tanggal
      FROM tb_shift
      WHERE created_at LIKE ?
    ''', ['%$mulai%']);

    //   final result = await db!.rawQuery('''
    //   SELECT saldo_awal, saldo_akhir, uang_fisik, selisih, DATE(created_at) as tanggal
    //   FROM tb_shift
    // ''');

    return result;
  }

  Future<List<Map<String, dynamic>>> produkTerlaris(String bulan) async {
    Database? db = await createDatabase();

    var date = DateTime.now();
    var year = DateFormat('yyyy').format(date); // gunakan 4 digit tahun
    return await db!.rawQuery('''
    SELECT 
      pr.nama_barang,
      SUM(pd.qty) AS total_qty,
      SUM(pd.qty * pr.harga_jual) AS total_penjualan,
      SUM(pd.qty * (pr.harga_jual - pr.harga_beli)) AS lab
    FROM tb_detail_transaksi_pembelian pd
    JOIN tb_produk pr ON pr.id = pd.id_barang
   
    WHERE strftime('%m', pd.created_at) = ? 
      AND strftime('%Y', pd.created_at) = ?
    GROUP BY pr.id_barang
    ORDER BY total_qty DESC
    LIMIT 10
  ''', [bulan, year]);
  }

  Future<List> showKomisi() async {
    Database? db = await createDatabase();

    return db!.rawQuery('''
    SELECT 
            a.id,
            a.id_barang,
            a.qty,
            a.harga,
            a.catatan,
            a.id_transaksi,
            a.created_at,
            b.nama_barang,
            b.harga_jual,
            b.kode,
            e.total_transaksi,
            c.id as id_transaksi_tbl,
            c.user_id,
            COALESCE(d.name, 'Admin') as nama_user,
            COALESCE(e.total_transaksi, 0) as komisi
          FROM tb_detail_transaksi_pembelian a
          LEFT JOIN tb_produk b ON a.id_barang = b.id
          LEFT JOIN tb_transaksi_pembelian c ON a.id_transaksi = c.id
          LEFT JOIN users d ON c.user_id = d.id
          LEFT JOIN tb_komisi_penjualan e ON a.id_transaksi = e.id_transaksi
          ORDER BY a.created_at DESC
          ''');
    //  print(db?.path);
    // return db!.query('tb_transaksi_pembelian');
  }

  Future<Map<String, dynamic>?> getProdukIdByPkDanNama(
      int idPk, String namaProduk) async {
    Database? db = await createDatabase();

    final result = await db!.query(
      'tb_produk',
      where: 'id_pk = ? AND nama_barang = ?',
      whereArgs: [idPk, namaProduk],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return {
        'id': result.first['id'],
        'kode': result.first['kode'],
      };
    }

    return null;
  }

  Future<Map<String, dynamic>?> getProdukId(id) async {
    Database? db = await createDatabase();

    final result = await db!.query(
      'tb_produk',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return {
        'id': result.first['id'],
        'kode': result.first['kode'],
      };
    }

    return null;
  }

  Future<List<Map<String, dynamic>>> callSync(String table) async {
    Database? db = await createDatabase();

    final data = await db!.query(
      table,
      where: 'is_sync = ? OR is_sync IS NULL',
      whereArgs: [0],
    );

    if (data.isNotEmpty) {
      return data;
    }

    return [];
  }

  // ==================== STOCK OPNAME ====================

  Future<List> allStockOpname() async {
    Database? db = await createDatabase();
    return db!.query('tb_stock_opname', orderBy: 'created_at DESC');
  }

  Future<List<Map<String, dynamic>>> allStockOpnamePage(
      int limit, int offset) async {
    Database? db = await createDatabase();
    return db!.query('tb_stock_opname',
        orderBy: 'created_at DESC', limit: limit, offset: offset);
  }

  Future<int> countStockOpname() async {
    Database? db = await createDatabase();

    var result =
        await db!.rawQuery('SELECT COUNT(*) as count FROM tb_stock_opname');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> insertStockOpname(Map<String, dynamic> data) async {
    Database? db = await createDatabase();
    return db!.insert('tb_stock_opname', {
      ...data,
      'created_at': DateTime.now().toString(),
      'updated_at': DateTime.now().toString(),
    });
  }

  Future<int> updateStockOpname(Map<String, dynamic> data, int id) async {
    Database? db = await createDatabase();
    data['updated_at'] = DateTime.now().toString();
    return db!
        .update('tb_stock_opname', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteStockOpname(int id) async {
    Database? db = await createDatabase();
    return db!.delete('tb_stock_opname', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, dynamic>?> getStockOpnameById(int id) async {
    Database? db = await createDatabase();
    final result = await db!.query(
      'tb_stock_opname',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> syncStockOpname(int id) async {
    Database? db = await createDatabase();
    return db!.update(
      'tb_stock_opname',
      {'is_sync': 1, 'updated_at': DateTime.now().toString()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearStockOpname() async {
    Database? db = await createDatabase();
    await db!.delete('tb_stock_opname');
    await db
        .execute("DELETE FROM sqlite_sequence WHERE name='tb_stock_opname'");
  }

  // Produk Gudang Methods
  Future<int> createProdukGudang(Map<String, dynamic> data) async {
    Database? db = await createDatabase();
    return db!.insert('produk_gudang', data);
  }

  Future<List<Map<String, dynamic>>> getAllProdukGudang(idStokOpname) async {
    Database? db = await createDatabase();

    return await db!.query(
      'produk_gudang',
      where: 'id_stok_opname = ?',
      whereArgs: [idStokOpname],
      orderBy: 'updated_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getProdukGudang() async {
    Database? db = await createDatabase();

    return await db!.query(
      'produk_gudang',
      orderBy: 'updated_at DESC',
    );
  }

  Future<Map<String, dynamic>?> getProdukByBarcode(
    String barcode,
  ) async {
    Database? db = await createDatabase();

    final result = await db!.query(
      'produk_gudang',
      where: 'kode_item = ? OR kode_barcode = ?',
      whereArgs: [barcode, barcode],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  Future<List<Map<String, dynamic>>> getUnsyncProdukGudang() async {
    Database? db = await createDatabase();
    return db!.query('produk_gudang',
        where: 'is_sync = 0', orderBy: 'created_at ASC');
  }

  Future<int> updateProdukGudang(int id, Map<String, dynamic> data) async {
    Database? db = await createDatabase();
    return db!.update('produk_gudang', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> syncProdukGudang(int id) async {
    Database? db = await createDatabase();
    return db!.update(
      'produk_gudang',
      {'stok': 0, 'updated_at': DateTime.now().toString()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteProdukGudang(int id) async {
    Database? db = await createDatabase();
    return db!.delete('produk_gudang', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearSyncedProdukGudang() async {
    Database? db = await createDatabase();
    await db!.delete('produk_gudang', where: 'is_sync = 1');
  }

  Future<void> clearAllProdukGudang() async {
    Database? db = await createDatabase();
    await db!.delete('produk_gudang');
    await db.execute("DELETE FROM sqlite_sequence WHERE name='produk_gudang'");
  }

  Future<List<Map<String, dynamic>>> getHutangSupplier() async {
    final db = await createDatabase();

    return await db!.rawQuery('''
    SELECT 
      h.*, 
      s.nama as nama_supplier
    FROM tb_hutang_supplier h
    LEFT JOIN supplier s 
      ON s.kode_supplier = h.kode_supplier
    ORDER BY h.id DESC
    limit 100  
  ''');
  }

  Future<List<Map<String, dynamic>>> getPembayaranByHutang(
      String kodeHutang) async {
    final db = await createDatabase();

    return await db!.rawQuery('''
    SELECT *
    FROM tb_bayar_hutang_supplier
    WHERE kode_hutang = ?
    ORDER BY tanggal DESC
  ''', [kodeHutang]);
  }

  Future<void> bayarHutang({
    required String kodeHutang,
    required double jumlahBayar,
  }) async {
    final db = await createDatabase();

    await db!.transaction((txn) async {
      // 🔹 1. Ambil data hutang
      final hutang = await txn.query(
        'tb_hutang_supplier',
        where: 'kode_hutang = ?',
        whereArgs: [kodeHutang],
        limit: 1,
      );

      if (hutang.isEmpty) throw Exception("Hutang tidak ditemukan");

      final sisaLama = (hutang.first['sisa'] as num).toDouble();
      final dibayarLama = (hutang.first['dibayar'] as num?)?.toDouble() ?? 0;

      final sisaBaru = sisaLama - jumlahBayar;
      final dibayarBaru = dibayarLama + jumlahBayar;

      final statusBaru = sisaBaru <= 0 ? 'lunas' : 'belum_lunas';

      // 🔹 2. Insert pembayaran
      await txn.insert('tb_bayar_hutang_supplier', {
        'kode_hutang': kodeHutang,
        'jumlah_bayar': jumlahBayar,
        //'metode_pembayaran': 'cash',
        'keterangan': '',
        'tanggal': DateTime.now().toString(),
        'created_at': DateTime.now().toString(),
      });

      // 🔹 3. Update hutang
      await txn.update(
        'tb_hutang_supplier',
        {
          'sisa': sisaBaru,
          'dibayar': dibayarBaru,
          'status': statusBaru,
        },
        where: 'kode_hutang = ?',
        whereArgs: [kodeHutang],
      );
    });
  }

  Future<Map<String, dynamic>?> getHutangById(int id) async {
    final db = await createDatabase();

    final result = await db!.query(
      'tb_hutang_supplier',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  Future<double> getTotalSisaHutang() async {
    final db = await createDatabase();

    final result = await db!.rawQuery(
      "SELECT SUM(sisa) as total_sisa FROM tb_hutang_supplier",
    );

    if (result.isNotEmpty && result.first['total_sisa'] != null) {
      return (result.first['total_sisa'] as num).toDouble();
    }

    return 0.0;
  }

  Future<int> insertProdukGudang(Map<String, dynamic> data) async {
    final db = await createDatabase();
    return await db!.insert(
      'produk_gudang',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> insertStokOpname(
    Map<String, dynamic> data,
  ) async {
    final db = await createDatabase();

    return await db!.insert(
      'stok_opname',
      data,
    );
  }

  Future<List<Map<String, dynamic>>> getProdukGudangExportByOpname(
      idStokOpname) async {
    final db = await createDatabase();

    return await db!.rawQuery('''
    SELECT
      pg.*,
      so.nama_karyawan,
      so.nama_rak,
      so.tanggal
    FROM produk_gudang pg
    LEFT JOIN stok_opname so
      ON so.id = pg.id_stok_opname
    WHERE pg.id_stok_opname = ?
      AND CAST(pg.stok AS INTEGER) > 0
    ORDER BY pg.nama_item ASC
  ''', [idStokOpname]);
  }
}
