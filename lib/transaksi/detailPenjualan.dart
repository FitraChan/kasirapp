import 'dart:async';
import 'dart:convert';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kasirapp/transaksi/transPenjualan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kasirapp/model/currencyFormatter.dart';
import 'package:kasirapp/provider/idTransaksi_provider.dart';

import 'package:kasirapp/model/produkModel.dart';
import 'package:kasirapp/model/rupiahCurrency.dart';
import 'package:kasirapp/model/transaksiDetailPembelianModel.dart';
import 'package:intl/intl.dart';
import 'package:kasirapp/network_utils/api.dart';
import 'package:kasirapp/screen/home.dart';
import 'package:kasirapp/screen/login.dart';
import 'package:kasirapp/screen/menu2.dart';
import 'package:kasirapp/transaksi/pembayaranPesanDidepan.dart';
import 'package:kasirapp/transaksi/penjualan.dart';

import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:kasirapp/transaksi/splitPesanan.dart';

import '../screen/menu1.dart';

//import 'package:dio/dio.dart';

class DetailPenjualan extends ConsumerStatefulWidget {
  const DetailPenjualan({Key? key, required this.idTrans}) : super(key: key);

  final int idTrans;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DetailPenjualanState();
}

class _DetailPenjualanState extends ConsumerState<DetailPenjualan> {
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
  var selectDetailPembelian = [];
  List detailTrans = [];
  List allDetailTransaksi = [];
  List<List> all = [];

  List<List> AllData = [];
  var p;

  var produkScanResult = [];
  var allKategori = [];
  TextEditingController scan = TextEditingController();

  var allDetailTrans = [];
  var Trans = [];
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
  final _streamController = StreamController<int>();
  Stream<int> get _stream => _streamController.stream;
  Sink<int> get _sink => _streamController.sink;
  int initValue = 1;
  List data = [];
  int hasilDiskon = 1;
  var current;
  var currentString;
  var currentStringMinute;
  var status;

  @override
  void initState() {
    current = DateTime.parse(DateTime.now().toString());

    currentString = DateFormat('yyyy-MM-dd HH:mm:ss').format(current);

    currentStringMinute = DateFormat('yyyy-MM-dd HH:mm').format(current);
    helper = KasirHelper();

    refreshJumlahPembelian();

    allTrans = [];
    Trans = [];
    selectDetailPembelian = [];
    detailTrans = [];
    allDetailTransaksi = [];
    all = [];
    idTrx = 0;

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

    _sink.add(initValue);
    _stream.listen((event) => plusMinus.text = event.toString());

    _loadUserData();

    super.initState();
  }

  List allTrans = [];
  //List Trans = [];
  int? idTrx = 0;

  String? level;
  _loadUserData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    //print(localStorage.getString('user'));

    var a = localStorage.getString('user');

    //print(user);

