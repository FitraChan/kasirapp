// ignore_for_file: sort_child_properties_last

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:kasirapp/model/transaksiDetailPembelianModel.dart';
import 'package:intl/intl.dart';
import 'package:kasirapp/screen/home.dart';
import 'package:kasirapp/transaksi/penjualan.dart';

import 'package:kasirapp/helpers/dbkasir.dart';

import '../screen/menu1.dart';

//import 'package:dio/dio.dart';

class DetailPembelian extends StatefulWidget {
  const DetailPembelian({Key? key, required this.idTrans}) : super(key: key);
  final int idTrans;

  @override
  _DetailPembelianState createState() => _DetailPembelianState();
}

class _DetailPembelianState extends State<DetailPembelian> {
  String? email;
  //String? nim;
  String? notificationText;
  String? kewajiban;
  String? bayar;
  String? tunggakan;
  String? _dropdownError;
  String? _mySelection;
  var Katitems = [];
  var allKategori = [];

  var allDetailTrans = [];
  var DetailTrans = [];
  KasirHelper? helper;

  List names = [];
  var items = [];
  List filteredNames = [];
  var allProduk = [];
  var allPembayaran = [];
  var pembayaran = [];
  var count;
  var countDisc;
  var status;

  var sudahDibayar = [];

  bool _isLoading = false;
  String? kode;
  final oCcy = NumberFormat.decimalPattern();

  bool loadData = true;

