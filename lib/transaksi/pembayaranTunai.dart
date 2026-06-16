import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kasirapp/model/currencyFormatter.dart';
import 'package:kasirapp/model/rupiahCurrency.dart';

import 'package:kasirapp/model/transaksiPembelianModel.dart';
import 'package:kasirapp/model/pembayaranModel.dart';
import 'package:kasirapp/network_utils/api.dart';
import 'package:kasirapp/screen/home.dart';
import 'package:kasirapp/screen/login.dart';
import 'package:kasirapp/screen/menu2.dart';

import 'package:kasirapp/transaksi/transPenjualan.dart';
import 'package:kasirapp/transaksi/printing_widget.dart';

// import 'package:kasirapp/transaksi/pdfPreviewPage.dart';
import 'package:intl/intl.dart';
import 'package:kasirapp/helpers/dbkasir.dart';

import '../screen/menu1.dart';

//import 'package:firebase_messaging/firebase_messaging.dart';

class PembayaranTunai extends StatefulWidget {
  PembayaranTunai(
      {Key? key,
      required this.tanggal,
      required this.delivery,
      required this.idPelanggan,
      required this.kodeTransaksi})
      : super(key: key);

  String tanggal;
  String delivery;
  int idPelanggan;
  String kodeTransaksi;

  @override
  _PembayaranTunaiState createState() => _PembayaranTunaiState();
}

class _PembayaranTunaiState extends State<PembayaranTunai> {
  //  FirebaseMessaging messaging;
  final double _padding = 16.0;
  final double _buttonFontSize = 24.0;

  final Color _primarySwatchColor = Colors.orange;
  final Color _titleAppBarColor = Colors.white;
  final Color _buttonColorWhite = Colors.white;
  final Color _buttonHighlightColor = Colors.grey;
  final Color _buttonColorGrey = Colors.grey;
  final Color _textColorWhite = Colors.white;
  TextEditingController teSeach = TextEditingController();
  final oCcy = NumberFormat.decimalPattern();
  int _roundedNumber = 0;
  int _roundedNumber2 = 0;
  int _roundedNumber3 = 0;
  int _roundedNumber4 = 0;
  int _roundedNumber5 = 0;
  int _roundedNumber6 = 0;

  late int valueA;
  late int valueB;
  var sbValue = StringBuffer();
  String? operator;
  KasirHelper? helper;
  var allPembayaran = [];
  var pembayaran = [];
  var count;
  var allCount;
  var allDetailTrans = [];
  var DetailTrans = [];
  var namaBarang;
  var qty;
  var hargaBarang;

  var countDisc;

  var allSubPembayaran = [];
  var subPembayaran = [];
  var subCount;
  var totalAllCount;

  TextEditingController showKalkulator = TextEditingController();
  TextEditingController kembalian = TextEditingController();
  bool value = true;

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