    if (a != null) {
      var user = jsonDecode(localStorage.getString('user') ?? '');

      setState(() {
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
        var hargaJual = item['harga'];
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
              SET nama_barang = '$nama', harga = '$hargaJual' , tanggal_sekarang = '$tanggalMysql', id_kategori = '$idKategori', harga_beli = '$hargaBeli', stok = '$stok'
              WHERE kode = '$kode'
              ''');
          }
        } else {
          //final http.Response response = await http.get(Uri.parse(gambar));

          //imgString = Utility.base64String(response.bodyBytes);
          dbClient.rawQuery('''
                  INSERT INTO tb_produk (kode, harga,nama_barang,id_kategori,tanggal_sekarang,harga_beli,stok)
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

  void produkScan(kode) async {
    if (helper != null) {
      helper!.selectProdukScan(kode).then((course) {
        setState(() {
          produkScanResult = course;
          scanResult = produkScanResult.first;

          //appendValue(count.toString());

          //_isLoading = false;
        });

        showDialogWithCount(scanResult);
      });
    }
  }

  String? barcodeScanRes;
  String _scanBarcode = '';

  // Future<void> scanQR() async {
  //   // Platform messages may fail, so we use a try/catch PlatformException.
  //   try {
  //     barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
  //         '#ff6666', 'Cancel', true, ScanMode.QR);
  //     print(barcodeScanRes);
  //   } on PlatformException {
  //     barcodeScanRes = 'Failed to get platform version.';
  //   }

  //   // Platform messages are asynchronous, so we initialize in an async method.

  //   // setState to update our non-existent appearance.
  //   if (!mounted) return;

  //   setState(() {
  //     _scanBarcode = barcodeScanRes!;

  //     produkScan(_scanBarcode);
  //   });
  // }
  @override
  Widget build(BuildContext context) {
    String tot = count != null ? oCcy.format(count) : "0";

    return WillPopScope(
      onWillPop: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Penjualan(tanggal: ""),
          ),
        );
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: const Color(0xffF4F6F9),

        /// APPBAR
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          title: const Text(
            "Penjualan Baru",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Home(title: ''),
                ),
              );
            },
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: badges.Badge(
                showBadge: allDetailTrans.isNotEmpty,
                badgeContent: Text(
                  allDetailTrans.length.toString(),
                  style: const TextStyle(color: Colors.white),
                ),
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: () {
                    _refreshProduk();
                    showDialogWithFields();
                  },
                ),
              ),
            ),
          ],
        ),

        drawer: level == '1' ? const Menu() : const Menu2(),

        body: Column(
          children: [
            /// HEADER
            modernHeader(),

            /// CONTENT
            Expanded(
              child: contentModern(),
            ),
          ],
        ),

        /// BOTTOM BAR
        bottomNavigationBar: modernBottomBar(tot),
      ),
    );
  }

  Widget modernBottomBar(String tot) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(0.08),
          )
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// TOTAL
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Pembayaran",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  "Rp $tot",
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// BUTTON
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 55,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () {
                        ref.read(selectedIdTransaksiProvider.notifier).state =
                            widget.idTrans;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TransPenjualan(
                              tanggal: currentString,
                              delivery: '1',
                              idPembayaran: 2,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.payments_outlined,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Bayar Tunai",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 55,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SplitPesanan(
                              idTrans: widget.idTrans,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.call_split,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Split Pesanan",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _streamController.close();
    plusMinus.dispose();
    diskon.dispose();
    teSeach.dispose();
    harga.dispose();
    subTotal.dispose();
    catatan.dispose();

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
  // Container discount() {
  //   if (countDisc != 0) {
  //     return Container(
  //       padding: EdgeInsets.only(top: 8, left: 9),
  //       child: Text(countDisc.toString(), style: TextStyle(fontSize: 13)),
  //     );
  //   } else {
  //     return Container(
  //       padding: EdgeInsets.only(top: 8, left: 9),
  //       child: Text(""),
  //     );
  //   }
  // }
  TransaksiDetailPembelianModel? course;
  Widget contentModern() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: Trans.length,
      itemBuilder: (context, index) {
        final item = Trans[index];

        final harga = int.tryParse(
              item['harga'].toString(),
            ) ??
            0;

        final qty = item['qty'] ?? 0;

        final diskon = item['diskon'] ?? 0;

        final total = harga * qty;

        return GestureDetector(
          onTap: () {
            showDialogWithCountEdit(item);
          },
          onLongPress: () {
            final idBarang = int.parse(item['id_barang'].toString());

            final kodeBarang = int.parse(item['kode'].toString());

            showAlertDialog(
              context,
              kodeBarang,
              idBarang,
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                  color: Colors.black.withOpacity(0.05),
                )
              ],
            ),
            child: Row(
              children: [
                /// ICON
                Container(
                  height: 58,
                  width: 58,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: Colors.blue,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 14),

                /// INFO
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['nama_barang'].toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Kode : ${item['kode']}",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              "$qty x ${oCcy.format(harga)}",
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          if (diskon != 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                "Diskon $diskon",
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ]
                        ],
                      )
                    ],
                  ),
                ),

                /// TOTAL
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Rp ${oCcy.format(total)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.grey,
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget modernHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xff1565C0),
            Color(0xff42A5F5),
          ],
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: const Offset(0, 4),
            color: Colors.blue.withOpacity(0.2),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Transaksi Aktif",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentString,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _refreshDetailPembelian() async {
    if (helper != null) {
      helper!.showPembelianPemesanan(widget.idTrans).then((product) {
        setState(() {
          allDetailTrans = product;
          Trans = allDetailTrans;
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

  void showDialogWithCountEdit(items) {
    plusMinus = TextEditingController(text: items['qty'].toString());

    harga = TextEditingController(
        text: currencyFormatter.format(items['harga'].toString()));

    subTotal = TextEditingController(
        text: currencyFormatter.format(items['harga'].toString()));

    catatan = TextEditingController(text: items['catatan'].toString());

    var idBarang = items['id_barang'];

    var kodeBarang = items['kode'];

    var stok = items['stok'];

    Container limit;

    if (stok <= 10) {
      limit = Container(
          margin: const EdgeInsets.only(left: 10),
          child: DefaultTextStyle(
            style: const TextStyle(fontSize: 20.0, color: Colors.red),
            child: AnimatedTextKit(
              animatedTexts: [
                WavyAnimatedText('SISA STOK $stok'),
                //WavyAnimatedText('Look at the waves'),
              ],
              isRepeatingAnimation: true,
            ),
          ));
    } else {
      limit = Container();
    }
    var disc;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: StatefulBuilder(
            // You need this, notice the parameters below:
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                //  color: Color.fromARGB(255, 226, 222, 222),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      // crossAxisAlignment: CrossAxisAlignment.stretch,
                      // mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          // margin: const EdgeInsets.only(),
                          child: Text(items['nama_barang'].toString(),
                              style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        limit
                      ],
                    ),
                    Container(
                      child: const Divider(
                        color: Color.fromARGB(255, 3, 87, 156),
                        thickness: 3,
                        indent: 0,
                        endIndent: 0,
                      ),
                    ),
                    Container(
                      child: const Text("Jumlah Barang",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.blue,
                          )),
                    ),
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _sink.add(++initValue);

                            // ignore: unused_local_variable
                            var hasilTambah = initValue *
                                int.parse(items['harga'].toString());

                            int output;
                            if (diskon.text != "") {
                              output = initValue * hasilDiskon;
                              hasilTambah = output;
                            }

                            // print("hasilllll $hasil");
                            setState(() {
                              subTotal = TextEditingController(
                                  text: currencyFormatter
                                      .format(hasilTambah.toString()));
                            });
                          },
                          child: Container(
                            child: const Image(
                              image: AssetImage('images/plus.png'),
                              width: 40,
                              height: 40,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 50,
                          height: 40,
                          child: TextField(
                            style: const TextStyle(color: Color(0xFF000000)),
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

                              //  hintText: "Pencarian",
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                  width: 2.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _sink.add(--initValue);

                            var hasilKurang = initValue *
                                int.parse(items['harga'].toString());
                            int output;
                            if (diskon.text != "") {
                              output = initValue * hasilDiskon;
                              hasilKurang = output;
                            }
                            setState(() {
                              subTotal = TextEditingController(
                                  text: currencyFormatter
                                      .format(hasilKurang.toString()));
                            });
                          },
                          child: Container(
                            child: const Image(
                              image: AssetImage('images/minus.png'),
                              width: 40,
                              height: 40,
                            ),
                          ),
                        )
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: const Text("Harga",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.blue,
                          )),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      child: TextField(
                        style: const TextStyle(color: Color(0xFF000000)),
                        cursorColor: const Color(0xFF9b9b9b),
                        keyboardType: TextInputType.text,
                        controller: harga,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CurrencyInputFormatter(),
                        ],
                        decoration: InputDecoration(
                          fillColor: const Color.fromARGB(255, 204, 201, 201),
                          filled: true,
                          //  hintText: "Pencarian",
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 5, 81, 143),
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: const Text("Sub Total",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.blue,
                          )),
                    ),
                    Container(
                      child: TextField(
                        style: const TextStyle(color: Color(0xFF000000)),
                        cursorColor: const Color(0xFF9b9b9b),
                        keyboardType: TextInputType.text,
                        controller: subTotal,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CurrencyInputFormatter(),
                        ],
                        decoration: InputDecoration(
                          fillColor: const Color.fromARGB(255, 255, 255, 255),
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 5, 81, 143),
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: const Text("Catatan",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.blue,
                          )),
                    ),
                    Container(
                      child: TextField(
                        style: const TextStyle(color: Color(0xFF000000)),
                        cursorColor: const Color(0xFF9b9b9b),
                        keyboardType: TextInputType.text,
                        controller: catatan,
                        decoration: InputDecoration(
                          fillColor: const Color.fromARGB(255, 255, 255, 255),
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 5, 81, 143),
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                              width: 110,
                              child: FloatingActionButton.extended(
                                heroTag: 'uniqueTag4',
                                backgroundColor:
                                    const Color.fromARGB(255, 95, 151, 236),
                                label: const Text(
                                  'Simpan',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () async {
                                  String subTotFormat =
                                      removeCurrencyFormat(subTotal.text);
                                  var jml = int.parse(plusMinus.text);
                                  var harga = int.parse(subTotFormat);
                                  if (afterDisc != null) {
                                    disc = (afterDisc.round());
                                  } else {
                                    disc = 0;
                                  }

                                  await helper!
                                      .updateListDetailTransaksiPembelian(
                                          widget.idTrans,
                                          idBarang,
                                          jml,
                                          harga,
                                          catatan.text);

                                  refreshJumlahPembelian();

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DetailPenjualan(
                                              idTrans: widget.idTrans,
                                            )),
                                  );

                                  sendToMysql(
                                      widget.idTrans,
                                      kodeBarang,
                                      jml,
                                      harga,
                                      //  1,
                                      disc,
                                      catatan.text,
                                      currentString,
                                      'update');
                                },
                              )),
                          SizedBox(
                              width: 110,
                              child: FloatingActionButton.extended(
                                  heroTag: 'uniqueTag5',
                                  backgroundColor:
                                      const Color.fromARGB(255, 95, 151, 236),
                                  label: const Text(
                                    'Batal',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  onPressed: () async {
                                    subTotal = TextEditingController(text: "");
                                    harga = TextEditingController(text: "");
                                    plusMinus =
                                        TextEditingController(text: "1");
                                    diskon = TextEditingController(text: "");
                                    priceAfterDiscount =
                                        TextEditingController(text: "");

                                    initValue = 1;

                                    Navigator.pop(context);
                                  })),
                        ],
                      ),
                    )
                  ],
                ),
              );

              //   return Text(teSeach.text);
            },
          ),
        );
      },
    );
  }

  void showDialogWithCount(items) {
    harga = TextEditingController(
        text: currencyFormatter.format(items['harga'].toString()));

    subTotal = TextEditingController(
        text: currencyFormatter.format(items['harga'].toString()));

    var idBarang = items['id'];

    var kodeBarang = items['kode'];

    var stok = items['stok'];

    Container limit;

    if (stok <= 10) {
      limit = Container(
          margin: const EdgeInsets.only(left: 10),
          child: DefaultTextStyle(
            style: const TextStyle(fontSize: 20.0, color: Colors.red),
            child: AnimatedTextKit(
              animatedTexts: [
                WavyAnimatedText('SISA STOK $stok'),
                //WavyAnimatedText('Look at the waves'),
              ],
              isRepeatingAnimation: true,
            ),
          ));
    } else {
      limit = Container();
    }
    var disc;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: StatefulBuilder(
            // You need this, notice the parameters below:
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                //  color: Color.fromARGB(255, 226, 222, 222),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      // crossAxisAlignment: CrossAxisAlignment.stretch,
                      // mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          // margin: const EdgeInsets.only(),
                          child: Text(items['nama_barang'].toString(),
                              style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        limit
                      ],
                    ),
                    Container(
                      child: const Divider(
                        color: Color.fromARGB(255, 3, 87, 156),
                        thickness: 3,
                        indent: 0,
                        endIndent: 0,
                      ),
                    ),
                    Container(
                      child: const Text("Jumlah Barang",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.blue,
                          )),
                    ),
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _sink.add(++initValue);

                            // ignore: unused_local_variable
                            var hasilTambah = initValue *
                                int.parse(items['harga'].toString());

                            int output;
                            if (diskon.text != "") {
                              output = initValue * hasilDiskon;
                              hasilTambah = output;
                            }

                            // print("hasilllll $hasil");
                            setState(() {
                              subTotal = TextEditingController(
                                  text: currencyFormatter
                                      .format(hasilTambah.toString()));
                            });
                          },
                          child: Container(
                            child: const Image(
                              image: AssetImage('images/plus.png'),
                              width: 40,
                              height: 40,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 50,
                          height: 40,
                          child: TextField(
                            style: const TextStyle(color: Color(0xFF000000)),
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

                              //  hintText: "Pencarian",
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                  width: 2.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _sink.add(--initValue);

                            var hasilKurang = initValue *
                                int.parse(items['harga'].toString());
                            int output;
                            if (diskon.text != "") {
                              output = initValue * hasilDiskon;
                              hasilKurang = output;
                            }
                            setState(() {
                              subTotal = TextEditingController(
                                  text: currencyFormatter
                                      .format(hasilKurang.toString()));
                            });
                          },
                          child: Container(
                            child: const Image(
                              image: AssetImage('images/minus.png'),
                              width: 40,
                              height: 40,
                            ),
                          ),
                        )
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: const Text("Harga",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.blue,
                          )),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      child: TextField(
                        style: const TextStyle(color: Color(0xFF000000)),
                        cursorColor: const Color(0xFF9b9b9b),
                        keyboardType: TextInputType.text,
                        controller: harga,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CurrencyInputFormatter(),
                        ],
                        decoration: InputDecoration(
                          fillColor: const Color.fromARGB(255, 204, 201, 201),
                          filled: true,
                          //  hintText: "Pencarian",
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 5, 81, 143),
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: const Text("Sub Total",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.blue,
                          )),
                    ),
                    Container(
                      child: TextField(
                        style: const TextStyle(color: Color(0xFF000000)),
                        cursorColor: const Color(0xFF9b9b9b),
                        keyboardType: TextInputType.text,
                        controller: subTotal,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CurrencyInputFormatter(),
                        ],
                        decoration: InputDecoration(
                          fillColor: const Color.fromARGB(255, 255, 255, 255),
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 5, 81, 143),
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: const Text("Catatan",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.blue,
                          )),
                    ),
                    Container(
                      child: TextField(
                        style: const TextStyle(color: Color(0xFF000000)),
                        cursorColor: const Color(0xFF9b9b9b),
                        keyboardType: TextInputType.text,
                        controller: catatan,
                        decoration: InputDecoration(
                          fillColor: const Color.fromARGB(255, 255, 255, 255),
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 5, 81, 143),
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                              width: 110,
                              child: FloatingActionButton.extended(
                                heroTag: 'uniqueTag6',
                                backgroundColor:
                                    const Color.fromARGB(255, 95, 151, 236),
                                label: const Text(
                                  'Simpan',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () async {
                                  String subTotFormat =
                                      removeCurrencyFormat(subTotal.text);
                                  var jml = int.parse(plusMinus.text);
                                  var harga = int.parse(subTotFormat);
                                  if (afterDisc != null) {
                                    disc = (afterDisc.round());
                                  } else {
                                    disc = 0;
                                  }
                                  //    var status = 1;

                                  TransaksiDetailPembelianModel course =
                                      TransaksiDetailPembelianModel({
                                    'id_transaksi': widget.idTrans,
                                    'id_barang': idBarang,
                                    'qty': jml,
                                    'harga': harga,
                                    'status': 2,
                                    'diskon': disc,
                                    'catatan': catatan.text,
                                    'created_at': currentString
                                  });
                                  await helper!
                                      .createDetailTransaksiPembelian(course);

                                  refreshJumlahPembelian();

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DetailPenjualan(
                                              idTrans: widget.idTrans,
                                            )),
                                  );
                                  sendToMysql(
                                      widget.idTrans,
                                      kodeBarang,
                                      jml,
                                      harga,
                                      //  1,
                                      disc,
                                      catatan.text,
                                      currentString,
                                      '');
                                },
                              )),
                          SizedBox(
                              width: 110,
                              child: FloatingActionButton.extended(
                                  heroTag: 'uniqueTag7',
                                  backgroundColor:
                                      const Color.fromARGB(255, 95, 151, 236),
                                  label: const Text(
                                    'Batal',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  onPressed: () async {
                                    subTotal = TextEditingController(text: "");
                                    harga = TextEditingController(text: "");
                                    plusMinus =
                                        TextEditingController(text: "1");
                                    diskon = TextEditingController(text: "");
                                    priceAfterDiscount =
                                        TextEditingController(text: "");

                                    initValue = 1;

                                    Navigator.pop(context);
                                  })),
                        ],
                      ),
                    )
                  ],
                ),
              );

              //   return Text(teSeach.text);
            },
          ),
        );
      },
    );
  }

  void sendToMysql(
      idTrans, id, jml, harga, disc, catatan, waktu, update) async {
    Map data = {
      'id_transaksi': idTrans,
      'id_barang': id,
      'qty': jml,
      'harga': harga,
      'status': 3,
      'diskon': disc,
      'catatan': catatan,
      'created_at': waktu,
      'ket': update,
    };

    String url;

    url = 'save_detail_trans_pembelian';

    // final response = await htpp.post(Uri.parse(url), body: data);
    final response = await Network().getData_post(data, url);
    // var c = json.decode(response.body);

    if (response.statusCode == 200) {
      print('sukses');
    } else {
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
              showDialogWithCount(items[index]);
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
                        child: Text("IDR ${items[index]['harga']}",
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
