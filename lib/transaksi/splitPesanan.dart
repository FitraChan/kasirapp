import 'dart:async';
import 'dart:convert';

import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kasirapp/model/currencyFormatter.dart';

import 'package:kasirapp/model/produkModel.dart';
import 'package:kasirapp/model/subTransaksiDetailPembelianModel.dart';
import 'package:kasirapp/model/transaksiDetailPembelianModel.dart';
import 'package:intl/intl.dart';
import 'package:kasirapp/network_utils/api.dart';
import 'package:kasirapp/screen/home.dart';
import 'package:kasirapp/screen/login.dart';
import 'package:kasirapp/screen/menu2.dart';
import 'package:kasirapp/transaksi/penjualan.dart';

import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:kasirapp/transaksi/transPenjualan.dart';

import '../screen/menu1.dart';

//import 'package:dio/dio.dart';

class SplitPesanan extends StatefulWidget {
  const SplitPesanan({Key? key, required this.idTrans}) : super(key: key);

  final int idTrans;

  @override
  _SplitPesananState createState() => _SplitPesananState();
}

class _SplitPesananState extends State<SplitPesanan> {
  final TextEditingController _filter = TextEditingController();

  String? email;
  //String? nim;
  String? notificationText;
  String? kewajiban;
  String? bayar;
  String? tunggakan;
  String? _dropdownError;
  String? _mySelection;
  var Katitems = [];

  var produkScanResult = [];
  var allKategori = [];
  TextEditingController scan = TextEditingController();

  var allDetailTrans = [];
  var DetailTrans = [];
  KasirHelper? helper;
  TextEditingController teSeach = TextEditingController();
  TextEditingController plusMinus = TextEditingController();

  TextEditingController harga = TextEditingController();
  late TextEditingController diskon = TextEditingController();
  TextEditingController priceAfterDiscount = TextEditingController();
  TextEditingController subTotal = TextEditingController();
  TextEditingController catatan = TextEditingController();

  List names = [];
  var items = [];
  List filteredNames = [];
  var allProduk = [];
  var allPembayaran = [];
  var pembayaran = [];
  var count;
  var countDisc;
  var scanResult;

  bool _isLoading = false;
  String? kode;
  final oCcy = NumberFormat.decimalPattern();

  bool loadData = true;
  final _streamController = StreamController<List<int>>();
  Stream<List<int>> get _stream => _streamController.stream;
  Sink<List<int>> get _sink => _streamController.sink;

  List data = [];
  int hasilDiskon = 1;
  var current;
  var currentString;
  var currentStringMinute;
  var status;

  List allTrans = [];
  List Trans = [];
  int? idTrx = 0;
  int? idSubTrx = 0;
  var selectDetailPembelian = [];
  List detailTrans = [];
  List allDetailTransaksi = [];
  List<List> all = [];

  List<List> AllData = [];

