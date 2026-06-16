import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
//import 'package:kasirapp/helpers/databaseRepository.dart';
//import 'package:kasirapp/laporan/menuLaporan.dart';

import 'package:intl/intl.dart';
import 'package:kasirapp/main.dart';
import 'package:kasirapp/screen/coba.dart';
import 'package:kasirapp/screen/cobaDetail.dart';
import 'package:kasirapp/screen/cobaTambah.dart';
import 'package:kasirapp/screen/config.dart';
import 'package:kasirapp/screen/tambahToko.dart';
import 'package:kasirapp/screen/tambahUser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kasirapp/master_data/master.dart';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
//import 'package:kasirapp/pengeluaran/pengeluaranUmum.dart';
//import 'package:kasirapp/screen/login.dart';
import 'package:kasirapp/screen/home.dart';
import 'package:kasirapp/screen/login.dart';
import 'package:kasirapp/screen/registrasi.dart';
import 'package:kasirapp/sync/backUpAll.dart';
import 'package:kasirapp/sync/print.dart';
import 'package:kasirapp/transaksi/hapusTransaksi.dart';
import 'package:kasirapp/transaksi/penerimaan.dart';
import 'package:kasirapp/transaksi/pengeluaran.dart';
import 'package:kasirapp/screen/barcodeScan.dart';

//import 'package:kasirapp/screen/menuSync.dart';

//import 'package:kasirapp/transaksi/penjualan.dart';

import '../helpers/dbkasir.dart';
import '../laporan/menuLaporan.dart';
import '../model/penerimaanModel.dart';
import '../model/pengeluaranModel.dart';
import '../network_utils/api.dart';
import '../transaksi/penjualan.dart';

class Menu extends StatefulWidget {
  const Menu({
    Key? key,
  }) : super(key: key);

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  //  FirebaseMessaging messaging;
  KasirHelper? helper;

  bool isAuth = false;
  TextEditingController keteranganPenerimaan = TextEditingController();
  TextEditingController nilaiPenerimaan = TextEditingController();
  TextEditingController keterangan = TextEditingController();
  TextEditingController nilai = TextEditingController();

  @override
  void initState() {
    helper = KasirHelper();
    _loadUserData();
    super.initState();
  }

