import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kasirapp/model/pembayaranModel.dart';
import 'package:kasirapp/model/rupiahCurrency.dart';
import 'package:kasirapp/model/transaksiPembelianModel.dart';
import 'package:kasirapp/network_utils/api.dart';
import 'package:kasirapp/screen/login.dart';
import 'package:kasirapp/transaksi/transPenjualan.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/dbkasir.dart';

class PembayaranHutang extends StatefulWidget {
  final String tanggal;
  final int idPelanggan;
  const PembayaranHutang(
      {super.key, required this.tanggal, required this.idPelanggan});

  @override
  State<PembayaranHutang> createState() => _PembayaranHutangState();
}

class _PembayaranHutangState extends State<PembayaranHutang> {
  final TextEditingController _namaPelangganController =
      TextEditingController();
  final TextEditingController _catatanController = TextEditingController();
  final TextEditingController _pembayaranDimuka = TextEditingController();

  var current;
  var currentString;

  List allTrans = [];

  List Trans = [];
  //List Trans = [];
  int? idTrx = 0;
  List<List> AllData = [];

  List<List> all = [];
  var selectDetailPembelian = [];
  List detailTrans = [];
  List allDetailTransaksi = [];
  KasirHelper? helper;
  var allPembayaran = [];
  var pembayaran = [];
  var count = 0;
  var allCount;
  var allDetailTrans = [];
  var DetailTrans = [];
  var namaBarang;
  var qty;
  var hargaBarang;
  var allSubPembayaran = [];
  var subPembayaran = [];
  var subCount;
  var totalAllCount;

  @override
  void initState() {
    // _loadUserData();
    current = DateTime.parse(DateTime.now().toString());

    currentString = DateFormat('yyyy-MM-dd HH:mm:ss').format(current);

    helper = KasirHelper();
    //   _hitung();
    if (helper != null) {
      helper!.hitungPembelian().then((course) {
        setState(() {
          allPembayaran = course;
          pembayaran = allPembayaran;
          count = pembayaran.first['harga'] ?? 0;

          //_isLoading = false;
        });
      });

      helper!.hitungSubPembelian().then((course) {
        setState(() {
          allSubPembayaran = course;
          subPembayaran = allSubPembayaran;
          subCount = subPembayaran.first['harga'] ?? 0;

          totalAllCount = count + subCount;

          //appendValue(totalAllCount.toString());
        });
      });
    }

    if (helper != null) {
      helper!.showPembelian().then((courses) {
        setState(() {
          allDetailTrans = courses;
          DetailTrans = allDetailTrans;
        });
      });
    }

    if (helper != null) {
      helper!.showPembelianAndToping().then((courses) {
        setState(() {
          allTrans = courses;
          Trans = allTrans;
        });

        for (var x = 0; x < Trans.length; x++) {
          idTrx = 0;
          idTrx = Trans[x]['id_sub_transaksi'];

          AllData = [];
          helper!.listSubDetailTransaksi(idTrx).then((cou) {
            selectDetailPembelian = cou;
            for (var a = 0; a < 1; a++) {
              allDetailTransaksi = cou;
              detailTrans = allDetailTransaksi;
              AllData.add(detailTrans);
            }
            setState(() {
              all = AllData;
            });

            //print(AllData);
          });
        }
      });
    }

    // _loadUserData();

    super.initState();
  }

  double totalBelanja = 150000; // contoh total belanja
  final List<Map<String, dynamic>> metodePembayaran = [
    {"id": 1, "label": "Cash"},
    {"id": 2, "label": "Non Tunai"},
  ];

  String removeCurrencyFormat(String formattedValue) {
    // Hapus semua karakter yang bukan angka
    String cleanValue = formattedValue.replaceAll(RegExp(r'[^\d]'), '');

    return cleanValue;
  }

  String? name;
  int? idUser;
  String? level;
  _loadUserData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    //print(localStorage.getString('user'));

    var a = localStorage.getString('user');

    //print(user);

