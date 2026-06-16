import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kasirapp/model/currencyFormatter.dart';
import 'package:kasirapp/model/rupiahCurrency.dart';

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

class PembayaranPesanDidepan extends StatefulWidget {
  PembayaranPesanDidepan(
      {Key? key,
      required this.tanggal,
      required this.idTransaksi,
      required this.pembayaran})
      : super(key: key);

  String tanggal;

  int idTransaksi;

  int pembayaran;

  @override
  _PembayaranPesanDidepanState createState() => _PembayaranPesanDidepanState();
}

class _PembayaranPesanDidepanState extends State<PembayaranPesanDidepan> {
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

  late int valueA;
  late int valueB;
  var sbValue = StringBuffer();
  String? operator;
  KasirHelper? helper;
  var allPembayaran = [];
  var pembayaran = [];
  var count;
  var allDetailTrans = [];
  var DetailTrans = [];
  List Trans = [];

  List allTrans = [];
  List detailTrans = [];
  var namaBarang;
  var qty;
  var hargaBarang;

  var countDisc;

  TextEditingController showKalkulator = TextEditingController();
  TextEditingController kembalian = TextEditingController();
  bool value = true;

  var current;
  var currentString;

  //List Trans = [];
  int? idTrx = 0;
  List<List> AllData = [];

  List<List> all = [];
  var selectDetailPembelian = [];

