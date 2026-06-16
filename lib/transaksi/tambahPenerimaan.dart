import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:kasirapp/model/penerimaanModel.dart';
import 'package:kasirapp/helpers/dbkasir.dart';

import 'package:kasirapp/model/rupiahCurrency.dart';

//import 'package:kasirapp/master_data/tambahKategori.dart';

import 'package:kasirapp/network_utils/api.dart';
import 'package:kasirapp/screen/home.dart';
import 'package:kasirapp/transaksi/penerimaan.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screen/menu1.dart';

//import 'package:firebase_messaging/firebase_messaging.dart';

class TambahPenerimaan extends StatefulWidget {
  const TambahPenerimaan({Key? key}) : super(key: key);

  @override
  _TambahPenerimaanState createState() => _TambahPenerimaanState();
}

class _TambahPenerimaanState extends State<TambahPenerimaan> {
  final TextEditingController _namaController = TextEditingController();

  final TextEditingController _nilaiController = TextEditingController();

  KasirHelper? helper;

  var kodes = [];

  var current;
  var currentString;

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
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop(false);
          return Future.value(true);
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Tambah Penerimaan',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          // drawer: const Menu(),

          backgroundColor: Colors.grey[300],
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                const Text(
                  "Detail Penerimaan",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        /// Nama
                        TextFormField(
                          controller: _namaController,
                          decoration: InputDecoration(
                            labelText: "Nama Penerimaan",
                            prefixIcon: const Icon(Icons.description_outlined),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
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
                            labelText: "Nilai",
                            prefixIcon: const Icon(Icons.payments_outlined),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                /// Tombol Simpan
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _simpanData,
                    child: const Text(
                      "Simpan",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ));
  }

  Future<void> _simpanData() async {
    if (_namaController.text.isEmpty || _nilaiController.text.isEmpty) {
      EasyLoading.showError("Field tidak boleh kosong");
      return;
    }

    SharedPreferences localStorage = await SharedPreferences.getInstance();

    DateTime now = DateTime.now();
    String tanggal = DateFormat('dd-MM-yyyy').format(now);

    String cleanNilai = removeCurrencyFormat(_nilaiController.text);

    int nilaiParse = int.parse(cleanNilai);

    PenerimaanModel kat = PenerimaanModel({
      'keterangan': _namaController.text,
      'nilai': nilaiParse,
      'created_at': tanggal,
      'shift_id': int.parse(localStorage.getString('shift_id') ?? '0'),
    });

    EasyLoading.show(status: "Menyimpan...");

    final lastId = await helper!.createPenerimaan(kat);

    EasyLoading.dismiss();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const Penerimaan(
          title: '',
          tambah: 1,
        ),
      ),
    );

    sendToMysql(lastId, _namaController.text, nilaiParse);
  }

  void sendToMysql(id, keterangan, nilai) async {
    // imageFile = File(imagePath!);
    try {
      Map data = {
        'id': id.toString(),
        'keterangan': keterangan,
        'nilai': nilai,
      };

      String url;

      url = 'createPenerimaan';

      // final response = await htpp.post(Uri.parse(url), body: data);
      final response = await Network().getData_post(data, url);
      // var c = json.decode(response.body);

      if (response.statusCode == 200) {
        await helper!.sync(id, 'id', 'tb_penerimaan');
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
                    hintText: "Nama Penerimaan",
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
