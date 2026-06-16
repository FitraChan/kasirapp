import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:kasirapp/model/pengeluaranModel.dart';
import 'package:kasirapp/helpers/dbkasir.dart';

import 'package:kasirapp/model/rupiahCurrency.dart';

//import 'package:kasirapp/master_data/tambahKategori.dart';

import 'package:kasirapp/network_utils/api.dart';
import 'package:kasirapp/screen/home.dart';
import 'package:kasirapp/transaksi/pengeluaran.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screen/menu1.dart';

//import 'package:firebase_messaging/firebase_messaging.dart';

class TambahPengeluaran extends StatefulWidget {
  const TambahPengeluaran({Key? key}) : super(key: key);

  @override
  _TambahPengeluaranState createState() => _TambahPengeluaranState();
}

class _TambahPengeluaranState extends State<TambahPengeluaran> {
  final TextEditingController _namaController = TextEditingController();

  final TextEditingController _nilaiController = TextEditingController();

  KasirHelper? helper;

  var kodes = [];

  var current;
  var currentString;
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    helper = KasirHelper();
  }

  final dbClient = KasirHelper.db;

  String removeCurrencyFormat(String formattedValue) {
    // Hapus semua karakter yang bukan angka
    String cleanValue = formattedValue.replaceAll(RegExp(r'[^\d]'), '');

    return cleanValue;
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tambah Pengeluaran',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Tambah Pengeluaran",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                /// Nama Pengeluaran
                TextFormField(
                  controller: _namaController,
                  decoration: InputDecoration(
                    labelText: "Nama Pengeluaran",
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// Nilai
                TextFormField(
                  controller: _nilaiController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CurrencyInputFormatter(),
                  ],
                  decoration: InputDecoration(
                    labelText: "Nilai (Rp)",
                    prefixIcon: const Icon(Icons.attach_money),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                /// Tombol Simpan
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isLoading ? null : _simpanPengeluaran,
                    child: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            "Simpan",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _simpanPengeluaran() async {
    if (_namaController.text.isEmpty || _nilaiController.text.isEmpty) {
      EasyLoading.showError("Lengkapi data terlebih dahulu");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    SharedPreferences localStorage = await SharedPreferences.getInstance();

    final current = DateTime.now();
    final currentString = DateFormat('dd-MM-yyyy').format(current);

    String nilaiFormattedValue = removeCurrencyFormat(_nilaiController.text);

    final nilaiParse = int.parse(nilaiFormattedValue);

    PengeluaranModel kat = PengeluaranModel({
      'keterangan': _namaController.text,
      'nilai': nilaiParse,
      'created_at': currentString,
      'shift_id': int.parse(localStorage.getString('shift_id') ?? '0'),
    });

    final lastId = await helper!.createPengeluaran(kat);

    setState(() {
      _isLoading = false;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const Pengeluaran(title: '', tambah: 1)),
    );

    await sendToMysql(lastId, _namaController.text, nilaiParse);

    EasyLoading.showSuccess("Berhasil disimpan");

    //Navigator.pop(context);
  }

  sendToMysql(id, keterangan, nilai) async {
    // imageFile = File(imagePath!);
    try {
      Map data = {
        'id': id.toString(),
        'keterangan': keterangan,
        'nilai': nilai,
      };

      String url;

      url = 'createPengeluaran';

      // final response = await htpp.post(Uri.parse(url), body: data);
      final response = await Network().getData_post(data, url);
      // var c = json.decode(response.body);

      if (response.statusCode == 200) {
        await helper!.sync(id, 'id', 'tb_pengeluaran');
      } else {
        print(response.body);
        throw Exception('Failed to load album');
      }
    } on Exception catch (exception) {
      // only executed if error is of type Exception

      EasyLoading.showSuccess(exception.toString());
    } catch (error) {
      // EasyLoading.show(status: error.toString());
      EasyLoading.showSuccess(error.toString());
      // executed for errors of all types other than Exception
    }
  }

  Container tambahProd() {
    return Container(
        margin: const EdgeInsets.only(left: 8, top: 8),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 260,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5)),
                child: TextFormField(
                  style: const TextStyle(color: Color(0xFF000000)),
                  cursorColor: const Color(0xFF9b9b9b),
                  keyboardType: TextInputType.text,
                  controller: _namaController,
                  decoration: InputDecoration(
                    fillColor: Colors.grey,
                    prefixIcon: const Icon(
                      Icons.email,
                      color: Colors.grey,
                    ),
                    hintText: "Nama Pengeluaran",
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: BorderSide(
                        color: Colors.blue.shade900,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 8),
                child: Text("Nilai", style: TextStyle(color: Colors.blue[900])),
              ),
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 260,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5)),
                child: TextFormField(
                  style: const TextStyle(color: Color(0xFF000000)),
                  cursorColor: const Color(0xFF9b9b9b),
                  keyboardType: TextInputType.number,
                  controller: _nilaiController,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CurrencyInputFormatter(),
                  ],
                  decoration: InputDecoration(
                    fillColor: Colors.grey,
                    prefixIcon: const Icon(
                      Icons.email,
                      color: Colors.grey,
                    ),
                    hintText: "Nilai",
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: BorderSide(
                        color: Colors.blue.shade900,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
              ),
            ]));
  }

  @override
  void dispose() {
    // Membersihkan sumber daya saat widget dihapus
    // myController.dispose();

    _namaController.dispose();
    _nilaiController.dispose();

    super.dispose();
  }
}
