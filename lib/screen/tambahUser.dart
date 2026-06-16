import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/services.dart';
import 'package:kasirapp/network_utils/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TambahUser extends StatefulWidget {
  const TambahUser({Key? key}) : super(key: key);

  @override
  State<TambahUser> createState() => _TambahUserState();
}

class _TambahUserState extends State<TambahUser> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _namaTokoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _konfirmasiPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    getToko();
  }

  String level = '2';

  bool hidePassword = true;
  bool hideKonfirmasiPassword = true;

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
            'Tambah User',
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
                "Detail User",
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
                      /// EMAIL
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: "Email",
                          prefixIcon: const Icon(Icons.email_outlined),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// NAMA
                      TextFormField(
                        controller: _namaController,
                        decoration: InputDecoration(
                          labelText: "Nama",
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

                      /// LEVEL
                      DropdownButtonFormField<String>(
                        value: level,
                        items: const [
                          DropdownMenuItem(
                            value: '2',
                            child: Text('Kasir'),
                          ),
                          DropdownMenuItem(
                            value: '1',
                            child: Text('Admin'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            level = value!;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: "Level",
                          prefixIcon: const Icon(Icons.admin_panel_settings),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// NAMA TOKO
                      DropdownButtonFormField<String>(
                        value: selectedToko,
                        items: tokoList.map<DropdownMenuItem<String>>((item) {
                          return DropdownMenuItem<String>(
                            value: item['id'].toString(),
                            child: Text(item['nama_toko']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedToko = value;
                          });
                        },
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

                      /// PASSWORD
                      TextFormField(
                        controller: _passwordController,
                        obscureText: hidePassword,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              hidePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                hidePassword = !hidePassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// KONFIRMASI PASSWORD
                      TextFormField(
                        controller: _konfirmasiPasswordController,
                        obscureText: hideKonfirmasiPassword,
                        decoration: InputDecoration(
                          labelText: "Konfirmasi Password",
                          prefixIcon: const Icon(Icons.lock_reset_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              hideKonfirmasiPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                hideKonfirmasiPassword =
                                    !hideKonfirmasiPassword;
                              });
                            },
                          ),
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

  String? selectedToko;
  var tokoList = [];
  Future<void> getToko() async {
    try {
      EasyLoading.show(status: "Mengambil data toko...");

      final response = await Network().getData_get('toko');

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        print(data);

        /// contoh jika response array
        setState(() {
          tokoList = data['data'];
        });

        EasyLoading.dismiss();
      } else {
        EasyLoading.dismiss();

        print(response.body);

        throw Exception('Gagal mengambil data toko');
      }
    } catch (e) {
      EasyLoading.dismiss();

      print(e.toString());

      EasyLoading.showError(e.toString());
    }
  }

  Future<void> _simpanData() async {
    // if (_emailController.text.isEmpty ||
    //     _namaController.text.isEmpty ||
    //     _namaTokoController.text.isEmpty ||
    //     _passwordController.text.isEmpty ||
    //     _konfirmasiPasswordController.text.isEmpty) {
    //   EasyLoading.showError("Semua field wajib diisi");
    //   return;
    // }

    if (_passwordController.text != _konfirmasiPasswordController.text) {
      EasyLoading.showError("Konfirmasi password tidak sama");
      return;
    }

    EasyLoading.show(status: "Menyimpan...");

    Map<String, dynamic> data = {
      'email': _emailController.text,
      'name': _namaController.text,
      'level': level,
      'id_toko': selectedToko,
      'password': _passwordController.text,
    };

    final response = await Network().getData_post(data, 'register');
    // var c = json.decode(response.body);

    if (response.statusCode == 200) {
    } else {
      print(response.body);
      throw Exception('Failed to load album');
    }

    print(data);

    /// SIMPAN SQLITE / API DI SINI

    EasyLoading.dismiss();

    EasyLoading.showSuccess("User berhasil ditambahkan");

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _namaController.dispose();
    _namaTokoController.dispose();
    _passwordController.dispose();
    _konfirmasiPasswordController.dispose();

    super.dispose();
  }
}
