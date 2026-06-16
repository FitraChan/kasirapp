import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'package:kasirapp/master_data/master.dart';

import 'package:kasirapp/model/kategoriModel.dart';
import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:kasirapp/network_utils/api.dart';
import 'package:kasirapp/screen/home.dart';
import '../screen/menu1.dart';

//import 'package:firebase_messaging/firebase_messaging.dart';

class Registrasi extends StatefulWidget {
  const Registrasi({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _RegistrasiState createState() => _RegistrasiState();
}

class _RegistrasiState extends State<Registrasi> {
  //  FirebaseMessaging messaging;
  final _formKey = GlobalKey<FormState>();

  String name = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  Toko? selectedToko;
  int? selectedTokoId;

  bool passwordVisible = false;
  bool confirmPasswordVisible = false;
  bool _isLoading = false;

  void _register() async {
    setState(() {
      _isLoading = true;
    });

    Map data = {
      'id_toko': selectedTokoId,
      'name': name,
      'email': email,
      'password': password,
      'level': 2,
    };

    String url;

    url = 'register';

    // final response = await htpp.post(Uri.parse(url), body: data);
    // final response = await Network().getData_post(data, url);

    final response = await http.post(
      Uri.parse("https://kasir.mbcconsulting.id/api/register"),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode(data),
    );
    // var c = json.decode(response.body);

    if (response.statusCode == 200) {
      print('sukses');
    } else {
      print(response.body);
      throw Exception('Failed to load album');
    }
    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Register berhasil')),
    );

    Navigator.pop(context); // kembali ke login
  }

  void togglePassword() {
    setState(() {
      passwordVisible = !passwordVisible;
    });
  }

  void toggleConfirmPassword() {
    setState(() {
      confirmPasswordVisible = !confirmPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
          child: Column(
            children: [
              const Text(
                "Register",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    /// NAME
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Nama',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Nama wajib diisi';
                        }
                        name = value;
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    /// EMAIL
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Email wajib diisi';
                        }
                        email = value;
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    Autocomplete<Toko>(
                      displayStringForOption: (Toko option) => option.namaToko,
                      optionsBuilder:
                          (TextEditingValue textEditingValue) async {
                        if (textEditingValue.text.length < 2) {
                          return const Iterable<Toko>.empty();
                        }

                        return await fetchToko(textEditingValue.text);
                      },
                      onSelected: (Toko selection) {
                        setState(() {
                          selectedToko = selection;
                          selectedTokoId = selection.id;

                          print("Selected ID: ${selection.id}");
                        });
                      },
                      fieldViewBuilder:
                          (context, controller, focusNode, onFieldSubmitted) {
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: const InputDecoration(
                            labelText: "Cari Toko",
                            border: OutlineInputBorder(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    /// PASSWORD
                    TextFormField(
                      obscureText: !passwordVisible,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: togglePassword,
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Password wajib diisi';
                        }
                        password = value;
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    /// CONFIRM PASSWORD
                    TextFormField(
                      obscureText: !confirmPasswordVisible,
                      decoration: InputDecoration(
                        hintText: 'Konfirmasi Password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(confirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: toggleConfirmPassword,
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Konfirmasi password wajib diisi';
                        }
                        if (value != password) {
                          return 'Password tidak sama';
                        }
                        confirmPassword = value;
                        return null;
                      },
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.app_registration),
                        label: Text(
                          _isLoading ? "Processing..." : "Register",
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _register();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<Toko>> fetchToko(String query) async {
    //var url = 'search?q=$query';

    final response = await http.get(
      Uri.parse("https://kasir.mbcconsulting.id/api/toko/search?q=$query"),
      headers: {"Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => Toko.fromJson(json)).toList();
    } else {
      throw Exception("Gagal ambil data");
    }
  }
}

class Toko {
  final int id;
  final String namaToko;

  Toko({required this.id, required this.namaToko});

  factory Toko.fromJson(Map<String, dynamic> json) {
    return Toko(
      id: json['id'],
      namaToko: json['nama_toko'],
    );
  }

  @override
  String toString() => namaToko;
}