  int initValue = 1;
  List data = [];
  var hasilDiskon;
  var hasPay;
  var cashBack;
  @override
  void initState() {
    helper = KasirHelper();

    // refreshJumlahPembelian();

    if (helper != null) {
      helper!.selectDetailTransaksiPembelian(widget.idTrans).then((courses) {
        setState(() {
          allDetailTrans = courses;
          DetailTrans = allDetailTrans;
          if (DetailTrans.isNotEmpty) {
            countDisc = DetailTrans.first['diskon'];
            status = DetailTrans.first['status'];
          }
          //_isLoading = false;
        });
      });
    }

    if (helper != null) {
      helper!.totPembelian(widget.idTrans).then((course) {
        setState(() {
          allPembayaran = course;
          pembayaran = allPembayaran;
          count = pembayaran.first['harga'];

          //appendValue(count.toString());

          //_isLoading = false;
        });
      });
    }

    if (helper != null) {
      helper!.pembayaran(widget.idTrans).then((course) {
        setState(() {
          sudahDibayar = course;
          hasPay = sudahDibayar.first['dibayar'];
          cashBack = sudahDibayar.first['kembalian'];
        });
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //  print(diskon.text);countcountcountcount
    String tot;
    if (count != null) {
      tot = oCcy.format(count ?? "");
    } else {
      tot = "";
    }

    // var totMinOrPlus;

    // if (status == 3) {
    //   totMinOrPlus = "-" + tot;
    // } else {
    //   totMinOrPlus = tot;
    // }

    String cB;

    if (cashBack != 0 || cashBack != null) {
      cB = oCcy.format(cashBack ?? "");
    } else {
      cB = "";
    }

    return WillPopScope(
        onWillPop: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Penjualan(
                      tanggal: "",
                    )),
          );
          return Future.value(true);
        },
        child: Scaffold(
          appBar: AppBar(
            //Menambahkan TitleBar
            title: const Text('Penjualan Baru'),
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
                onPressed: () {
                  _refreshProduk();
                },
              ),
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
          drawer: const Menu(),
          backgroundColor: Colors.grey[300],
          body: SingleChildScrollView(
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    header(),
                    content(),

                    // coba(),
                    //_dataProduk(),
                  ],
                )
              ],
            ),
          ),
          bottomNavigationBar: Container(
              height: 130,
              child: Column(
                children: [
                  Container(
                    // padding: EdgeInsets.only(bottom: 10),
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(
                          color: Colors.black26,
                          indent: 11,
                          endIndent: 11,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(left: 8),
                              child: const Text("Total",
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold)),
                            ),

                            //  oCcy.format(int.parse(
                            //             course.hargaBarang.toString())),
                            Container(
                              padding: const EdgeInsets.only(right: 8),
                              // ignore: prefer_interpolation_to_compose_strings
                              child: Text("IDR " + tot,
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        )
                      ],
                    ),

                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                    ),
                    height: 50,
                  ),
                  Container(
                    //margin: EdgeInsets.only(top: 2),
                    child: Container(
                      margin: const EdgeInsets.only(left: 10, top: 5),
                      child: const Text("Informasi Pembayaran",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          )),
                    ),
                    width: double.infinity,
                    height: 30,
                    decoration: const BoxDecoration(color: Colors.red),
                  ),
                  Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 10, top: 4),
                        child: const Text("Jumlah Dibayar",
                            style: TextStyle(
                              fontSize: 13,
                              //color: Colors.white,
                            )),
                      ),
                      const Spacer(),
                      Container(
                        margin:
                            const EdgeInsets.only(left: 10, top: 4, right: 10),
                        child: Text(oCcy.format(int.parse(hasPay.toString())),
                            style: const TextStyle(
                              fontSize: 13,
                              //color: Colors.white,
                            )),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 10, top: 4),
                        child: const Text("Kembalian",
                            style: TextStyle(
                              fontSize: 13,
                              //color: Colors.white,
                            )),
                      ),
                      const Spacer(),
                      Container(
                        margin:
                            const EdgeInsets.only(left: 10, top: 4, right: 10),
                        child: Text(cB.toString(),
                            style: const TextStyle(
                              fontSize: 13,
                              //color: Colors.white,
                            )),
                      ),
                    ],
                  )
                ],
              ),
              decoration: const BoxDecoration()),
        ));
  }

  var fillDisc;

  TransaksiDetailPembelianModel? course;
  Container content() {
    return Container(
      child: ListView.builder(
        itemCount: DetailTrans.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          // course = TransaksiDetailPembelianModel.fromMap(DetailTrans[index]);

          Container nilaiDiskon;

          if (DetailTrans[index]['diskon'] != 0) {
            fillDisc = Container(
              padding: const EdgeInsets.only(top: 8, left: 9),
              child: const Text("Diskon", style: TextStyle(fontSize: 13)),
            );

            nilaiDiskon = Container(
              padding: const EdgeInsets.only(top: 26, left: 9),
              child: Text("- ${DetailTrans[index]['diskon']}",
                  style: const TextStyle(fontSize: 13)),
            );
          } else {
            fillDisc = Container(
              padding: const EdgeInsets.only(top: 8, left: 9),
              child: const Text(""),
            );

            nilaiDiskon = Container(
              padding: const EdgeInsets.only(top: 8, left: 9),
              child: const Text(""),
            );
          }
          // }

          return GestureDetector(
            onTap: () {
              // Navigator.push(
              //     context,
              //     new MaterialPageRoute(
              //         builder: (context) => EditProduk(
              //               produkModel: course,
              //             )));
            },
            child: Container(
              child: Material(
                elevation: 4.0,
                borderRadius: BorderRadius.circular(5.0),
                color: index % 2 == 0
                    ? Colors.white
                    : const Color.fromARGB(255, 226, 232, 230),
                child: Center(
                  child: Row(
                    //    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(top: 9, left: 9),
                            child: Text(DetailTrans[index]['kode'].toString(),
                                style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold)),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 8, left: 9),
                            child: Text(
                                DetailTrans[index]['nama_barang'].toString(),
                                style: const TextStyle(fontSize: 13)),
                          ),
                          fillDisc,
                        ],
                      ),
                      const Spacer(),
                      Container(
                          padding: const EdgeInsets.only(top: 15, right: 10),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    child: Text(
                                        "${DetailTrans[index]['qty']} x ${oCcy.format(int.parse(DetailTrans[index]['harga_jual'].toString()))}",
                                        style: const TextStyle(fontSize: 13)),
                                  )
                                ],
                              ),
                              nilaiDiskon,
                            ],
                          )),
                    ],
                  ),
                ),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                // color: Colors.white,
              ),
              height: 80,
              width: double.infinity,
            ),
          );
        },
      ),
    );
  }

  Container header() {
    var current = DateTime.parse(DateTime.now().toString());

    var currentDate = DateFormat('dd-MM-yyyy').format(current);
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.only(left: 9),
                child: Text(currentDate,
                    style: const TextStyle(
                        color: Colors.white,
                        //  fontWeight: FontWeight.bold,
                        fontSize: 25)),
              ),
              Container(),
            ],
          ),
        ],
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue,
                Color.fromARGB(255, 12, 103, 177),
              ],
              stops: [
                0.4,
                0.9
              ])
          //Color.fromARGB(1, 41, 87, 129),
          ),
      height: 50,
      width: double.infinity,
    );
  }

  void _refreshDetailPembelian() async {
    if (helper != null) {
      helper!.showPembelian().then((product) {
        setState(() {
          allDetailTrans = product;
          DetailTrans = allDetailTrans;
          //_isLoading = false;
        });
      });
    }
  }

  void _refreshProduk() async {
    if (helper != null) {
      helper!.allProduk().then((product) {
        setState(() {
          allProduk = product;
          items = allProduk;
          _isLoading = false;
        });
      });
    }
  }
}
