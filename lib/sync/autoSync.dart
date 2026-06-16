import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:kasirapp/master_data/tambahProduk.dart';
import 'package:kasirapp/network_utils/api.dart';
import 'package:kasirapp/helpers/dbkasir.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class SyncService {
  KasirHelper? helper;

  Future<void> autoSyncSavePembayaran() async {
    helper = KasirHelper();

    var detailTransaksi =
        await helper!.callSync('tb_detail_transaksi_pembelian');

    var urlDetail = "save_detail_trans_pembelian";

    for (var itemTrans in detailTransaksi) {
      try {
        Map dataDetail = {
          'kode_transaksi': itemTrans['kode_transaksi'],
          'id_transaksi': itemTrans['id_transaksi'],
          'id_barang': itemTrans['id_barang'],
          'harga': itemTrans['harga'],
          'qty': itemTrans['qty'],
          'status': itemTrans['status'],
          'catatan': itemTrans['catatan'],
          'created_at': itemTrans['created_at'],
        };
        final response = await Network().getData_post(dataDetail, urlDetail);

        if (response.statusCode == 200) {
          await helper!.sync(itemTrans['kode_transaksi'], 'kode_transaksi',
              'tb_detail_transaksi_pembelian');

          print("Transaksi ${itemTrans['kode_transaksi']} berhasil sync");
        }
      } catch (e) {
        print("Error sync $e");
      }
    }

    var transaksi = await helper!.callSync('tb_transaksi_pembelian');
    var url = "save_pembayaran";
    for (var item in transaksi) {
      try {
        Map data = {
          'proses_sync': 1,
          'total': item['total'],
          'id_transaksi': item['id'],
          'id_pembeli': item['id_pembeli'],
          'status_bayar': item['status_bayar'],
          'created_at': item['created_at'],
          'kode_transaksi': item['kode_transaksi']
        };
        final response = await Network().getData_post(data, url);

        if (response.statusCode == 200) {
          await helper!.sync(item['id'], 'id', 'tb_transaksi_pembelian');

          print("Transaksi ${item['id']} berhasil sync");

          print("Boooodyyyy ${response.body} ");
        }
      } catch (e) {
        print("Error sync $e");
      }
    }
  }

  // Future<void> autoSyncSavePenjualan() async {
  //   helper = KasirHelper();
  //   var transaksi = await helper!.callSync('tb_detail_transaksi_pembelian');
  //   var url = "save_detail_trans_pembelian";
  //   for (var item in transaksi) {
  //     try {
  //       Map data = {
  //         'id_barang': item['id_barang'],
  //         'qty': item['qty'],
  //         'harga': item['harga'],
  //         'status': item['status'],
  //         'catatan': item['catatan'],
  //         'created_at': item['created_at'],
  //         'kode_transaksi': item['kode_transaksi'],
  //       };
  //       final response = await Network().getData_post(data, url);

  //       if (response.statusCode == 200) {
  //         await helper!.sync(item['id'], 'id', 'tb_detail_transaksi_pembelian');

  //         print("Transaksi ${item['id']} berhasil sync");
  //       }
  //     } catch (e) {
  //       print("Error sync $e");
  //     }
  //   }
  // }

  Future<void> autoSyncBarangMasuk() async {
    helper = KasirHelper();

    var transaksi = await helper!.callSync('barang_masuk');

    var url = "createBarangMasuk";
    for (var item in transaksi) {
      print('masuk auto sync barang masuk');

      try {
        Map data = {
          // 'id': id.toString(),
          'no_transaksi': item['no_transaksi']?.toString() ?? '',
          'tanggal': item['tanggal']?.toString() ?? '',
          "kode_produk": item['kode_produk'],
          "kode_supplier": item['kode_supplier'],
          'qty': item['qty'],
          'harga_beli': item['harga_beli']?.toString() ?? '0',
          'total': item['total']?.toString() ?? '0',
          'keterangan': item['keterangan']?.toString() ?? '',
          'metode_pembayaran': item['metode_pembayaran']?.toString() ?? '',
        };
        final response = await Network().getData_post(data, url);

        if (response.statusCode == 200) {
          await helper!.sync(item['id'], 'id', 'barang_masuk');

          print("Transaksi ${item['id']} berhasil sync");
        }
      } catch (e) {
        print("Error sync $e");
      }
    }
  }

  Future<void> autoSyncPenerimaan() async {
    helper = KasirHelper();

    var transaksi = await helper!.callSync('tb_penerimaan');

    var url = "createPenerimaan";
    for (var item in transaksi) {
      try {
        Map data = {
          'id': item['id'],
          'keterangan': item['keterangan'],
          'nilai': item['nilai'],
        };
        final response = await Network().getData_post(data, url);

        if (response.statusCode == 200) {
          await helper!.sync(item['id'], 'id', 'tb_penerimaan');

          print("Transaksi ${item['id']} berhasil sync");
        }
      } catch (e) {
        print("Error sync $e");
      }
    }
  }

  Future<void> autoSyncPengeluaran() async {
    helper = KasirHelper();

    var transaksi = await helper!.callSync('tb_pengeluaran');

    var url = "createPengeluaran";
    for (var item in transaksi) {
      try {
        Map data = {
          'id': item['id'],
          'keterangan': item['keterangan'],
          'nilai': item['nilai'],
        };
        final response = await Network().getData_post(data, url);

        if (response.statusCode == 200) {
          await helper!.sync(item['id'], 'id', 'tb_pengeluaran');

          print("Transaksi ${item['id']} berhasil sync");
        }
      } catch (e) {
        print("Error sync $e");
      }
    }
  }

  Future<void> autoSyncProduk() async {
    helper = KasirHelper();

    var transaksi = await helper!.callSync('tb_produk');

    var url = "add_produk_by_sync";
    print('masuk home: ');

    for (var item in transaksi) {
      try {
        File file = await base64ToFile(item['gambar']);
        FormData formData = FormData.fromMap({
          'nama_barang': item['nama_barang'],
          'kode': item['kode'],
          'id_kategori': item['id_kategori'],
          'harga_beli': item['harga_beli'],
          'harga_jual': item['harga_jual'] ?? 0,
          'shopee_food': item['shopee_food'] ?? 0,
          'go_food': item['go_food'] ?? 0,
          'stok': item['stok'],
          'created_at': item['created_at'],
          'keterangan': item['id_kategori'],
          'gambar': await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
        });

        final response = await Network().getData_postDio(formData, url);

        if (response.statusCode == 200) {
          await helper!.sync(item['id'], 'id', 'tb_produk');
          print("Produk ${item['id']} berhasil sync");

          print(response.data);
        }
      } catch (e) {
        print("Error sync $e");
      }
    }
  }

  Future<File> base64ToFile(String base64String) async {
    final bytes = base64Decode(base64String);

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/temp_image.jpg');

    await file.writeAsBytes(bytes);

    return file;
  }

  Future<void> autoSyncSaveKategori() async {
    helper = KasirHelper();
    var transaksi = await helper!.callSync('tb_kategori');
    var url = "save_sync_kategori";
    for (var item in transaksi) {
      try {
        Map data = {
          'id': item['id'],
          'kode': item['kode'],
          'nama_kategori': item['nama_kategori'],
        };
        final response = await Network().getData_post(data, url);

        if (response.statusCode == 200) {
          await helper!.sync(item['id'], 'id', 'tb_kategori');
          print("Transaksi ${item['id']} berhasil sync");
        }
      } catch (e) {
        print("Error sync $e");
      }
    }
  }

  Future<void> autoSyncSaveSupplier() async {
    helper = KasirHelper();
    var transaksi = await helper!.callSync('supplier');
    var url = "simpanSupplier";
    for (var item in transaksi) {
      try {
        Map data = {
          'nama': item['id'],
          'no_hp': item['no_hp'],
          'alamat': item['alamat'],
          'kode_supplier': item['kode_supplier'],
        };
        final response = await Network().getData_post(data, url);

        if (response.statusCode == 200) {
          await helper!.sync(item['id'], 'id', 'supplier');
          print("Transaksi ${item['id']} berhasil sync");
        }
      } catch (e) {
        print("Error sync $e");
      }
    }
  }

  Future<void> autoSyncKomisi() async {
    helper = KasirHelper();
    var transaksi = await helper!.callSync('tb_komisi_penjualan');
    var url = "simpanKomisi";
    for (var item in transaksi) {
      try {
        Map data = {
          'id_komisi': item['id'],
        };
        final response = await Network().getData_post(data, url);

        if (response.statusCode == 200) {
          await helper!.sync(item['id'], 'id', 'tb_komisi_penjualan');
          print("Transaksi ${item['id']} berhasil sync");
        }
      } catch (e) {
        print("Error sync $e");
      }
    }
  }
}