    if (a != null) {
      var user = jsonDecode(localStorage.getString('user') ?? '');

      setState(() {
        name = user['name'];

        idUser = user['id'];
        level = user['level'].toString();
      });
    } else {
      // Login();

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    }
  }

  int? selectedId;
  bool value = true;

  void simpanTransaksiHutang() async {
    var dates = DateTime.parse(currentString);

    SharedPreferences localStorage = await SharedPreferences.getInstance();

    var formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(dates);

    var allTotal = int.parse(count.toString());

    String bayarDimuka = _pembayaranDimuka.text != ''
        ? removeCurrencyFormat(_pembayaranDimuka.text)
        : '';

    var sisaHutang =
        allTotal - (bayarDimuka != '' ? int.parse(bayarDimuka) : 0);

    TransaksiPembelianModel beli = TransaksiPembelianModel({
      'total': allTotal,
      'id_pembeli': idUser,
      'status_bayar': selectedId,
      'keterangan': '',
      'created_at': formattedDate,
      'id_pelanggan': widget.idPelanggan,
      'total_hutang': allTotal,
      'total_bayar': bayarDimuka != '' ? int.parse(bayarDimuka) : 0,
      'sisa_hutang': sisaHutang,
      'shift_id': int.parse(localStorage.getString('shift_id') ?? '0'),
    });

    helper!.createTransaksiPembelian(beli);

    var pembelian = [];
    var selectDetailPembelian = [];

    var idTrx;
    if (helper != null) {
      helper!.idPembelian().then((courses) {
        setState(() {
          //allDetailTrans = courses;
          pembelian = courses;
          idTrx = pembelian.first['id'];

          helper!.insertHutang(idTrx, allTotal,
              bayarDimuka != '' ? int.parse(bayarDimuka) : 0, sisaHutang);

          //_isLoading = false;

          PembayaranModel bayar = PembayaranModel({
            'total': allTotal,
            'id_transaksi': idTrx,
            'created_at': formattedDate,
            'dibayar': bayarDimuka != '' ? int.parse(bayarDimuka) : 0,
            //'kembalian': cashBack,
          });

          helper!.createPembayaran(bayar);

          helper!.updateDetailTransaksiPembelianHutang(idTrx);

          helper!.selectDetailTransaksiPembelian(idTrx).then((cou) {
            selectDetailPembelian = cou;

            // var panj = selectDetailPembelian.length;

            for (var a = 0; a < selectDetailPembelian.length; a++) {
              // print(selectDetailPembelian[a]['harga']);

              var idBar = selectDetailPembelian[a]['id_barang'];
              var stock = selectDetailPembelian[a]['stok'];
              var jum = selectDetailPembelian[a]['qty'];

              helper!.updateStok(idBar, stock, jum, 0);
            }

            //allDetailTrans = courses;
          });
        });

        mysqlCreatePembayaran(allTotal, idTrx, bayarDimuka, '', idUser,
            formattedDate, sisaHutang, widget.idPelanggan);
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaksi hutang berhasil disimpan')),
    );
  }

  var hasil;

  void mysqlCreatePembayaran(total, idTrx, dibayar, kembali, idUser, createdAt,
      sisaHutang, idPelanggan) async {
    Map data = {
      'total': total,
      'id_transaksi': idTrx,
      'dibayar': dibayar != '' ? int.parse(dibayar) : 0,
      'kembalian': kembali,
      'id_pembeli': idUser,
      'status_bayar': selectedId,
      'created_at': createdAt,
      'sisa_hutang': sisaHutang,
      'total_hutang': total,
      'total_bayar': dibayar != '' ? int.parse(dibayar) : 0,
      'id_pelanggan': idPelanggan,
    };

    String url;

    url = 'save_pembayaran';

    // final response = await htpp.post(Uri.parse(url), body: data);
    final response = await Network().getData_post(data, url);
    // var c = json.decode(response.body);

    if (response.statusCode == 200) {
      print('sukses');

      await helper!.sync(idTrx, 'id', 'tb_transaksi_pembelian');
      await helper!
          .sync(idTrx, 'id_transaksi', 'tb_detail_transaksi_pembelian');

      await helper!.sync(idTrx, 'id_transaksi', 'tb_hutang');

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TransPenjualan(
                  tanggal: currentString,
                  delivery: '1',
                  idPembayaran: 0,
                )),
      );
    } else {
      print(response.body);
      throw Exception('Failed to load album');
    }
  }

  final oCcy = NumberFormat.decimalPattern();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Pembayaran Hutang'),
          backgroundColor: Colors.red[700],
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Belanja: Rp ${oCcy.format(count)}',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Metode Pembayaran',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedId,
                  items: metodePembayaran.map((item) {
                    return DropdownMenuItem<int>(
                      value: item['id'],
                      child: Text(item['label']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedId = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _pembayaranDimuka,
                  maxLines: 2,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CurrencyInputFormatter(),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Pembayaran Dimuka',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _catatanController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Catatan (opsional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan sebagai Hutang'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  onPressed: simpanTransaksiHutang,
                ),
              ],
            ),
          ),
        ));
  }
}