  String? name;

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
        level = user['level'];
        // nim = user['str_user_name'];
      });
    } else {
      // Login();

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: draw(),
    );
  }

  ListView draw() {
    return ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: <Widget>[
        const DrawerHeader(
          decoration: BoxDecoration(
              color: Color.fromARGB(143, 143, 136, 136),
              image: DecorationImage(
                  fit: BoxFit.fill, image: AssetImage('images/sunset.jpg'))),
          child: Text(
            'Side menu',
            style: TextStyle(color: Colors.white, fontSize: 25),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const Home(
                        title: '',
                      )),
            );
          },
          child: Center(
            child: Container(
              height: 70,
              width: 300,
              margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: Card(
                  color: Colors.grey,
                  child: Row(children: [
                    Stack(children: <Widget>[
                      Container(
                        width: 80,
                        height: 92,
                        color: const Color.fromARGB(255, 116, 177, 226),
                      ),
                      Positioned(
                        left: 15.0,
                        top: 15,
                        child: Container(
                          alignment: Alignment.topCenter,
                          width: 50,
                          height: 40,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('images/home2.png'),
                              fit: BoxFit.fill,
                            ),
                            //shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ]),
                    Container(
                      width: 212,
                      height: 92,
                      padding: const EdgeInsets.only(top: 38, left: 8),
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.white, Colors.grey.shade300])),
                      child: const Text(
                        "Home",
                      ),
                      //color: Colors.grey[200],
                    )
                  ])),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Coba()),
            );
          },
          child: Center(
            child: Container(
              height: 70,
              width: 300,
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Card(
                  color: Colors.grey,
                  child: Row(children: [
                    Stack(children: <Widget>[
                      Container(
                        width: 80,
                        height: 92,
                        color: const Color.fromARGB(255, 6, 167, 152),
                      ),
                      Positioned(
                        left: 15.0,
                        top: 15,
                        child: Container(
                          alignment: Alignment.topCenter,
                          width: 50,
                          height: 40,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('images/master_data.png'),
                              fit: BoxFit.fill,
                            ),
                            //shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ]),
                    Container(
                      width: 212,
                      height: 92,
                      padding: const EdgeInsets.only(top: 38, left: 8),
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.white, Colors.grey.shade300])),
                      child: const Text(
                          //"Master Data",
                          "Coba"),
                      //color: Colors.grey[200],
                    )
                  ])),
            ),
          ),
        ),

        if (level == '5') ...[
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TambahToko()),
              );
            },
            child: Center(
              child: SizedBox(
                height: 70,
                width: 300,
                child: Card(
                    child: Row(children: [
                  Stack(children: <Widget>[
                    Container(
                      width: 80,
                      height: 92,
                      color: Colors.blue,
                    ),
                    Positioned(
                      left: 15.0,
                      top: 5,
                      child: Container(
                        alignment: Alignment.topCenter,
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('images/outcome.png'),
                            fit: BoxFit.fill,
                          ),
                          //shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const Positioned(
                        top: 65,
                        left: 15,
                        child: Text("Outcome",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)))
                  ]),
                  Container(
                    width: 212,
                    height: 92,
                    padding: const EdgeInsets.only(top: 40, left: 8),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.white, Colors.grey.shade300])),
                    child: const Text(
                      "Tambah Toko",
                    ),
                    //color: Colors.grey[200],
                  )
                ])),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TambahUser()),
              );
            },
            child: Center(
              child: SizedBox(
                height: 70,
                width: 300,
                child: Card(
                    child: Row(children: [
                  Stack(children: <Widget>[
                    Container(
                      width: 80,
                      height: 92,
                      color: const Color.fromARGB(255, 116, 177, 226),
                    ),
                    Positioned(
                      left: 15.0,
                      top: 5,
                      child: Container(
                        alignment: Alignment.topCenter,
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('images/income.png'),
                            fit: BoxFit.fill,
                          ),
                          //shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const Positioned(
                        top: 65,
                        left: 15,
                        child: Text("Income",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)))
                  ]),
                  Container(
                    width: 212,
                    height: 92,
                    padding: const EdgeInsets.only(top: 40, left: 8),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.white, Colors.grey.shade300])),
                    child: const Text(
                      "Tambah User",
                    ),
                    //color: Colors.grey[200],
                  )
                ])),
              ),
            ),
          ),
        ],

        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Config(
                        title: '',
                      )),
            );
          },
          child: Center(
            child: SizedBox(
              height: 70,
              width: 300,
              child: Card(
                  child: Row(children: [
                Stack(children: <Widget>[
                  Container(
                    width: 80,
                    height: 92,
                    color: const Color.fromARGB(255, 241, 91, 92),
                  ),
                  Positioned(
                    left: 15.0,
                    top: 7,
                    child: Container(
                      alignment: Alignment.topCenter,
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('images/troly.png'),
                          fit: BoxFit.fill,
                        ),
                        //shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const Positioned(
                      top: 65,
                      left: 22,
                      child: Text("Sales",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)))
                ]),
                Container(
                  width: 212,
                  height: 92,
                  padding: const EdgeInsets.only(top: 32, left: 8),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.white, Colors.grey.shade300])),
                  child: const Text(
                    "Konfigurasi",
                  ),
                  //color: Colors.grey[200],
                )
              ])),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MenuLaporan()),
            );
          },
          child: Center(
            child: SizedBox(
              height: 70,
              width: 300,
              child: Card(
                  child: Row(children: [
                Stack(children: <Widget>[
                  Container(
                    width: 80,
                    height: 92,
                    color: const Color.fromARGB(255, 114, 98, 137),
                  ),
                  Positioned(
                    left: 15.0,
                    top: 7,
                    child: Container(
                      alignment: Alignment.topCenter,
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('images/graf.png'),
                          fit: BoxFit.fill,
                        ),
                        //shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const Positioned(
                      top: 65,
                      left: 18,
                      child: Text("Report",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)))
                ]),
                Container(
                  width: 212,
                  height: 92,
                  padding: const EdgeInsets.only(top: 38, left: 8),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.white, Colors.grey.shade300])),
                  child: const Text(
                    "Laporan",
                  ),
                  //color: Colors.grey[200],
                ),
              ])),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Print()),
            );
          },
          child: Center(
            child: SizedBox(
              height: 70,
              width: 300,
              child: Card(
                  child: Row(children: [
                Stack(children: <Widget>[
                  Container(
                    width: 80,
                    height: 92,
                    color: const Color.fromARGB(255, 185, 183, 187),
                  ),
                  Positioned(
                    left: 15.0,
                    top: 7,
                    child: Container(
                      alignment: Alignment.topCenter,
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('images/printer.png'),
                          fit: BoxFit.fill,
                        ),
                        //shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const Positioned(
                      top: 65,
                      left: 18,
                      child: Text("Printer",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)))
                ]),
                Container(
                  width: 212,
                  height: 92,
                  padding: const EdgeInsets.only(top: 38, left: 8),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.white, Colors.grey.shade300])),
                  child: const Text(
                    "Pilih Printer",
                  ),
                  //color: Colors.grey[200],
                ),
              ])),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const Registrasi(
                        title: '',
                      )),
            );
          },
          child: Center(
            child: SizedBox(
              height: 70,
              width: 300,
              child: Card(
                  child: Row(children: [
                Stack(children: <Widget>[
                  Container(
                    width: 80,
                    height: 92,
                    color: const Color.fromARGB(255, 207, 201, 201),
                  ),
                  Positioned(
                    left: 15.0,
                    top: 7,
                    child: Container(
                      alignment: Alignment.topCenter,
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('images/plus.png'),
                          fit: BoxFit.fill,
                        ),
                        //shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const Positioned(
                      top: 65,
                      left: 18,
                      child: Text("Daftar",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)))
                ]),
                Container(
                  width: 212,
                  height: 92,
                  padding: const EdgeInsets.only(top: 38, left: 8),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.white, Colors.grey.shade300])),
                  child: const Text(
                    "Daftar",
                  ),
                  //color: Colors.grey[200],
                ),
              ])),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HapusTransaksi()),
            );
          },
          child: Center(
            child: SizedBox(
              height: 70,
              width: 300,
              child: Card(
                  child: Row(children: [
                Stack(children: <Widget>[
                  Container(
                    width: 80,
                    height: 92,
                    color: const Color.fromARGB(255, 207, 201, 201),
                  ),
                  Positioned(
                    left: 15.0,
                    top: 7,
                    child: Container(
                      alignment: Alignment.topCenter,
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('images/plus.png'),
                          fit: BoxFit.fill,
                        ),
                        //shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const Positioned(
                      top: 65,
                      left: 18,
                      child: Text("Hapus Transaksi",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)))
                ]),
                Container(
                  width: 212,
                  height: 92,
                  padding: const EdgeInsets.only(top: 38, left: 8),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.white, Colors.grey.shade300])),
                  child: const Text(
                    "Hapus Transaksi",
                  ),
                  //color: Colors.grey[200],
                ),
              ])),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const BackUpAll(
                        title: '',
                      )),
            );
          },
          child: Center(
            child: SizedBox(
              height: 70,
              width: 300,
              child: Card(
                  child: Row(children: [
                Stack(children: <Widget>[
                  Container(
                    width: 80,
                    height: 92,
                    color: const Color.fromARGB(255, 207, 201, 201),
                  ),
                  Positioned(
                    left: 15.0,
                    top: 7,
                    child: Container(
                      alignment: Alignment.topCenter,
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('images/data.png'),
                          fit: BoxFit.fill,
                        ),
                        //shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const Positioned(
                      top: 65,
                      left: 18,
                      child: Text("Back Up",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)))
                ]),
                Container(
                  width: 212,
                  height: 92,
                  padding: const EdgeInsets.only(top: 38, left: 8),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.white, Colors.grey.shade300])),
                  child: const Text(
                    "Back up",
                  ),
                  //color: Colors.grey[200],
                ),
              ])),
            ),
          ),
        ),
        // GestureDetector(
        //   onTap: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //           builder: (context) => const BarcodeScanScreen()),
        //     );
        //   },
        //   child: Center(
        //     child: SizedBox(
        //       height: 70,
        //       width: 300,
        //       child: Card(
        //           child: Row(children: [
        //         Stack(children: <Widget>[
        //           Container(
        //             width: 80,
        //             height: 92,
        //             color: const Color.fromARGB(255, 156, 39, 176),
        //           ),
        //           Positioned(
        //             left: 15.0,
        //             top: 7,
        //             child: Container(
        //               alignment: Alignment.topCenter,
        //               width: 50,
        //               height: 50,
        //               decoration: const BoxDecoration(
        //                 image: DecorationImage(
        //                   image: AssetImage('images/scan.png'),
        //                   fit: BoxFit.fill,
        //                 ),
        //               ),
        //             ),
        //           ),
        //           const Positioned(
        //               top: 65,
        //               left: 8,
        //               child: Text("Scan Barcode",
        //                   style: TextStyle(
        //                       color: Colors.white,
        //                       fontWeight: FontWeight.bold,
        //                       fontSize: 15)))
        //         ]),
        //         Container(
        //           width: 212,
        //           height: 92,
        //           padding: const EdgeInsets.only(top: 38, left: 8),
        //           decoration: BoxDecoration(
        //               gradient: LinearGradient(
        //                   begin: Alignment.topCenter,
        //                   end: Alignment.bottomCenter,
        //                   colors: [Colors.white, Colors.grey.shade300])),
        //           child: const Text(
        //             "Scan Barcode",
        //           ),
        //         ),
        //       ])),
        //     ),
        //   ),
        // ),

        GestureDetector(
          onTap: () {
            logout('token', 'user', 'selected_device');
          },
          child: Center(
            child: SizedBox(
              height: 70,
              width: 300,
              child: Card(
                  child: Row(children: [
                Stack(children: <Widget>[
                  Container(
                    width: 80,
                    height: 92,
                    color: const Color.fromARGB(255, 241, 91, 92),
                  ),
                  Positioned(
                    left: 15.0,
                    top: 7,
                    child: Container(
                      alignment: Alignment.topCenter,
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('images/logout.png'),
                          fit: BoxFit.fill,
                        ),
                        //shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const Positioned(
                      top: 65,
                      left: 18,
                      child: Text("Log Out",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)))
                ]),
                Container(
                  width: 212,
                  height: 92,
                  padding: const EdgeInsets.only(top: 38, left: 8),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.white, Colors.grey.shade300])),
                  child: const Text(
                    "Log Out",
                  ),
                  //color: Colors.grey[200],
                ),
              ])),
            ),
          ),
        ),
      ],
    );
  }

  void logout(String token, String user, String device) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // String url = 'getSaldoAkhir';

      // // panggil API
      // final response = await Network().getData_post(null, url);

      // print(response.body);

      //var body = json.decode(response.body);

      if (helper != null) {
        var user = jsonDecode(prefs.getString('user') ?? '');
        await helper!.updateSaldoAkhir(user['id']);
      }
      // hapus session
      await prefs.remove('token');
      await prefs.remove('user');
      await prefs.remove('shift_id');

      await prefs.remove('kategori');
      await prefs.remove('pencarian');
      await prefs.remove('stok');
      await prefs.remove('kategoriDalamContainer');

      // await prefs.remove(device); // kalau memang perlu

      // redirect ke login
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      }
    } catch (e, stackTrace) {
      debugPrint("Error saat logout: $e");
      debugPrint(stackTrace.toString());

      // optional: tampilkan snackbar atau dialog biar user tahu
      EasyLoading.show(status: e.toString());
    }
  }

  TextEditingController tanggalAwal = TextEditingController();
  TextEditingController tanggalAwalPenerimaan = TextEditingController();
  void showDialogWithFieldsPenerimaan() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final DateTime now = DateTime.now();
        final DateFormat formatter = DateFormat('dd-MM-yyyy');
        final String formatted = formatter.format(now);
        // var sekarang = DateTime.parse(DateTime.now().toString());

        tanggalAwal = TextEditingController(text: formatted.toString());
        final format = DateFormat("dd-MM-yyyy");
        return AlertDialog(
          content: StatefulBuilder(
            // You need this, notice the parameters below:
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                children: [
                  SizedBox(
                    // ignore: sort_child_properties_last
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: const Text(
                            "Penerimaan",
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          child: DateTimeField(
                            validator: (value) {
                              if (value == null) {
                                return 'Please enter a date';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              hintText: "Tanggal",
                              labelText: "Tanggal",
                              // prefixText: _currency,
                            ),
                            format: format,
                            controller: tanggalAwalPenerimaan,
                            onShowPicker: (context, currentValue) {
                              return showDatePicker(
                                  context: context,
                                  firstDate: DateTime(1900),
                                  initialDate: currentValue ?? DateTime.now(),
                                  lastDate: DateTime(2100));
                            },
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          child: const Text(
                            "Keterangan",
                            style: TextStyle(
                                fontSize: 15,
                                color: Color.fromARGB(255, 109, 107, 107)),
                          ),
                        ),
                        Container(
                            //  margin: EdgeInsets.only(top: 10),
                            //  width: 20,
                            child: TextField(
                          style: const TextStyle(color: Color(0xFF000000)),
                          cursorColor: const Color(0xFF9b9b9b),
                          keyboardType: TextInputType.text,
                          controller: keteranganPenerimaan,
                          decoration: const InputDecoration(
                            hintText: "Penerimaan",
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.normal),
                          ),
                        )),
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          child: const Text(
                            "Nilai",
                            style: TextStyle(
                                fontSize: 15,
                                color: Color.fromARGB(255, 109, 107, 107)),
                          ),
                        ),
                        Container(
                            //  margin: EdgeInsets.only(top: 10),
                            //  width: 20,
                            child: TextField(
                          style: const TextStyle(color: Color(0xFF000000)),
                          cursorColor: const Color(0xFF9b9b9b),
                          keyboardType: TextInputType.number,
                          controller: nilaiPenerimaan,
                          decoration: const InputDecoration(
                            hintText: "Nilai",
                            hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                                fontWeight: FontWeight.normal),
                          ),
                        )),
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          child: const Text(
                            "Diambil Dari",
                            style: TextStyle(
                                fontSize: 15,
                                color: Color.fromARGB(255, 109, 107, 107)),
                          ),
                        ),
                        Container(
                            //  margin: EdgeInsets.only(top: 10),
                            //  width: 20,
                            child: const TextField(
                          style: TextStyle(color: Color(0xFF000000)),
                          cursorColor: Color(0xFF9b9b9b),
                          keyboardType: TextInputType.number,
                          //controller: nilai,
                          decoration: InputDecoration(
                            hintText: "Kas",
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.normal),
                          ),
                        )),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                margin: const EdgeInsets.only(top: 10),
                                width: 110,
                                child: FloatingActionButton.extended(
                                  backgroundColor:
                                      const Color.fromARGB(255, 95, 151, 236),
                                  label: const Text(
                                    'Simpan',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  onPressed: () async {
                                    final DateFormat formatter2 =
                                        DateFormat('yyyy-MM-dd HH:mm:ss');
                                    final String tanggalan =
                                        formatter2.format(now);
                                    var idTrx;
                                    var pembelian = [];

                                    var nilaiParse =
                                        int.parse(nilaiPenerimaan.text);

                                    //    var status = 1;

                                    PenerimaanModel course = PenerimaanModel({
                                      'nilai': nilaiParse,
                                      'keterangan': keteranganPenerimaan.text,
                                      'created_at': tanggalan,
                                    });
                                    helper!.createPenerimaan(course);

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const Home(
                                                title: "",
                                              )),
                                    );

                                    mysqlCreatePenerimaan(
                                        nilaiParse, keteranganPenerimaan.text);
                                  },
                                )),
                            Container(
                                margin: const EdgeInsets.only(top: 10),
                                width: 110,
                                child: FloatingActionButton.extended(
                                    backgroundColor:
                                        const Color.fromARGB(255, 95, 151, 236),
                                    label: const Text(
                                      'Batal',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    onPressed: () async {
                                      nilaiPenerimaan =
                                          TextEditingController(text: "");

                                      Navigator.pop(context);
                                    })),
                          ],
                        ),
                      ],
                    ),
                    height: 500,
                    width: double.infinity,
                  ),

                  //
                ],
              );

              //   return Text(teSeach.text);
            },
          ),
        );
      },
    );
  }

  void showDialogWithFieldsPengeluaran() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final DateTime now = DateTime.now();
        final DateFormat formatter = DateFormat('dd-MM-yyyy');
        final String formatted = formatter.format(now);
        // var sekarang = DateTime.parse(DateTime.now().toString());

        tanggalAwal = TextEditingController(text: formatted.toString());

        tanggalAwalPenerimaan =
            TextEditingController(text: formatted.toString());
        final format = DateFormat("dd-MM-yyyy");
        return AlertDialog(
          content: StatefulBuilder(
            // You need this, notice the parameters below:
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                children: [
                  SizedBox(
                    // ignore: sort_child_properties_last
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: const Text(
                            "Pengeluara",
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          child: DateTimeField(
                            validator: (value) {
                              if (value == null) {
                                return 'Please enter a date';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              hintText: "Tanggal",
                              labelText: "Tanggal",
                              // prefixText: _currency,
                            ),
                            format: format,
                            controller: tanggalAwal,
                            onShowPicker: (context, currentValue) {
                              return showDatePicker(
                                  context: context,
                                  firstDate: DateTime(1900),
                                  initialDate: currentValue ?? DateTime.now(),
                                  lastDate: DateTime(2100));
                            },
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          child: const Text(
                            "Keterangan",
                            style: TextStyle(
                                fontSize: 15,
                                color: Color.fromARGB(255, 109, 107, 107)),
                          ),
                        ),
                        Container(
                            //  margin: EdgeInsets.only(top: 10),
                            //  width: 20,
                            child: TextField(
                          style: const TextStyle(color: Color(0xFF000000)),
                          cursorColor: const Color(0xFF9b9b9b),
                          keyboardType: TextInputType.text,
                          controller: keterangan,
                          decoration: const InputDecoration(
                            hintText: "Pengeluaran",
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.normal),
                          ),
                        )),
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          child: const Text(
                            "Nilai",
                            style: TextStyle(
                                fontSize: 15,
                                color: Color.fromARGB(255, 109, 107, 107)),
                          ),
                        ),
                        Container(
                            //  margin: EdgeInsets.only(top: 10),
                            //  width: 20,
                            child: TextField(
                          style: const TextStyle(color: Color(0xFF000000)),
                          cursorColor: const Color(0xFF9b9b9b),
                          keyboardType: TextInputType.number,
                          controller: nilai,
                          decoration: const InputDecoration(
                            hintText: "Nilai",
                            hintStyle: TextStyle(
                                color: Color.fromARGB(255, 20, 18, 18),
                                fontSize: 15,
                                fontWeight: FontWeight.normal),
                          ),
                        )),
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          child: const Text(
                            "Diambil Dari",
                            style: TextStyle(
                                fontSize: 15,
                                color: Color.fromARGB(255, 109, 107, 107)),
                          ),
                        ),
                        Container(
                            //  margin: EdgeInsets.only(top: 10),
                            //  width: 20,
                            child: const TextField(
                          style: TextStyle(color: Color(0xFF000000)),
                          cursorColor: Color(0xFF9b9b9b),
                          keyboardType: TextInputType.number,
                          //controller: nilai,
                          decoration: InputDecoration(
                            hintText: "Kas",
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.normal),
                          ),
                        )),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                margin: const EdgeInsets.only(top: 10),
                                width: 110,
                                child: FloatingActionButton.extended(
                                  backgroundColor:
                                      const Color.fromARGB(255, 95, 151, 236),
                                  label: const Text(
                                    'Simpa',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  onPressed: () async {
                                    final DateFormat formatter2 =
                                        DateFormat('yyyy-MM-dd HH:mm:ss');
                                    final String tanggalan =
                                        formatter2.format(now);
                                    var idTrx;
                                    var pembelian = [];

                                    var nilaiParse = int.parse(nilai.text);

                                    if (helper != null) {
                                      helper!.idPembelian().then((courses) {
                                        setState(() {
                                          pembelian = courses;
                                          idTrx = pembelian.first['id'];

                                          //    var status = 1;

                                          PengeluaranModel course =
                                              PengeluaranModel({
                                            'nilai': nilaiParse,
                                            'keterangan': keterangan.text,
                                            'created_at': tanggalan,
                                          });
                                          helper!.createPengeluaran(course);
                                        });
                                      });
                                    }
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const Home(
                                                title: "",
                                              )),
                                    );
                                    mysqlCreatePengeluaran(
                                        nilaiParse, keterangan.text);
                                  },
                                )),
                            Container(
                                margin: const EdgeInsets.only(top: 10),
                                width: 110,
                                child: FloatingActionButton.extended(
                                    backgroundColor:
                                        const Color.fromARGB(255, 95, 151, 236),
                                    label: const Text(
                                      'Batal',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    onPressed: () async {
                                      nilai = TextEditingController(text: "");

                                      Navigator.pop(context);
                                    })),
                          ],
                        ),
                      ],
                    ),
                    height: 500,
                    width: double.infinity,
                  ),

                  //
                ],
              );

              //   return Text(teSeach.text);
            },
          ),
        );
      },
    );
  }

  void mysqlCreatePengeluaran(nilai, keterangan) async {
    Map data = {
      'nilai': nilai,
      'keterangan': keterangan,
    };

    String url;

    url = 'createPengeluaran';

    // final response = await htpp.post(Uri.parse(url), body: data);
    final response = await Network().getData_post(data, url);
    // var c = json.decode(response.body);

    if (response.statusCode == 200) {
      print('sukses');
    } else {
      print(response.body);
      throw Exception('Failed to load album');
    }
  }

  void mysqlCreatePenerimaan(nilai, keterangan) async {
    Map data = {
      'nilai': nilai,
      'keterangan': keterangan,
    };

    String url;

    url = 'createPenerimaan';

    // final response = await htpp.post(Uri.parse(url), body: data);
    final response = await Network().getData_post(data, url);
    // var c = json.decode(response.body);

    if (response.statusCode == 200) {
      print('sukses');
    } else {
      print(response.body);
      throw Exception('Failed to load album');
    }
  }

  @override
  void dispose() {
    tanggalAwalPenerimaan.dispose();
    keteranganPenerimaan.dispose();
    nilaiPenerimaan.dispose();
    tanggalAwal.dispose();
    keterangan.dispose();
    nilai.dispose();

    super.dispose();
  }
}