  @override
  void initState() {
    // _loadUserData();
    current = DateTime.parse(DateTime.now().toString());

    currentString = DateFormat('yyyy-MM-dd HH:mm:ss').format(current);
    sbValue.write("0");
    operator = "";

    helper = KasirHelper();
    //   _hitung();
    if (helper != null) {
      helper!.hitungPembelian().then((course) {
        setState(() {
          allPembayaran = course;
          pembayaran = allPembayaran;
          count = pembayaran.first['total'] ?? 0;
          _roundNumber(count);
          appendValue(count.toString());

          //_isLoading = false;
        });
      });

      helper!.hitungSubPembelian().then((course) {
        setState(() {
          allSubPembayaran = course;
          subPembayaran = allSubPembayaran;
          subCount = subPembayaran.first['total'] ?? 0;

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
          countDisc = DetailTrans.first['diskon'];
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

    super.initState();
  }

  var bayar1;
  var bayar2;
  var bayar3;
  var bayar4;

  Container daftarBayar() {
    bayar1 = (count / 5).round() * 5;
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: ElevatedButton(onPressed: () {}, child: Text(bayar1)),
          )
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    var tgl = widget.tanggal;
    return WillPopScope(
        onWillPop: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const TransPenjualan(
                      tanggal: "",
                      delivery: "1",
                      idPembayaran: 0,
                    )),
          );
          return Future.value(true);
        },
        child: Scaffold(
            appBar: AppBar(
              //Menambahkan TitleBar
              title: Text('Belajar Flutter $tgl'),
              //Mengubah Warna Background
              backgroundColor: Colors.red[900],
              //Menambahkan Leading menu
              leading: IconButton(
                icon: const Icon(Icons.home, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Home(
                              title: '',
                            )),
                  );
                },
              ),
              //Menambahkan Beberapa Action Button
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
            drawer: level == '1' ? const Menu() : const Menu2(),
            backgroundColor: Colors.grey[300],
            body: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [kalkulator()]
                    // students(),
                    ))));
  }

  void appendValue(String str) => setState(() {
        //  var typeCall = int.parse(showKalkulator.text);

        if (sbValue.toString() == "0" && str != "0") {
          sbValue.clear();
        }
        sbValue.write(str);
        var lib = [];

        lib.add(str);
        // lib[int.parse(showKalkulator.text)];
        //  print(showKalkulator.text);
      });

  void clearValue() => setState(() {
        operator = "";
        sbValue.clear();
        sbValue.write("0");
      });

  void deleteValue() => setState(() {
        String strValue = sbValue.toString();
        if (strValue.isNotEmpty) {
          strValue = strValue.substring(0, strValue.length - 1);
          sbValue.clear();
          sbValue.write(strValue.isEmpty ? "0" : strValue);
        }
      });

  var hasil;

  void mysqlCreatePembayaran(
      total, idTrx, dibayar, kembali, idUser, createdAt, statusBayar) async {
    Map data = {
      'total': total,
      'id_transaksi': idTrx,
      'dibayar': dibayar,
      'kembalian': kembali,
      'id_pembeli': idUser,
      'status_bayar': statusBayar,
      'created_at': createdAt,
      'kode_transaksi': widget.kodeTransaksi
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
    } else {
      print(response.body);
      throw Exception('Failed to load album');
    }
  }

  final currencyFormatter = CurrencyFormatter();

  String removeCurrencyFormat(String formattedValue) {
    // Hapus semua karakter yang bukan angka
    String cleanValue = formattedValue.replaceAll(RegExp(r'[^\d]'), '');

    String resultString = cleanValue.substring(0, cleanValue.length - 2);

    return resultString;
  }

  int roundToNearest5000(int number) {
    if (number % 5000 == 0) {
      return number;
    } else {
      return ((number / 5000).ceil()) * 5000;
    }
  }

  void _roundNumber(harga) {
    final int inputNumber = harga;

    final int inputNumber2 = roundToNearest5000(inputNumber) + 5000;
    final int inputNumber3 = roundToNearest5000(inputNumber) + 10000;
    final int inputNumber4 = roundToNearest5000(inputNumber) + 15000;
    int inputNumber5 = 0;
    if (harga <= 50000) {
      inputNumber5 = 50000;
    } else if (harga >= 50000 && harga <= 100000) {
      inputNumber5 = 100000;
    } else if (harga >= 100000 && harga <= 150000) {
      inputNumber5 = 150000;
    } else if (harga >= 150000 && harga <= 200000) {
      inputNumber5 = 200000;
    } else if (harga >= 200000 && harga <= 250000) {
      inputNumber5 = 250000;
    } else if (harga >= 250000 && harga <= 300000) {
      inputNumber5 = 300000;
    } else if (harga >= 300000 && harga <= 350000) {
      inputNumber5 = 350000;
    } else if (harga >= 350000 && harga <= 400000) {
      inputNumber5 = 400000;
    } else if (harga >= 400000 && harga <= 450000) {
      inputNumber5 = 450000;
    } else if (harga >= 450000 && harga <= 500000) {
      inputNumber5 = 500000;
    } else if (harga >= 500000 && harga <= 550000) {
      inputNumber5 = 550000;
    }

    setState(() {
      _roundedNumber = roundToNearest5000(inputNumber);
      _roundedNumber2 = roundToNearest5000(inputNumber2);
      _roundedNumber3 = roundToNearest5000(inputNumber3);
      _roundedNumber4 = roundToNearest5000(inputNumber4);
      _roundedNumber5 = (inputNumber5);
      // _roundedNumber6 = roundToNearest5000(inputNumber6);
    });
  }

  Container kalkulator() {
    var typeCall = int.parse(sbValue.toString());

    //   print(hasil);

    String tot;
    if (count != null) {
      tot = oCcy.format(count ?? "");
      hasil = typeCall - count;
      kembalian = TextEditingController(
          text: currencyFormatter.format(hasil.toString()));
    } else {
      tot = "";
    }
    showKalkulator = TextEditingController(
        text: currencyFormatter.format(sbValue.toString()));
    // var screenHeight = MediaQuery.of(context).size.height;
    return Container(
        width: double.infinity,
        height: 600,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                width: double.infinity,
                height: 40,
                color: Colors.black,
                child: Row(
                  //crossAxisAlignment: CrossAxisAlignment,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      child: const Text("Total",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          )),
                    ),
                    //  Spacer(),
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: Text(tot,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  child: SingleChildScrollView(
                      child: Stack(
                    children: [
                      Column(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 8, left: 8),
                                child: Text("Jumlah Dibayar",
                                    style: TextStyle(color: Colors.blue[900])),
                              ),
                              MediaQuery.of(context).orientation ==
                                      Orientation.landscape
                                  ? Container(
                                      margin: const EdgeInsets.only(
                                          top: 8, left: 8),
                                      width: 260,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: TextField(
                                        style: const TextStyle(
                                            color: Color(0xFF000000)),
                                        cursorColor: const Color(0xFF9b9b9b),
                                        keyboardType: TextInputType.text,
                                        readOnly: true,
                                        controller: showKalkulator,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                          CurrencyInputFormatter(),
                                        ],
                                        textAlign: TextAlign.right,
                                        decoration: InputDecoration(
                                          fillColor: Colors.grey,
                                          hintText: "Jumlah",
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                            borderSide: BorderSide(
                                              color: Colors.blue.shade900,
                                              width: 2.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      margin: const EdgeInsets.only(
                                          top: 8, left: 8),
                                      width: 130,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: TextField(
                                        style: const TextStyle(
                                            color: Color(0xFF000000)),
                                        cursorColor: const Color(0xFF9b9b9b),
                                        keyboardType: TextInputType.text,
                                        readOnly: true,
                                        controller: showKalkulator,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                          CurrencyInputFormatter(),
                                        ],
                                        textAlign: TextAlign.right,
                                        decoration: InputDecoration(
                                          fillColor: Colors.grey,
                                          hintText: "Jumlah",
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                            borderSide: BorderSide(
                                              color: Colors.blue.shade900,
                                              width: 2.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                              Container(
                                margin: const EdgeInsets.only(top: 8, left: 8),
                                child: Text("Kembalian",
                                    style: TextStyle(color: Colors.blue[900])),
                              ),
                              MediaQuery.of(context).orientation ==
                                      Orientation.landscape
                                  ? Container(
                                      margin: const EdgeInsets.only(
                                          top: 8, left: 8),
                                      width: 260,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: TextFormField(
                                        style: const TextStyle(
                                            color: Color(0xFF000000)),
                                        cursorColor: const Color(0xFF9b9b9b),
                                        keyboardType: TextInputType.text,
                                        controller: kembalian,
                                        readOnly: true,
                                        textAlign: TextAlign.right,
                                        decoration: InputDecoration(
                                          fillColor: Colors.grey,
                                          hintText: "Jumlah",
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                            borderSide: BorderSide(
                                              color: Colors.blue.shade900,
                                              width: 2.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      margin: const EdgeInsets.only(
                                          top: 8, left: 8),
                                      width: 130,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: TextFormField(
                                        style: const TextStyle(
                                            color: Color(0xFF000000)),
                                        cursorColor: const Color(0xFF9b9b9b),
                                        keyboardType: TextInputType.text,
                                        controller: kembalian,
                                        readOnly: true,
                                        textAlign: TextAlign.right,
                                        decoration: InputDecoration(
                                          fillColor: Colors.grey,
                                          hintText: "Jumlah",
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                            borderSide: BorderSide(
                                              color: Colors.blue.shade900,
                                              width: 2.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                              Row(
                                children: [
                                  Checkbox(
                                    value: true,
                                    onChanged: (value) {
                                      setState(() {
                                        this.value = value!;
                                      });
                                    },
                                  ),
                                  Text("Cetak Struk",
                                      style: TextStyle(color: Colors.blue[900]))
                                ],
                              )
                            ],
                          ),
                        ],
                      )
                    ],
                  )),
                ),
                SizedBox(
                  width: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // === Baris pertama (3 tombol) ===
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildElegantButton(_roundedNumber),
                        const SizedBox(height: 8),
                        _buildElegantButton(_roundedNumber2),
                        const SizedBox(height: 8),
                        _buildElegantButton(_roundedNumber3),
                      ],
                    ),
                    const SizedBox(width: 10), // jarak antar baris

                    // === Baris kedua (2 tombol) ===
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildElegantButton(_roundedNumber4),
                        const SizedBox(height: 8),
                        _buildElegantButton(_roundedNumber5),
                      ],
                    ),
                  ],
                ),

                // Column(
                //   children: [
                //     Container(
                //         margin: const EdgeInsets.all(10),
                //         child: ElevatedButton(
                //           onPressed: () {
                //             clearValue();
                //             appendValue(_roundedNumber.toString());
                //           },
                //           child: Text(oCcy.format(_roundedNumber)),
                //         )),
                //     Container(
                //         margin: const EdgeInsets.all(10),
                //         child: ElevatedButton(
                //           onPressed: () {
                //             clearValue();
                //             appendValue(_roundedNumber2.toString());
                //           },
                //           child: Text(oCcy.format(_roundedNumber2)),
                //         )),
                //     Container(
                //         margin: const EdgeInsets.all(10),
                //         child: ElevatedButton(
                //           onPressed: () {
                //             clearValue();
                //             appendValue(_roundedNumber3.toString());
                //           },
                //           child: Text(oCcy.format(_roundedNumber3)),
                //         )),
                //   ],
                // ),

                // Column(children: [
                //   Container(
                //       margin: const EdgeInsets.all(10),
                //       child: ElevatedButton(
                //         onPressed: () {
                //           clearValue();
                //           appendValue(_roundedNumber4.toString());
                //         },
                //         child: Text(oCcy.format(_roundedNumber4)),
                //       )),
                //   Container(
                //       margin: const EdgeInsets.all(10),
                //       child: ElevatedButton(
                //         onPressed: () {
                //           clearValue();
                //           appendValue(_roundedNumber5.toString());
                //         },
                //         child: Text(oCcy.format(_roundedNumber5)),
                //       )),
                // ])
              ],
            ),
            Container(
              color: Colors.grey[800],
              width: double.infinity,
              height: 70,

              child: Container(
                margin: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // === Tombol Cash ===
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () {
                        prosesPembayaran(
                            statusBayar: 1, // Cash
                            tot: tot);
                      },
                      child: const Text("Cash",
                          style: TextStyle(color: Colors.white)),
                    ),

                    // === Tombol Non Tunai ===
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      onPressed: () {
                        prosesPembayaran(statusBayar: 2, tot: tot // Non Tunai
                            );
                      },
                      child: const Text("Non Tunai",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ), //child: ,
            ),
            Expanded(
              key: const Key("expanded_bagian_bawah"),
              flex: 1,
              child: Column(
                key: const Key("expanded_column_bagian_bawah"),
                children: [
                  _buildRow([
                    _buildButton("C",
                        color: _primarySwatchColor, onTap: clearValue, flex: 2),
                    _buildIconButton(Icons.backspace,
                        color: _buttonColorGrey, onTap: deleteValue),
                    _buildButton("00",
                        color: _buttonColorGrey,
                        onTap: () => appendValue("00")),
                  ]),
                  _buildRow([
                    _buildButton("7",
                        color: _buttonColorGrey, onTap: () => appendValue("7")),
                    _buildButton("8",
                        color: _buttonColorGrey, onTap: () => appendValue("8")),
                    _buildButton("9",
                        color: _buttonColorGrey, onTap: () => appendValue("9")),
                    _buildButton("000",
                        color: _buttonColorGrey,
                        onTap: () => appendValue("000")),
                  ]),
                  _buildRow([
                    _buildButton("4",
                        color: _buttonColorGrey, onTap: () => appendValue("4")),
                    _buildButton("5",
                        color: _buttonColorGrey, onTap: () => appendValue("5")),
                    _buildButton("6",
                        color: _buttonColorGrey, onTap: () => appendValue("6")),
                    _buildButton(".",
                        color: _buttonColorGrey, onTap: () => appendValue(".")),
                  ]),
                  _buildRow([
                    _buildButton("1",
                        color: _buttonColorGrey, onTap: () => appendValue("1")),
                    _buildButton("2",
                        color: _buttonColorGrey, onTap: () => appendValue("2")),
                    _buildButton("3",
                        color: _buttonColorGrey, onTap: () => appendValue("3")),
                    _buildButton("+", color: _buttonColorGrey, onTap: () {}),
                  ]),
                  _buildRow([
                    _buildButton("0",
                        color: _buttonColorGrey,
                        onTap: () => appendValue("0"),
                        flex: 3),
                    _buildButton("=",
                        color: _textColorWhite,
                        bgColor: Colors.blue,
                        onTap: () {}),
                  ]),
                ],
              ),
            )
          ],
        ));
  }

  void prosesPembayaran({required int statusBayar, required String tot}) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();

    var idTrx;

    var dates = DateTime.parse(currentString);
    var formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(dates);

    var allTotal = int.parse(count.toString());
    String showKalkulatorFormat = removeCurrencyFormat(showKalkulator.text);
    String kembalianFormat = removeCurrencyFormat(kembalian.text);
    var dibayar = int.parse(showKalkulatorFormat);
    var cashBack = int.parse(kembalianFormat);

    // Insert transaksi
    TransaksiPembelianModel beli = TransaksiPembelianModel({
      'total': allTotal,
      'id_pembeli': idUser,
      'status_bayar': statusBayar,
      'keterangan': '',
      'created_at': formattedDate,
      'shift_id': int.parse(localStorage.getString('shift_id') ?? '0'),
      'kode_transaksi': widget.kodeTransaksi
    });

    await helper!.createTransaksiPembelian(beli);

    // Ambil ID transaksi terakhir
    helper!.idPembelian().then((courses) {
      var pembelian = courses;
      var idTrx = pembelian.first['id'];

      PembayaranModel bayar = PembayaranModel({
        'total': allTotal,
        'id_transaksi': idTrx,
        'created_at': formattedDate,
        'dibayar': dibayar,
        'kembalian': cashBack,
      });

      helper!.createPembayaran(bayar);
      helper!.createKomisi(idTrx);

      // Update detail + stok
      helper!.updateDetailTransaksiPembelian(idTrx);

      helper!.selectDetailTransaksiPembelian(idTrx).then((detail) {
        for (var a in detail) {
          helper!.updateStok(a['id_barang'], a['stok'], a['qty'], idTrx);
        }
      });

      // Simpan ke MySQL
      mysqlCreatePembayaran(allTotal, idTrx, dibayar, cashBack, idUser,
          formattedDate, statusBayar);

      localStorage.remove('kode_transaksi');

      if (value == true) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PrintingWidget(
              idTrans: idTrx,
              detailTransaksi: Trans,
              all: all,
              tot: tot,
              kembalian: kembalian.text,
              dibayar: showKalkulator.text,
              nama: name,
            ),
          ),
        );
      }
    });
  }

  /// helper row
  Widget _buildRow(List<Widget> children) {
    return Expanded(
      flex: 1,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  /// helper button text
  Widget _buildButton(
    String text, {
    required Color color,
    required VoidCallback onTap,
    int flex = 1,
    Color? bgColor,
  }) {
    return Expanded(
      flex: flex,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor ?? _buttonColorWhite,
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: _buttonFontSize,
          ),
        ),
      ),
    );
  }

  /// helper button icon
  Widget _buildIconButton(
    IconData icon, {
    required Color color,
    required VoidCallback onTap,
    int flex = 1,
  }) {
    return Expanded(
      flex: flex,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _buttonColorWhite,
        ),
        onPressed: onTap,
        child: Icon(icon, color: color),
      ),
    );
  }

  Widget _buildElegantButton(int value) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue[800],
        padding: const EdgeInsets.symmetric(
          horizontal: 20, // sebelumnya 28
          vertical: 14, // sebelumnya 18
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // agak kecil biar compact
          side: BorderSide(color: Colors.blue.shade100),
        ),
        elevation: 2,
        minimumSize: const Size(80, 48), // ukuran minimum tombol
      ),
      onPressed: () {
        clearValue();
        appendValue(value.toString());
      },
      child: Text(
        oCcy.format(value),
        style: const TextStyle(
          fontSize: 16, // lebih kecil dari 18
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  void dispose() {
    kembalian.dispose();
    showKalkulator.dispose();

    //priceAfterDiscount.dispose();
    super.dispose();
  }
}
