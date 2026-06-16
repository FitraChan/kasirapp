// import 'package:bluetooth_print/bluetooth_print.dart';
// import 'package:bluetooth_print/bluetooth_print_model.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:kasirapp/network_utils/api.dart';
import 'package:kasirapp/screen/home.dart';
import 'package:kasirapp/transaksi/transPenjualan.dart';

class HapusTransaksi extends StatefulWidget {
  const HapusTransaksi({
    Key? key,
  }) : super(key: key);

  @override
  _HapusTransaksiState createState() => _HapusTransaksiState();
}

class _HapusTransaksiState extends State<HapusTransaksi> {
  KasirHelper? helper;

  @override
  void initState() {
    super.initState();

    helper = KasirHelper();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const Home(
                      title: '',
                    )),
          );
          return Future.value(true);
        },
        child: Scaffold(
            appBar: AppBar(title: const Text('Hapus Pemesanan')),
            body: Center(
                child: Column(
              children: [
                truncateAllPemesanan(),
                truncateAllinOut(),
                truncateAllProduk(),
                truncateBarangMasuk(),
                truncateMutasiAndKas(),
              ],
            ))));
  }

  Container truncateBarangMasuk() {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      width: 150,
      child: FloatingActionButton.extended(
        onPressed: () {
          hapusBarangMasuk();
        },
        heroTag: 'uniqueTag11',
        label: const Text('Hapus Barang Masuk'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),
    );
  }

  Container truncateMutasiAndKas() {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      width: 150,
      child: FloatingActionButton.extended(
        onPressed: () {
          hapusMutasiAndKasAndHutang();
        },
        heroTag: 'uniqueTag15',
        label: const Text('Hapus Mutasi & Kas & Hutang Supplier'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),
    );
  }

  Container truncateAllProduk() {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      width: 150,
      child: FloatingActionButton.extended(
        onPressed: () {
          truncateProduk();
        },
        heroTag: 'uniqueTag1',
        label: const Text('Hapus Produk'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),
    );
  }

  Container truncateAllPemesanan() {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      width: 150,
      child: FloatingActionButton.extended(
        onPressed: () {
          truncatePemesanan();
        },
        label: const Text('Hapus Pemesanan'),
        heroTag: 'uniqueTag2',
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),
    );
  }

  Container truncateAllinOut() {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      width: 150,
      child: FloatingActionButton.extended(
        onPressed: () {
          // truncatePemesanan();
          truncateInOut();
        },
        heroTag: 'uniqueTag4',
        label: const Text('Hapus In / Out'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
      ),
    );
  }

  void hapusBarangMasuk() async {
    helper!.truncateBarangMasuk().then((course) {
      print(course);
    });

    mysqlBarangMasuk();
  }

  void hapusMutasiAndKasAndHutang() async {
    helper!.truncateMutasiAndKas().then((course) {
      print(course);
    });

    mysqlTruncateKasAndStokAndHutang();
  }

  void truncateProduk() async {
    // ini hapus produk , kategori, supplier, dan pk_ac
    helper!.truncateProduk().then((course) {
      print(course);
    });

    //mysqlProduk();
  }

  void truncateInOut() async {
    helper!.truncateInOut().then((course) {
      print(course);
    });

    mysqlTruncateInOut();
  }

  void truncatePemesanan() async {
    helper!.truncatePemesanan().then((course) {
      print(course);
    });

    mysqlTruncatePemesanan();
  }

  void mysqlTruncateInOut() async {
    String url;

    url = 'truncate_in_out';

    // final response = await htpp.post(Uri.parse(url), body: data);
    final response = await Network().getData_post('', url);
    // var c = json.decode(response.body);

    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: 'HAPUS IN/OUT SUKSES',
        toastLength: Toast
            .LENGTH_SHORT, // Duration for which the toast should be visible
        gravity: ToastGravity.BOTTOM, // Position of the toast on the screen
        // Font size of the message
      );
    } else {
      print(response.body);
      Fluttertoast.showToast(
        msg: 'HAPUS IN/OUT GAGAL',
        toastLength: Toast
            .LENGTH_SHORT, // Duration for which the toast should be visible
        gravity: ToastGravity.BOTTOM, // Position of the toast on the screen
        // Font size of the message
      );
    }
  }

  void mysqlTruncateKasAndStokAndHutang() async {
    String url;

    url = 'truncate_kas_and_stok';

    // final response = await htpp.post(Uri.parse(url), body: data);
    final response = await Network().getData_post('', url);
    // var c = json.decode(response.body);

    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: 'HAPUS KAS & STOK SUKSES',
        toastLength: Toast
            .LENGTH_SHORT, // Duration for which the toast should be visible
        gravity: ToastGravity.BOTTOM, // Position of the toast on the screen
        // Font size of the message
      );
    } else {
      print(response.body);
      Fluttertoast.showToast(
        msg: 'HAPUS KAS & STOK GAGAL',
        toastLength: Toast
            .LENGTH_SHORT, // Duration for which the toast should be visible
        gravity: ToastGravity.BOTTOM, // Position of the toast on the screen
        // Font size of the message
      );
    }
  }

  void mysqlTruncatePemesanan() async {
    String url;

    url = 'truncate_pemesanan';

    // final response = await htpp.post(Uri.parse(url), body: data);
    final response = await Network().getData_post('', url);
    // var c = json.decode(response.body);

    if (response.statusCode == 200) {
      //print('sukses');
      Fluttertoast.showToast(
        msg: 'HAPUS PEMESANAN SUKSES',
        toastLength: Toast
            .LENGTH_SHORT, // Duration for which the toast should be visible
        gravity: ToastGravity.BOTTOM, // Position of the toast on the screen
        // Font size of the message
      );
    } else {
      print(response.body);
      Fluttertoast.showToast(
        msg: 'HAPUS PEMESANAN GAGAL',
        toastLength: Toast
            .LENGTH_SHORT, // Duration for which the toast should be visible
        gravity: ToastGravity.BOTTOM, // Position of the toast on the screen
        // Font size of the message
      );
    }
  }

  void mysqlBarangMasuk() async {
    String url;

    url = 'truncate_barang_masuk';

    // final response = await htpp.post(Uri.parse(url), body: data);
    final response = await Network().getData_post('', url);
    // var c = json.decode(response.body);

    if (response.statusCode == 200) {
      //print('sukses');
      Fluttertoast.showToast(
        msg: 'HAPUS BARANG MASUK SUKSES',
        toastLength: Toast
            .LENGTH_SHORT, // Duration for which the toast should be visible
        gravity: ToastGravity.BOTTOM, // Position of the toast on the screen
        // Font size of the message
      );
    } else {
      print(response.body);
      Fluttertoast.showToast(
        msg: 'HAPUS BARANG MASUK GAGAL',
        toastLength: Toast
            .LENGTH_SHORT, // Duration for which the toast should be visible
        gravity: ToastGravity.BOTTOM, // Position of the toast on the screen
        // Font size of the message
      );
    }
  }

  void mysqlProduk() async {
    String url;

    url = 'truncate_produk';

    // final response = await htpp.post(Uri.parse(url), body: data);
    final response = await Network().getData_post('', url);
    // var c = json.decode(response.body);

    if (response.statusCode == 200) {
      //print('sukses');
      Fluttertoast.showToast(
        msg: 'HAPUS PRODUK SUKSES',
        toastLength: Toast
            .LENGTH_SHORT, // Duration for which the toast should be visible
        gravity: ToastGravity.BOTTOM, // Position of the toast on the screen
        // Font size of the message
      );
    } else {
      print(response.body);
      Fluttertoast.showToast(
        msg: 'HAPUS PRODUK GAGAL',
        toastLength: Toast
            .LENGTH_SHORT, // Duration for which the toast should be visible
        gravity: ToastGravity.BOTTOM, // Position of the toast on the screen
        // Font size of the message
      );
    }
  }
}