  @override
  void initState() {
    current = DateTime.parse(DateTime.now().toString());

    currentString = DateFormat('yyyy-MM-dd HH:mm:ss').format(current);

    currentStringMinute = DateFormat('yyyy-MM-dd HH:mm').format(current);
    helper = KasirHelper();

    refreshJumlahPembelian();

    if (helper != null) {
      helper!.allProduk().then((product) {
        setState(() {
          allProduk = product;
          items = allProduk;
          _isLoading = false;
        });
      });
    }

    if (helper != null) {
      helper!.allCategori().then((courses) {
        setState(() {
          allKategori = courses;
          Katitems = allKategori;
          _isLoading = false;
        });
      });
    }

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
      helper!.showPembelianAndTopingFront(widget.idTrans).then((courses) {
        //  setState(() {

        _isLoading = true;
        allTrans = courses;
        Trans = allTrans;
        // var id = Trans.first['id'];

        for (var x = 0; x < Trans.length; x++) {
          idTrx = 0;
          idTrx = Trans[x]['id_sub_transaksi'];
          // print(idTrx);
          //detailToping(idTrx);
          helper!.listSubDetailTransaksiFront(idTrx).then((cou) {
            selectDetailPembelian = cou;

            detailTrans = [];

            for (var a = 0; a < 1; a++) {
              allDetailTransaksi = cou;
              detailTrans = allDetailTransaksi;
              AllData.add(detailTrans);
            }

            setState(() {
              all = AllData;
            });
          });
        }
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

    // _sink.add(initValue);
    _stream.listen((event) => plusMinus.text = event.toString());

    _loadUserData();

    super.initState();
  }

  String? level;
  _loadUserData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    //print(localStorage.getString('user'));

    var a = localStorage.getString('user');

    //print(user);

    if (a != null) {
      var user = jsonDecode(localStorage.getString('user') ?? '');

      setState(() {
        level = user['level'];
      });
    } else {
      // Login();

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    }
  }

  var listPenjualan = [];
  sync() async {
    String url;

    url = 'produkSync';

    final response = await Network().getData_get(url);

    final dbClient = KasirHelper.db;

    if (response.statusCode == 200) {
      setState(() {
        listPenjualan = json.decode(response.body);
      });
      for (var item in listPenjualan) {
        var kode = item['kode'];
        var hargaJual = item['harga_jual'];
        var nama = item['nama_barang'];
        var idKategori = item['id_kategori'];
        var createdAtMysql = item['created_at'];
        var hargaBeli = item['harga_beli'];
        var stok = item['stok'];
        //var satuan = item['satuan'];

        // var gambar = item['gambar'];
        //String imgString;

        // var date = DateTime.parse(createdAtMysql.toString());

        var dateValue = DateFormat("yyyy-MM-ddTHH:mm:ssZ")
            .parseUTC(createdAtMysql)
            .subtract(const Duration(hours: 1))
            .toLocal();

        var tanggalMysql = DateFormat('yyyy-MM-dd HH:mm').format(dateValue);

        final maps = await dbClient!
            .rawQuery("select * from tb_produk where kode = ?", [kode]);

        //  var kd = maps.first['kode'];

        if (maps.isNotEmpty) {
          var createdAt = maps.first['tanggal_sekarang'];
          if (tanggalMysql != createdAt) {
            dbClient.rawQuery('''
              UPDATE tb_produk
              SET nama_barang = '$nama', harga_jual = '$hargaJual' , tanggal_sekarang = '$tanggalMysql', id_kategori = '$idKategori', harga_beli = '$hargaBeli', stok = '$stok'
              WHERE kode = '$kode'
              ''');
          }
        } else {
          //final http.Response response = await http.get(Uri.parse(gambar));

          //imgString = Utility.base64String(response.bodyBytes);
          dbClient.rawQuery('''
                  INSERT INTO tb_produk (kode, harga_jual,nama_barang,id_kategori,tanggal_sekarang,harga_beli,stok)
                                 VALUES ('$kode','$hargaJual' ,'$nama','$idKategori','$tanggalMysql','$hargaBeli','$stok')
              ''');
        }
      }
    } else {
      throw Exception('Failed to load album');
    }
  }

  void refreshJumlahPembelian() async {
    if (helper != null) {
      helper!.hitungPembelian().then((course) {
        setState(() {
          allPembayaran = course;
          pembayaran = allPembayaran;
          count = pembayaran.first['harga'];

          //appendValue(count.toString());

          //_isLoading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //  print(diskon.text);
    String tot;
    if (count != null) {
      tot = oCcy.format(count ?? "");
    } else {
      tot = "";
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
              badges.Badge(
                showBadge: allDetailTrans.isNotEmpty ? true : false,
                position: badges.BadgePosition.topEnd(top: 5, end: 2),
                badgeContent: Text(allDetailTrans.length.toString()),
                child: IconButton(
                  icon: const Icon(Icons.shop_rounded, color: Colors.white),
                  onPressed: () {
                    _refreshProduk();
                    showDialogWithFields();
                  },
                ),
              ),
            ],
          ),
          drawer: level == '1' ? const Menu() : const Menu2(),
          backgroundColor: Colors.grey[300],
          body:
              //coba(),

              SingleChildScrollView(
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    header(),
                    content(),

                    //  coba(),
                    //_dataProduk(),
                  ],
                )
              ],
            ),
          ),
          bottomNavigationBar: Container(
              height: 120,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 41, 88, 130),
              ),
              child: Column(
                children: [
                  Container(
                    // padding: EdgeInsets.only(bottom: 10),
                    width: double.infinity,

                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                    ),
                    height: 50,
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
                              child: const Text("Jumlah",
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold)),
                            ),

                            //  oCcy.format(int.parse(
                            //             course.hargaBarang.toString())),
                            Container(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text("IDR $tot",
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 10),
                        width: 150,
                        child: FloatingActionButton.extended(
                          onPressed: () async {
                            // print(DetailTrans);

                            for (var i = 0; i < Trans.length; i++) {
                              // if (itemCounts[i] != 0) {
                              helper!.updateStokDetailPemesanan(
                                  Trans[i]['id_barang'],
                                  Trans[i]['qty'],
                                  itemCounts[i],
                                  widget.idTrans,
                                  Trans[i]['harga_jual']);

                              idSubTrx = 0;
                              idSubTrx = Trans[i]['id_sub_transaksi'];

                              helper!
                                  .listSubDetailTransaksiFront(idTrx)
                                  .then((cou) {
                                selectDetailPembelian = cou;

                                detailTrans = [];

                                for (var a = 0; a < all[i].length; a++) {
                                  helper!.updateStokSubDetailPemesanan(
                                      all[i][a]['id_barang'],
                                      all[i][a]['qty'],
                                      itemCounts[i],
                                      widget.idTrans,
                                      idSubTrx,
                                      all[i][a]['harga_jual']);
                                }
                              });

                              var newHarga =
                                  Trans[i]['harga_jual'] * itemCounts[i];
                              if (itemCounts[i] != 0) {
                                TransaksiDetailPembelianModel course =
                                    TransaksiDetailPembelianModel({
                                  'id_barang': Trans[i]['id_barang'],
                                  'qty': itemCounts[i],
                                  'id_sub_transaksi': idSubTrx,
                                  'harga': newHarga,
                                  'status': 1,
                                  'created_at': currentString,
                                });

                                //if()
                                await helper!
                                    .createDetailTransaksiPembelian(course);
                              }

                              for (var a = 0; a < all[i].length; a++) {
                                var newHarga =
                                    all[i][a]['harga_jual'] * itemCounts[i];
                                if (itemCounts[i] != 0) {
                                  SubTransaksiDetailPembelianModel course =
                                      SubTransaksiDetailPembelianModel({
                                    'id_barang': all[i][a]['id_barang'],
                                    'qty': itemCounts[i],
                                    'harga': newHarga,
                                    'id_sub_transaksi': all[i][a]
                                        ['id_sub_transaksi'],
                                    'status': 1,
                                    'created_at': currentString,
                                  });

                                  //if()
                                  await helper!
                                      .createSubDetailTransaksiPembelian(
                                          course);

                                  sendSubToMysql(
                                      all[i][a]['id_barang'],
                                      itemCounts[i],
                                      newHarga,
                                      currentString,
                                      widget.idTrans,
                                      all[i][a]['qty'],
                                      all[i][a]['harga_jual'],
                                      all[i][a]['id_sub_transaksi']);
                                }
                              }

                              sendToMysql(
                                  Trans[i]['kode'],
                                  itemCounts[i],
                                  newHarga,
                                  currentString,
                                  widget.idTrans,
                                  Trans[i]['qty'],
                                  Trans[i]['harga_jual'],
                                  idSubTrx);

                              // print(
                              //     '${DetailTrans[i]['kode']}  ${itemCounts[i]}');
                              //  }
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TransPenjualan(
                                        tanggal: currentString,
                                        delivery: "1",
                                        idPembayaran: 0,
                                      )),
                            );
                          },
                          label: const Text('Konfirmasi'),
                          backgroundColor: Colors.blue[900],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              )),
        ));
  }

  @override
  void dispose() {
    _streamController.close();
    plusMinus.dispose();
    diskon.dispose();
    //priceAfterDiscount.dispose();
    super.dispose();
  }

  void _deleteItem(int id) async {
    await helper!.deleteDetailPembelianPemesanan(id, widget.idTrans);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a Produk!'),
    ));
    _refreshDetailPembelian();
    Navigator.of(context).pop(false);
  }

  void _deleteMysql(
    kodeBarang,
  ) async {
    Map data = {'id_barang': kodeBarang, 'id_transaksi': widget.idTrans};

    String url;

    url = 'delete_detail_transaksi_pemesanan';

    // final response = await htpp.post(Uri.parse(url), body: data);
    final response = await Network().getData_post(data, url);
    // var c = json.decode(response.body);

    if (response.statusCode == 200) {
      print('sukses');
    } else {
      print(response.body);
      throw Exception(response);
    }
  }

  showAlertDialog(BuildContext context, int id, int idBarang) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Yes"),
      onPressed: () {
        _deleteItem(idBarang);

        _deleteMysql(id);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("AlertDialog"),
      content: const Text("Apa Yakin Anda Akan Menghapus?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  var fillDisc;

  List<int> itemCounts = List.generate(10, (index) => 0);
  void incrementItemCount(int index) {
    setState(() {
      itemCounts[index]++;
    });
  }

  void decrementItemCount(int index) {
    setState(() {
      if (itemCounts[index] > 0) {
        itemCounts[index]--;
      }
    });
  }

  TransaksiDetailPembelianModel? course;
  Container content() {
    return Container(
        child: Column(
      children: [
        ListView.builder(
          itemCount: Trans.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            // }
            int indexToping = 0;

            indexToping = index;
            if (index >= all.length) {
              indexToping = 0;
            }
            plusMinus =
                TextEditingController(text: itemCounts[index].toString());
            return GestureDetector(
              child: SingleChildScrollView(
                // decoration: BoxDecoration(
                //   borderRadius: BorderRadius.circular(5),
                //   // color: Colors.white,
                // ),
                // height: 100,
                // width: double.infinity,
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
                              child: Text(Trans[index]['kode'].toString(),
                                  style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold)),
                            ),
                            Container(
                              padding: const EdgeInsets.only(top: 8, left: 9),
                              child: Text(
                                  Trans[index]['nama_barang'].toString(),
                                  style: const TextStyle(fontSize: 13)),
                            ),
                            Container(
                              padding: const EdgeInsets.only(top: 8, left: 9),
                              child: Text('Note : ${Trans[index]['catatan']}'),
                            ),

                            if (all.isNotEmpty)
                              Container(
                                  width: 270,
                                  height: 100,
                                  child: ListView.builder(
                                      itemCount: all[indexToping].length,
                                      // shrinkWrap: true,
                                      // physics: const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index2) {
                                        //  all.length;
                                        // if (all.isNotEmpty)
                                        //   for (var x = 0; x < all[index].length; x++)
                                        return Container(
                                          //width: 250,
                                          // width: 300,
                                          height: 40,
                                          padding: const EdgeInsets.only(
                                              top: 2, left: 9),
                                          decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                Colors.white,
                                                Colors.grey.shade400
                                              ])),
                                          child: Container(
                                            height: 20,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                        height: 30,
                                                        width: 150,
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                top: 10,
                                                                left: 9),
                                                        child: Text(
                                                          "- " +
                                                              all[indexToping][
                                                                          index2]
                                                                      [
                                                                      'nama_barang']
                                                                  .toString(),
                                                          style: const TextStyle(
                                                              fontSize: 13,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .italic),
                                                        )),

                                                    const Spacer(),
                                                    Container(
                                                      // width: double.infinity,
                                                      height: 20,
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 8,
                                                              right: 10),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            child: Text(
                                                              "${all[indexToping][index2]['qty']} x ${oCcy.format(int.parse(all[indexToping][index2]['harga_jual'].toString()))}",
                                                              style: const TextStyle(
                                                                  fontSize: 13,
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .italic),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    //  ],
                                                    //)
                                                  ],
                                                ),
                                                // Container(
                                                //   padding: const EdgeInsets.only(
                                                //       top: 2, left: 9),
                                                //   child: Text(
                                                //       'Note : ${selectDetailPembelian[index]['catatan']}'),
                                                // ),
                                              ],
                                            ),
                                          ),
                                        );
                                        //  fillDisc,
                                      })),

                            // fillDisc,
                          ],
                        ),
                        const Spacer(),
                        Container(
                            padding: const EdgeInsets.only(top: 15, right: 10),
                            child: Column(
                              children: [
                                Row(
                                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () =>
                                          decrementItemCount(index),
                                    ),
                                    //  Text('Item ${itemCounts[index]}'),
                                    SizedBox(
                                      width: 50,
                                      height: 40,
                                      child: TextField(
                                        style: const TextStyle(
                                            color: Color(0xFF000000)),
                                        cursorColor: const Color(0xFF9b9b9b),
                                        keyboardType: TextInputType.text,
                                        controller: plusMinus,
                                        onChanged: (value) {
                                          setState(() {
                                            hitungJumlahHarga(value);
                                          });
                                        },
                                        decoration: InputDecoration(
                                          fillColor: Colors.grey,
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                            borderSide: const BorderSide(
                                              color: Colors.white,
                                              width: 2.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () =>
                                          incrementItemCount(index),
                                    ),
                                  ],
                                ),
                              ],
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    )

        // child:

        );
  }

  Container header() {
    //var currentDate = DateTime.parse(widget.tanggal.toString());

    // var currentDate = DateFormat('dd-MM-yyyy').format(current);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        //Color.fromARGB(1, 41, 87, 129),
      ),
      height: 50,
      width: double.infinity,
      child: Material(
        elevation: 4.0,
        borderRadius: BorderRadius.circular(5.0),
        color: const Color.fromARGB(255, 42, 87, 129),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 9),
                  child: Text(currentString,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 25)),
                ),
                Container(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _refreshDetailPembelian() async {
    if (helper != null) {
      helper!.showPembelianPemesanan(widget.idTrans).then((product) {
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

  void showDialogWithFields() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: StatefulBuilder(
            // You need this, notice the parameters below:
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      //Color.fromARGB(1, 41, 87, 129),
                    ),
                    height: 130,
                    width: double.infinity,
                    child: Material(
                      elevation: 4.0,
                      borderRadius: BorderRadius.circular(5.0),
                      color: const Color.fromARGB(255, 42, 87, 129),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                  margin:
                                      const EdgeInsets.only(left: 10, top: 10),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  width: 200,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton(
                                      icon: const Icon(Icons.arrow_drop_down),
                                      iconSize: 30,
                                      underline: const SizedBox(),
                                      items: Katitems.map((item) {
                                        return DropdownMenuItem(
                                          value: item['id'].toString(),
                                          child: Text(item['nama_kategori']),
                                        );
                                      }).toList(),
                                      hint: const Text(
                                        "Please choose a Kategori",
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      onChanged: (String? newVal) {
                                        setState(() {
                                          _mySelection = newVal!;
                                          _dropdownError = null;
                                          var id = int.parse(
                                              _mySelection.toString());
                                          _cariKat(id);

                                          //print(newVal);
                                          //  this._getNames(newVal);
                                        });
                                      },
                                      value: _mySelection,
                                    ),
                                  )),
                              _dropdownError == null
                                  ? const SizedBox.shrink()
                                  : Text(
                                      _dropdownError ?? "",
                                      style: const TextStyle(color: Colors.red),
                                    ),
                            ],
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                                left: 10, top: 10, right: 10),
                            //  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            width: 340,
                            height: 40,
                            decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(10)),
                            child: TextFormField(
                              style: const TextStyle(color: Color(0xFF000000)),
                              cursorColor: const Color(0xFF9b9b9b),
                              keyboardType: TextInputType.text,
                              controller: teSeach,
                              onChanged: (value) {
                                setState(() {
                                  filterSeach(value);
                                });
                              },
                              decoration: InputDecoration(
                                fillColor: Colors.grey,
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: Colors.white,
                                ),
                                hintText: "Pencarian",
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: const BorderSide(
                                    color: Colors.white,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  // const SizedBox(
                  //   height: 10,
                  // ),
                  _buildList(),

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

  var afterDisc;

  final currencyFormatter = CurrencyFormatter();
  void hitungDiskon(String query) async {
    if (query.isNotEmpty) {
      var price = int.parse(harga.text);
      int disc = int.parse(diskon.text);
      afterDisc = (disc * price) / 100;
      var input = price - afterDisc;
      var jml = int.parse(plusMinus.text);

      setState(() {
        hasilDiskon = int.parse(input.toStringAsFixed(0));
        afterDisc;
        var total = hasilDiskon * jml;
        priceAfterDiscount =
            TextEditingController(text: hasilDiskon.toString());
        subTotal = TextEditingController(
            text: currencyFormatter.format(total.toString()));

        //  print(jml);
      });

      return;
    } else {
      setState(() {
        items = [];
        items = allProduk;
      });
    }
  }

  var hasilJumlah;
  void hitungJumlahHarga(String query) async {
    if (query.isNotEmpty) {
      var jumlah = int.parse(plusMinus.text);
      var price = int.parse(harga.text);

      setState(() {
        hasilJumlah = jumlah * price;

        subTotal = TextEditingController(
            text: currencyFormatter.format(hasilJumlah.toString()));
      });

      return;
    } else {
      setState(() {
        items = [];
        items = allProduk;
      });
    }
  }

  String removeCurrencyFormat(String formattedValue) {
    // Hapus semua karakter yang bukan angka
    String cleanValue = formattedValue.replaceAll(RegExp(r'[^\d]'), '');
    // String formattedNumber =
    //     cleanValue.replaceAll(RegExp(r"(\.0{2,})|(0*)$"), "");

    String resultString = cleanValue.substring(0, cleanValue.length - 2);

    return resultString;
  }

  void sendToMysql(
      id, jml, harga, waktu, idTrans, qty, hargaJual, idSubTrx) async {
    Map data = {
      'id_barang': id,
      'jumlah': jml,
      'harga': harga,
      'status': 1,
      'created_at': waktu,
      'id_transaksi': idTrans,
      'id_sub_transaksi': idSubTrx,
      'qty': qty,
      'harga_jual': hargaJual,
    };

    String url;

    url = 'split_trans';

    // final response = await htpp.post(Uri.parse(url), body: data);
    final response = await Network().getData_post(data, url);
    // var c = json.decode(response.body);

    if (response.statusCode == 200) {
      print('sukses');
    } else {
      throw Exception('Failed to load album');
    }
  }

  void sendSubToMysql(
      id, jml, harga, waktu, idTrans, qty, hargaJual, idSubTrans) async {
    Map data = {
      'id_barang': id,
      'jumlah': jml,
      'harga': harga,
      'status': 1,
      'created_at': waktu,
      'id_transaksi': idTrans,
      'id_sub_transaksi': idSubTrans,
      'qty': qty,
      'harga_jual': hargaJual,
    };

    String url;

    url = 'split_sub_trans';

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

  void refreshKategori() {
    if (helper != null) {
      helper!.allCategori().then((courses) {
        setState(() {
          allKategori = courses;
          Katitems = allKategori;
          _isLoading = false;
        });
      });
    }
  }

  void _refreshProdukCari(id) async {
    if (helper != null) {
      helper!.cariKategori(id).then((product) {
        setState(() {
          allProduk = product;
          items = allProduk;
        });
      });
    }
  }

  void _cariKat(int id) async {
    await helper!.cariKategori(id);

    _refreshProdukCari(id);
  }

  void filterSeach(String query) async {
    var dummySearchList = allProduk;
    if (query.isNotEmpty) {
      var dummyListData = [];
      for (var item in dummySearchList) {
        var course = ProdukModel.fromMap(item);
        if (course.namaBarang!.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      }
      setState(() {
        items = [];
        items.addAll(dummyListData);
      });

      return;
    } else {
      setState(() {
        items = [];
        items = allProduk;
      });
    }
  }

  Expanded _buildList() {
    // print("seleksiii $items");

    return Expanded(
        child: Container(
      child: ListView.builder(
        itemCount: items.length,
        // shrinkWrap: true,
        // physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          // ProdukModel? course = ProdukModel.fromMap(items[index]);
          return GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                // color: Colors.white,
              ),
              height: 60,
              width: double.infinity,
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
                            child: Text(
                                "${items[index]['kode']} (${items[index]['stok']})",
                                style: const TextStyle(
                                    fontSize: 15, color: Colors.blue)),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 15, left: 9),
                            child: Text(items[index]['nama_barang'].toString(),
                                style: const TextStyle(fontSize: 13)),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.only(top: 15, right: 10),
                        child: Text("IDR ${items[index]['harga_jual']}",
                            style: const TextStyle(fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ));
  }
}
