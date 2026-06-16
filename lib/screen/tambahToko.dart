import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:kasirapp/network_utils/api.dart';

class TambahToko extends StatefulWidget {
  const TambahToko({Key? key}) : super(key: key);

  @override
  State<TambahToko> createState() => _TambahTokoState();
}

class _TambahTokoState extends State<TambahToko> {
  final TextEditingController _namaTokoController = TextEditingController();

  final TextEditingController _alamatController = TextEditingController();

  final TextEditingController _pemilikController = TextEditingController();

  final TextEditingController _noHpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(false);
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          title: const Text(
            'Tambah Toko',
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              const Text(
                "Detail Toko",
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
                      /// NAMA TOKO
                      TextFormField(
                        controller: _namaTokoController,
                        decoration: InputDecoration(
                          labelText: "Nama Toko",
                          prefixIcon: const Icon(Icons.store_outlined),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// ALAMAT
                      TextFormField(
                        controller: _alamatController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: "Alamat",
                          prefixIcon: const Icon(Icons.location_on_outlined),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// PEMILIK
                      TextFormField(
                        controller: _pemilikController,
                        decoration: InputDecoration(
                          labelText: "Pemilik",
                          prefixIcon: const Icon(Icons.person_outline),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// NO HP
                      TextFormField(
                        controller: _noHpController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          labelText: "No HP",
                          prefixIcon: const Icon(Icons.phone_outlined),
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

              /// BUTTON SIMPAN
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
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _simpanData() async {
    if (_namaTokoController.text.isEmpty ||
        _alamatController.text.isEmpty ||
        _pemilikController.text.isEmpty ||
        _noHpController.text.isEmpty) {
      EasyLoading.showError("Semua field wajib diisi");
      return;
    }

    try {
      EasyLoading.show(status: "Menyimpan...");

      Map<String, dynamic> data = {
        "nama_toko": _namaTokoController.text,
        "alamat": _alamatController.text,
        "pemilik": _pemilikController.text,
        "no_hp": _noHpController.text,
      };

      final response = await Network().getData_post(data, 'toko');

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);

        print(result);

        EasyLoading.dismiss();

        EasyLoading.showSuccess("Toko berhasil ditambahkan");

        Navigator.pop(context);
      } else {
        EasyLoading.dismiss();

        print(response.body);

        EasyLoading.showError("Gagal menambahkan toko");
      }
    } catch (e) {
      EasyLoading.dismiss();

      print(e.toString());

      EasyLoading.showError(e.toString());
    }
  }

  @override
  void dispose() {
    _namaTokoController.dispose();
    _alamatController.dispose();
    _pemilikController.dispose();
    _noHpController.dispose();

    super.dispose();
  }
}