  List allDetailTransaksi = [];
  int _roundedNumber = 0;
  int _roundedNumber2 = 0;
  int _roundedNumber3 = 0;
  int _roundedNumber4 = 0;
  int _roundedNumber5 = 0;
  int _roundedNumber6 = 0;

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
      helper!
          .hitungPembelianPemesananDidepan(widget.idTransaksi)
          .then((course) {
        setState(() {
          allPembayaran = course;
          pembayaran = allPembayaran;
          count = pembayaran.first['harga'];
          _roundNumber(count);

          appendValue(count.toString());

          //_isLoading = false;
        });
      });
    }

    if (helper != null) {
      helper!.showPembelianPemesananDidepan(widget.idTransaksi).then((courses) {
        setState(() {
          allDetailTrans = courses;
          DetailTrans = allDetailTrans;
          countDisc = DetailTrans.first['diskon'];
          // namaBarang = DetailTrans.first['nama_barang'];
          // qty = DetailTrans.first['qty'];
          // hargaBarang = DetailTrans.first['harga_barang'];
        });
      });
    }

    if (helper != null) {
      helper!
          .showPembelianAndTopingPrintFront(widget.idTransaksi)
          .then((courses) {
        setState(() {
          allTrans = courses;
          Trans = allTrans;
          // var id = Trans.first['id'];
        });

        for (var x = 0; x < Trans.length; x++) {
          idTrx = 0;
          idTrx = Trans[x]['id_sub_transaksi'];

          // detailToping(idTrx);

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
                    tanggal: "", delivery: "1", idPembayaran: 0)),
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
        //hasil = typeCall - count;
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
    };

    String url;

    url = 'save_pembayaran_didepan';

    // final response = await htpp.post(Uri.parse(url), body: data);
    final response = await Network().getData_post(data, url);
    // var c = json.decode(response.body);

    await helper!.sync(idTrx, 'id', 'tb_transaksi_pembelian');
    await helper!.sync(idTrx, 'id_transaksi', 'tb_detail_transaksi_pembelian');

    if (response.statusCode == 200) {
      print('sukses');
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
    //sbValue = count;

    var typeCall = int.parse(sbValue.toString());

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

                // MediaQuery.of(context).orientation ==
                //                     Orientation.landscape
                //                 ?
                Column(
                  children: [
                    Container(
                        margin: const EdgeInsets.all(10),
                        child: ElevatedButton(
                          onPressed: () {
                            clearValue();
                            appendValue(_roundedNumber.toString());
                          },
                          child: Text(oCcy.format(_roundedNumber)),
                        )),
                    Container(
                        margin: const EdgeInsets.all(10),
                        child: ElevatedButton(
                          onPressed: () {
                            clearValue();
                            appendValue(_roundedNumber2.toString());
                          },
                          child: Text(oCcy.format(_roundedNumber2)),
                        )),
                    Container(
                        margin: const EdgeInsets.all(10),
                        child: ElevatedButton(
                          onPressed: () {
                            clearValue();
                            appendValue(_roundedNumber3.toString());
                          },
                          child: Text(oCcy.format(_roundedNumber3)),
                        )),
                  ],
                ),

                Column(children: [
                  Container(
                      margin: const EdgeInsets.all(10),
                      child: ElevatedButton(
                        onPressed: () {
                          clearValue();
                          appendValue(_roundedNumber4.toString());
                        },
                        child: Text(oCcy.format(_roundedNumber4)),
                      )),
                  Container(
                      margin: const EdgeInsets.all(10),
                      child: ElevatedButton(
                        onPressed: () {
                          clearValue();
                          appendValue(_roundedNumber5.toString());
                        },
                        child: Text(oCcy.format(_roundedNumber5)),
                      )),
                ])
              ],
            ),
            Container(
              color: const Color.fromARGB(255, 2, 101, 182),
              width: double.infinity,
              height: 70,

              child: Container(
                margin: const EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: () {
                    var dates = DateTime.parse(currentString);

                    var formattedDate =
                        DateFormat('yyyy-MM-dd HH:mm:ss').format(dates);

                    var allTotal = int.parse(count.toString());
                    String showKalkulatorFormat =
                        removeCurrencyFormat(showKalkulator.text);
                    String kembalianFormat =
                        removeCurrencyFormat(kembalian.text);
                    var dibayar = int.parse(showKalkulatorFormat);
                    var cashBack = int.parse(kembalianFormat);
                    // TransaksiPembelianModel beli = TransaksiPembelianModel({
                    //   'total': allTotal,
                    //   'id_pembeli': idUser,
                    //   'keterangan': '',
                    //   'created_at': formattedDate,
                    // });

                    // helper!.createTransaksiPembelian(beli);

                    var selectDetailPembelian = [];
                    var selectSubDetailPembelian = [];

                    if (helper != null) {
                      //  helper!.idPembelian().then((courses) {
                      setState(() {
                        //allDetailTrans = courses;

                        //_isLoading = false;

                        PembayaranModel bayar = PembayaranModel({
                          'total': allTotal,
                          'id_transaksi': widget.idTransaksi,
                          'created_at': formattedDate,
                          'dibayar': dibayar,
                          'kembalian': cashBack,
                        });

                        helper!.createPembayaran(bayar);

                        helper!.updateDetailTransaksiPembelianPembayaranDidepan(
                            widget.idTransaksi, widget.pembayaran);

                        helper!
                            .selectDetailTransaksiPembelian(widget.idTransaksi)
                            .then((cou) {
                          selectDetailPembelian = cou;

                          // var panj = selectDetailPembelian.length;

                          for (var a = 0;
                              a < selectDetailPembelian.length;
                              a++) {
                            // print(selectDetailPembelian[a]['harga']);

                            var idBar = selectDetailPembelian[a]['id_barang'];
                            var stock = selectDetailPembelian[a]['stok'];
                            var jum = selectDetailPembelian[a]['qty'];

                            helper!.updateStok(
                                idBar, stock, jum, widget.idTransaksi);
                          }
                          //allDetailTrans = courses;
                        });

                        helper!
                            .selectSubDetailTransaksiPembelian(
                                widget.idTransaksi)
                            .then((cou) {
                          selectSubDetailPembelian = cou;

                          for (var a = 0;
                              a < selectSubDetailPembelian.length;
                              a++) {
                            // print(selectDetailPembelian[a]['harga']);

                            var idBar =
                                selectSubDetailPembelian[a]['id_barang'];
                            var stock = selectSubDetailPembelian[a]['stok'];
                            var jum = selectSubDetailPembelian[a]['qty'];

                            helper!.updateStok(
                                idBar, stock, jum, widget.idTransaksi);
                          }
                        });
                      });

                      mysqlCreatePembayaran(
                          allTotal,
                          widget.idTransaksi,
                          dibayar,
                          cashBack,
                          idUser,
                          formattedDate,
                          widget.pembayaran);

                      if (value == true) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PrintingWidget(
                              idTrans: widget.idTransaksi,
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
                      //   });
                    }
                  },
                  child: const Text("Konfirmasi"),
                ),
              ),
              //child: ,
            ),
            Expanded(
              key: const Key("expanded_bagian_bawah"),
              flex: 1,
              child: Column(
                key: const Key("expanded_column_bagian_bawah"),
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            // color: _buttonColorWhite,
                            // highlightColor: _buttonHighlightColor,
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.red,
                                backgroundColor: _buttonColorWhite),
                            child: Text(
                              "C",
                              style: TextStyle(
                                  color: _primarySwatchColor,
                                  fontSize: _buttonFontSize),
                            ),
                            onPressed: () {
                              // TODO: do something in here

                              clearValue();
                            },
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            // color: _buttonColorWhite,
                            // highlightColor: _buttonHighlightColor,
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.red,
                                backgroundColor: _buttonColorWhite),
                            child: Icon(
                              Icons.backspace,
                              color: _buttonColorGrey,
                            ),
                            onPressed: () {
                              // TODO: do something in here

                              deleteValue();
                            },
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            // color: _buttonColorWhite,
                            // highlightColor: _buttonHighlightColor,
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.red,
                                backgroundColor: _buttonColorWhite),
                            child: Text(
                              "00",
                              style: TextStyle(
                                color: _buttonColorGrey,
                                fontSize: _buttonFontSize,
                              ),
                            ),
                            onPressed: () {
                              // TODO: do something in here
                              appendValue("00");
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            // color: _buttonColorWhite,
                            // highlightColor: _buttonHighlightColor,
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.red,
                                backgroundColor: _buttonColorWhite),
                            child: Text(
                              "7",
                              style: TextStyle(
                                color: _buttonColorGrey,
                                fontSize: _buttonFontSize,
                              ),
                            ),
                            onPressed: () {
                              // TODO: do something in here
                              appendValue("7");
                            },
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            // color: _buttonColorWhite,
                            // highlightColor: _buttonHighlightColor,
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.red,
                                backgroundColor: _buttonColorWhite),
                            child: Text(
                              "8",
                              style: TextStyle(
                                color: _buttonColorGrey,
                                fontSize: _buttonFontSize,
                              ),
                            ),
                            onPressed: () {
                              // TODO: do something in here

                              appendValue("8");
                            },
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            // color: _buttonColorWhite,
                            // highlightColor: _buttonHighlightColor,
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.red,
                                backgroundColor: _buttonColorWhite),
                            child: Text(
                              "9",
                              style: TextStyle(
                                color: _buttonColorGrey,
                                fontSize: _buttonFontSize,
                              ),
                            ),
                            onPressed: () {
                              // TODO: do something in here
                              appendValue("9");
                            },
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            // color: _buttonColorWhite,
                            // highlightColor: _buttonHighlightColor,
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.red,
                                backgroundColor: _buttonColorWhite),
                            child: Text(
                              "000",
                              style: TextStyle(
                                color: _buttonColorGrey,
                                fontSize: _buttonFontSize,
                              ),
                            ),
                            onPressed: () {
                              // TODO: do something in here
                              appendValue("000");
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            // color: _buttonColorWhite,
                            // highlightColor: _buttonHighlightColor,
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.red,
                                backgroundColor: _buttonColorWhite),
                            child: Text(
                              "4",
                              style: TextStyle(
                                color: _buttonColorGrey,
                                fontSize: _buttonFontSize,
                              ),
                            ),
                            onPressed: () {
                              // TODO: do something in here

                              appendValue("4");
                            },
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            // color: _buttonColorWhite,
                            // highlightColor: _buttonHighlightColor,
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.red,
                                backgroundColor: _buttonColorWhite),
                            child: Text(
                              "5",
                              style: TextStyle(
                                color: _buttonColorGrey,
                                fontSize: _buttonFontSize,
                              ),
                            ),
                            onPressed: () {
                              // TODO: do something in here
                              appendValue("5");
                            },
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            // color: _buttonColorWhite,
                            // highlightColor: _buttonHighlightColor,
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.red,
                                backgroundColor: _buttonColorWhite),
                            child: Text(
                              "6",
                              style: TextStyle(
                                color: _buttonColorGrey,
                                fontSize: _buttonFontSize,
                              ),
                            ),
                            onPressed: () {
                              // TODO: do something in here

                              appendValue("6");
                            },
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            // color: _buttonColorWhite,
                            // highlightColor: _buttonHighlightColor,
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.red,
                                backgroundColor: _buttonColorWhite),
                            child: Text(
                              ".",
                              style: TextStyle(
                                color: _buttonColorGrey,
                                fontSize: _buttonFontSize,
                              ),
                            ),
                            onPressed: () {
                              // TODO: do something in here
                              appendValue(".");
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            // color: _buttonColorWhite,
                            // highlightColor: _buttonHighlightColor,
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.red,
                                backgroundColor: _buttonColorWhite),
                            child: Text(
                              "1",
                              style: TextStyle(
                                color: _buttonColorGrey,
                                fontSize: _buttonFontSize,
                              ),
                            ),
                            onPressed: () {
                              // TODO: do something in here
                              appendValue("1");
                            },
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            // color: _buttonColorWhite,
                            // highlightColor: _buttonHighlightColor,
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.red,
                                backgroundColor: _buttonColorWhite),
                            child: Text(
                              "2",
                              style: TextStyle(
                                color: _buttonColorGrey,
                                fontSize: _buttonFontSize,
                              ),
                            ),
                            onPressed: () {
                              // TODO: do something in here

                              appendValue("2");
                            },
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            // color: _buttonColorWhite,
                            // highlightColor: _buttonHighlightColor,
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.red,
                                backgroundColor: _buttonColorWhite),
                            child: Text(
                              "3",
                              style: TextStyle(
                                color: _buttonColorGrey,
                                fontSize: _buttonFontSize,
                              ),
                            ),
                            onPressed: () {
                              // TODO: do something in here

                              appendValue("3");
                            },
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            // color: _buttonColorWhite,
                            // highlightColor: _buttonHighlightColor,
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.red,
                                backgroundColor: _buttonColorWhite),
                            child: Text(
                              "+",
                              style: TextStyle(
                                color: _buttonColorGrey,
                                fontSize: _buttonFontSize,
                              ),
                            ),
                            onPressed: () {
                              // TODO: do something in here
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Expanded(
                          flex: 3,
                          child: ElevatedButton(
                            // color: _buttonColorWhite,
                            // highlightColor: _buttonHighlightColor,
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.red,
                                backgroundColor: _buttonColorWhite),
                            child: Text(
                              "0",
                              style: TextStyle(
                                color: _buttonColorGrey,
                                fontSize: _buttonFontSize,
                              ),
                            ),
                            onPressed: () {
                              // TODO: do something in here
                              appendValue("0");
                            },
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            // color: _buttonColorWhite,
                            // highlightColor: _buttonHighlightColor,
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.red,
                                backgroundColor: _buttonColorWhite),
                            child: Text(
                              "=",
                              style: TextStyle(
                                color: _textColorWhite,
                                fontSize: _buttonFontSize,
                              ),
                            ),
                            onPressed: () {
                              // TODO: do something in here
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ));
  }

  @override
  void dispose() {
    kembalian.dispose();
    showKalkulator.dispose();

    //priceAfterDiscount.dispose();
    super.dispose();
  }
}
