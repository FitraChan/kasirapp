// // ignore_for_file: prefer_const_constructors

// import 'dart:async';

// import 'package:flutter/material.dart';

// import 'package:kasirapp/model/produkModel.dart';
// import 'package:kasirapp/model/transaksiPembelianModel.dart';
// import 'package:kasirapp/model/transaksiDetailPembelianModel.dart';
// import 'package:kasirapp/model/pembayaranModel.dart';
// import 'package:intl/intl.dart';
// import 'package:kasirapp/screen/home.dart';
// import 'package:kasirapp/transaksi/penjualan.dart';
// //import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

// import 'package:kasirapp/helpers/dbkasir.dart';

// //import 'package:dio/dio.dart';

// class TransPengembalian extends StatefulWidget {
//   const TransPengembalian({Key? key, required this.tanggal}) : super(key: key);
//   final String tanggal;

//   @override
//   _TransPengembalianState createState() => _TransPengembalianState();
// }

// class _TransPengembalianState extends State<TransPengembalian> {
//   final TextEditingController _filter = TextEditingController();

//   String? email;
//   //String? nim;
//   String? notificationText;
//   String? kewajiban;
//   String? bayar;
//   String? tunggakan;
//   String? _dropdownError;
//   String? _mySelection;
//   var Katitems = [];

//   var produkScanResult = [];
//   var allKategori = [];
//   TextEditingController scan = TextEditingController();

//   var allDetailTrans = [];
//   var DetailTrans = [];
//   KasirHelper? helper;
//   TextEditingController teSeach = TextEditingController();
//   TextEditingController plusMinus = TextEditingController();
//   TextEditingController harga = TextEditingController();
//   late TextEditingController diskon = TextEditingController();
//   TextEditingController priceAfterDiscount = TextEditingController();
//   TextEditingController subTotal = TextEditingController();

//   List names = [];
//   var items = [];
//   List filteredNames = [];
//   var allProduk = [];
//   var allPembayaran = [];
//   var pembayaran = [];
//   var count;
//   var countDisc;
//   var scanResult;

//   bool _isLoading = false;
//   String? kode;
//   final oCcy = NumberFormat.decimalPattern();

//   bool loadData = true;
//   final _streamController = StreamController<int>();
//   Stream<int> get _stream => _streamController.stream;
//   Sink<int> get _sink => _streamController.sink;
//   int initValue = 1;
//   List data = [];
//   int hasilDiskon = 1;
//   @override
//   void initState() {
//     helper = KasirHelper();

//     refreshJumlahPembelian();
//     if (helper != null) {
//       helper!.allProduk().then((product) {
//         setState(() {
//           allProduk = product;
//           items = allProduk;
//           _isLoading = false;
//         });
//       });
//     }

//     if (helper != null) {
//       helper!.allCategori().then((courses) {
//         setState(() {
//           allKategori = courses;
//           Katitems = allKategori;
//           _isLoading = false;
//         });
//       });
//     }

//     if (helper != null) {
//       helper!.showPembelian().then((courses) {
//         setState(() {
//           allDetailTrans = courses;
//           DetailTrans = allDetailTrans;
//           if (DetailTrans.isNotEmpty) {
//             countDisc = DetailTrans.first['diskon'];
//           }
//           //_isLoading = false;
//         });
//       });
//     }

//     _sink.add(initValue);
//     _stream.listen((event) => plusMinus.text = event.toString());

//     super.initState();
//   }

//   void refreshJumlahPembelian() async {
//     if (helper != null) {
//       helper!.hitungPembelian().then((course) {
//         setState(() {
//           allPembayaran = course;
//           pembayaran = allPembayaran;
//           count = pembayaran.first['harga'];

//           //appendValue(count.toString());

//           //_isLoading = false;
//         });
//       });
//     }
//   }

//   void produkScan(kode) async {
//     if (helper != null) {
//       helper!.selectProdukScan(kode).then((course) {
//         setState(() {
//           produkScanResult = course;
//           scanResult = produkScanResult.first;

//           //appendValue(count.toString());

//           //_isLoading = false;
//         });

//         showDialogWithCount(scanResult);
//       });
//     }
//   }

//   String? barcodeScanRes;
//   final String _scanBarcode = '';

//   // Future<void> scanQR() async {
//   //   // Platform messages may fail, so we use a try/catch PlatformException.
//   //   try {
//   //     barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
//   //         '#ff6666', 'Cancel', true, ScanMode.QR);
//   //     print(barcodeScanRes);
//   //   } on PlatformException {
//   //     barcodeScanRes = 'Failed to get platform version.';
//   //   }

//   //   // Platform messages are asynchronous, so we initialize in an async method.

//   //   // setState to update our non-existent appearance.
//   //   if (!mounted) return;

//   //   setState(() {
//   //     _scanBarcode = barcodeScanRes!;

//   //     produkScan(_scanBarcode);
//   //   });
//   // }

//   @override
//   Widget build(BuildContext context) {
//     //  print(diskon.text);

//     String tot;
//     if (count != null) {
//       tot = oCcy.format(count ?? "");
//     } else {
//       tot = "";
//     }

//     return WillPopScope(
//         onWillPop: () async {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (context) => Penjualan(
//                       tanggal: "",
//                     )),
//           );
//           return Future.value(true);
//         },
//         child: Scaffold(
//           appBar: AppBar(
//             //Menambahkan TitleBar
//             title: Text('Pengembalian Baru'),
//             //Mengubah Warna Background
//             backgroundColor: Colors.red[900],
//             //Menambahkan Leading menu
//             leading: IconButton(
//               icon: Icon(Icons.home, color: Colors.white),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => Home(
//                             title: '',
//                           )),
//                 );
//               },
//             ),
//             //Menambahkan Beberapa Action Button
//             actions: <Widget>[
//               IconButton(
//                 icon: Icon(Icons.add, color: Colors.white),
//                 onPressed: () {
//                   _refreshProduk();
//                   showDialogWithFields();
//                 },
//               ),
//               IconButton(
//                 icon: Icon(Icons.search, color: Colors.white),
//                 onPressed: () {},
//               ),
//             ],
//           ),
//           backgroundColor: Colors.grey[300],
//           body: SingleChildScrollView(
//             child: Stack(
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     header(),
//                     content(),

//                     // coba(),
//                     //_dataProduk(),
//                   ],
//                 )
//               ],
//             ),
//           ),
//           bottomNavigationBar: Container(
//               height: 120,
//               // ignore: sort_child_properties_last
//               child: Column(
//                 children: [
//                   Container(
//                     // padding: EdgeInsets.only(bottom: 10),
//                     width: double.infinity,

//                     decoration: BoxDecoration(
//                       color: Colors.grey[300],
//                     ),
//                     height: 50,
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.only(top: 10),
//                         width: 300,
//                         child: FloatingActionButton.extended(
//                           onPressed: () {
//                             //    showAlertDialog(BuildContext context) {
//                             // set up the buttons
//                             Widget cancelButton = TextButton(
//                               child: const Text("Cancel"),
//                               onPressed: () {
//                                 Navigator.of(context).pop();
//                               },
//                             );
//                             Widget continueButton = TextButton(
//                               child: const Text("Continue"),
//                               onPressed: () {
//                                 var dates = DateTime.parse(widget.tanggal);

//                                 var formattedDate =
//                                     DateFormat('yyyy-MM-dd HH:mm:ss')
//                                         .format(dates);

//                                 var allTotal = int.parse(count.toString());

//                                 TransaksiPembelianModel beli =
//                                     TransaksiPembelianModel({
//                                   'total': allTotal,
//                                   'id_pembeli': 0,
//                                   'keterangan': '',
//                                   'created_at': formattedDate,
//                                 });

//                                 helper!.createTransaksiPembelian(beli);
//                                 var pembelian = [];
//                                 var selectDetailPembelian = [];

//                                 var idTrx;
//                                 if (helper != null) {
//                                   helper!.idPembelian().then((courses) {
//                                     setState(() {
//                                       //allDetailTrans = courses;
//                                       pembelian = courses;
//                                       idTrx = pembelian.first['id'];
//                                       //_isLoading = false;

//                                       PembayaranModel bayar = PembayaranModel({
//                                         'total': allTotal,
//                                         'id_transaksi': idTrx,
//                                         'created_at': formattedDate,
//                                         'dibayar': allTotal,
//                                         'kembalian': 0,
//                                       });

//                                       helper!.createPembayaran(bayar);

//                                       helper!
//                                           .updateDetailTransaksiPembelianUntukPengembalianBarang(
//                                               idTrx);

//                                       helper!
//                                           .selectDetailTransaksiPembelian(idTrx)
//                                           .then((cou) {
//                                         selectDetailPembelian = cou;

//                                         // var panj = selectDetailPembelian.length;

//                                         for (var a = 0;
//                                             a < selectDetailPembelian.length;
//                                             a++) {
//                                           // print(selectDetailPembelian[a]['harga']);

//                                           var idBar = selectDetailPembelian[a]
//                                               ['id_barang'];
//                                           var stock =
//                                               selectDetailPembelian[a]['stok'];
//                                           var jum =
//                                               selectDetailPembelian[a]['qty'];

//                                           helper!.updateStokPengembalianBarang(
//                                               idBar, stock, jum);
//                                         }
//                                         //allDetailTrans = courses;
//                                       });
//                                     });
//                                   });
//                                 }

//                                 Navigator.of(context).push(
//                                   MaterialPageRoute(
//                                     builder: (context) => Penjualan(
//                                       tanggal: '',
//                                     ),
//                                   ),
//                                 );
//                               },
//                             );

//                             // set up the AlertDialog
//                             AlertDialog alert = AlertDialog(
//                               title: Text("AlertDialog"),
//                               content: Text("IDR $tot?"),
//                               actions: [
//                                 cancelButton,
//                                 continueButton,
//                               ],
//                             );

//                             // show the dialog
//                             showDialog(
//                               context: context,
//                               builder: (BuildContext context) {
//                                 return alert;
//                               },
//                             );
//                             // }
//                           },
//                           label: const Text('Pengembalian Barang'),
//                           backgroundColor: Colors.blue[900],
//                           foregroundColor: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               decoration: BoxDecoration(
//                 color: Color.fromARGB(255, 41, 88, 130),
//               )),
//         ));
//   }

//   @override
//   void dispose() {
//     _streamController.close();
//     plusMinus.dispose();
//     diskon.dispose();
//     //priceAfterDiscount.dispose();
//     super.dispose();
//   }

//   // void _deleteItem(int id) async {
//   //   await helper!.deleteDetailPembelian(id);
//   //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//   //     content: Text('Successfully deleted a Produk!'),
//   //   ));
//   //   _refreshDetailPembelian();
//   //   Navigator.of(context).pop(false);
//   // }

//   showAlertDialog(BuildContext context, int id) {
//     // set up the buttons
//     Widget cancelButton = TextButton(
//       child: Text("Cancel"),
//       onPressed: () {
//         Navigator.of(context).pop();
//       },
//     );
//     Widget continueButton = TextButton(
//       child: Text("Yes"),
//       onPressed: () {
//         // _deleteItem(id);
//       },
//     );

//     // set up the AlertDialog
//     AlertDialog alert = AlertDialog(
//       title: Text("AlertDialog"),
//       content: Text("Apa Yakin Anda Akan Menghapus?"),
//       actions: [
//         cancelButton,
//         continueButton,
//       ],
//     );

//     // show the dialog
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return alert;
//       },
//     );
//   }

//   var fillDisc;
//   // Container discount() {
//   //   if (countDisc != 0) {
//   //     return Container(
//   //       padding: EdgeInsets.only(top: 8, left: 9),
//   //       child: Text(countDisc.toString(), style: TextStyle(fontSize: 13)),
//   //     );
//   //   } else {
//   //     return Container(
//   //       padding: EdgeInsets.only(top: 8, left: 9),
//   //       child: Text(""),
//   //     );
//   //   }
//   // }
//   TransaksiDetailPembelianModel? course;
//   Container content() {
//     return Container(
//       child: ListView.builder(
//         itemCount: DetailTrans.length,
//         shrinkWrap: true,
//         physics: NeverScrollableScrollPhysics(),
//         itemBuilder: (context, index) {
//           // course = TransaksiDetailPembelianModel.fromMap(DetailTrans[index]);

//           Container nilaiDiskon;
//           var idBarang = int.parse(DetailTrans[index]['id_barang'].toString());
//           if (DetailTrans[index]['diskon'] != 0) {
//             fillDisc = Container(
//               padding: EdgeInsets.only(top: 8, left: 9),
//               child: Text("Diskon", style: TextStyle(fontSize: 13)),
//             );

//             nilaiDiskon = Container(
//               padding: EdgeInsets.only(top: 26, left: 9),
//               child: Text("- ${DetailTrans[index]['diskon']}",
//                   style: TextStyle(fontSize: 13)),
//             );
//           } else {
//             fillDisc = Container(
//               padding: EdgeInsets.only(top: 8, left: 9),
//               child: Text(""),
//             );

//             nilaiDiskon = Container(
//               padding: EdgeInsets.only(top: 8, left: 9),
//               child: Text(""),
//             );
//           }
//           // }

//           return GestureDetector(
//             onTap: () {
//               // Navigator.push(
//               //     context,
//               //     new MaterialPageRoute(
//               //         builder: (context) => EditProduk(
//               //               produkModel: course,
//               //             )));
//             },
//             onLongPress: () {
//               showAlertDialog(context, idBarang);
//             },
//             child: Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(5),
//                 // color: Colors.white,
//               ),
//               height: 80,
//               width: double.infinity,
//               child: Material(
//                 elevation: 4.0,
//                 borderRadius: BorderRadius.circular(5.0),
//                 color: index % 2 == 0
//                     ? Colors.white
//                     : Color.fromARGB(255, 226, 232, 230),
//                 child: Center(
//                   child: Row(
//                     //    mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Column(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Container(
//                             padding: EdgeInsets.only(top: 9, left: 9),
//                             child: Text(DetailTrans[index]['kode'].toString(),
//                                 style: TextStyle(
//                                     fontSize: 15,
//                                     color: Colors.black,
//                                     fontWeight: FontWeight.bold)),
//                           ),
//                           Container(
//                             padding: EdgeInsets.only(top: 8, left: 9),
//                             child: Text(
//                                 DetailTrans[index]['nama_barang'].toString(),
//                                 style: TextStyle(fontSize: 13)),
//                           ),
//                           fillDisc,
//                         ],
//                       ),
//                       Spacer(),
//                       Container(
//                           padding: EdgeInsets.only(top: 15, right: 10),
//                           child: Column(
//                             children: [
//                               Row(
//                                 children: [
//                                   Container(
//                                     child: Text(
//                                         "${DetailTrans[index]['qty']} x ${oCcy.format(int.parse(DetailTrans[index]['harga_jual'].toString()))}",
//                                         style: TextStyle(fontSize: 13)),
//                                   )
//                                 ],
//                               ),
//                               nilaiDiskon,
//                             ],
//                           )),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Container header() {
//     //var currentDate = DateTime.parse(widget.tanggal.toString());

//     // var currentDate = DateFormat('dd-MM-yyyy').format(current);
//     String tot;
//     if (count != null) {
//       tot = oCcy.format(count ?? "");
//     } else {
//       tot = "";
//     }
//     return Container(
//       child: Material(
//         elevation: 4.0,
//         // borderRadius: BorderRadius.circular(5.0),
//         //  color: Color.fromARGB(255, 42, 87, 129),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               //color: Color.fromARGB(255, 42, 87, 129),
//               decoration: BoxDecoration(
//                 color: Color.fromARGB(255, 42, 87, 129),
//               ),
//               height: 30,
//               width: double.infinity,
//               //color: Color.fromARGB(255, 42, 87, 129),
//               child: Row(
//                 children: [
//                   Container(
//                     padding: EdgeInsets.only(left: 9),
//                     child: Text(widget.tanggal,
//                         style: TextStyle(color: Colors.white, fontSize: 15)),
//                   ),
//                   // Container(),
//                 ],
//               ),
//             ),
//             Container(
//               decoration: BoxDecoration(
//                 color: Colors.black,
//               ),
//               height: 40,
//               child: Row(
//                 children: [
//                   Container(
//                     margin: EdgeInsets.only(left: 10),
//                     child: Text(
//                       "IDR",
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                   Spacer(),
//                   Container(
//                     padding: EdgeInsets.only(right: 9),
//                     child: Text(tot,
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold)),
//                   ),
//                 ],
//               ),
//             ),
//             GestureDetector(
//               child: Container(
//                 decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   stops: const [0.1, 0.9],
//                   colors: const [
//                     Color.fromARGB(255, 228, 221, 221),
//                     Color.fromARGB(255, 107, 100, 100),
//                   ],
//                 )
//                     //  color: Colors.black,
//                     ),
//                 height: 50,
//                 child: Row(
//                   children: [
//                     Container(
//                       width: 50,
//                       height: 50,
//                       margin: EdgeInsets.only(left: 20),
//                       decoration: BoxDecoration(
//                         image: DecorationImage(
//                           image: AssetImage('images/troly2.png'),
//                           fit: BoxFit.fill,
//                         ),
//                         //shape: BoxShape.circle,
//                       ),
//                     ),
//                     //Spacer(),
//                     Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Container(
//                           margin: EdgeInsets.only(left: 20),
//                           child: Text("Tambah Barang",
//                               style: TextStyle(
//                                   color: Colors.blue,
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold)),
//                         ),
//                         Container(
//                           margin: EdgeInsets.only(left: 20),
//                           child: Text("Pilih Barang Yang Dikembalikan",
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 15,
//                               )),
//                         ),
//                       ],
//                     )
//                   ],
//                 ),
//               ),
//               onTap: () {
//                 showDialogWithFields();
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _refreshDetailPembelian() async {
//     if (helper != null) {
//       helper!.showPembelian().then((product) {
//         setState(() {
//           allDetailTrans = product;
//           DetailTrans = allDetailTrans;
//           //_isLoading = false;
//         });
//       });
//     }
//   }

//   void _refreshProduk() async {
//     if (helper != null) {
//       helper!.allProduk().then((product) {
//         setState(() {
//           allProduk = product;
//           items = allProduk;
//           _isLoading = false;
//         });
//       });
//     }
//   }

//   void showDialogWithFields() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           content: StatefulBuilder(
//             // You need this, notice the parameters below:
//             builder: (BuildContext context, StateSetter setState) {
//               return Column(
//                 children: [
//                   Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(5),
//                       //Color.fromARGB(1, 41, 87, 129),
//                     ),
//                     height: 130,
//                     width: double.infinity,
//                     child: Material(
//                       elevation: 4.0,
//                       borderRadius: BorderRadius.circular(5.0),
//                       color: Color.fromARGB(255, 42, 87, 129),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Container(
//                                   margin: EdgeInsets.only(left: 10, top: 10),
//                                   padding: EdgeInsets.symmetric(
//                                       horizontal: 10, vertical: 5),
//                                   width: 200,
//                                   decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       borderRadius: BorderRadius.circular(10)),
//                                   child: DropdownButtonHideUnderline(
//                                     child: DropdownButton(
//                                       icon: Icon(Icons.arrow_drop_down),
//                                       iconSize: 30,
//                                       underline: SizedBox(),
//                                       items: Katitems.map((item) {
//                                         return DropdownMenuItem(
//                                           value: item['id'].toString(),
//                                           child: Text(item['nama_kategori']),
//                                         );
//                                       }).toList(),
//                                       hint: Text(
//                                         "Please choose a Kategori",
//                                         textAlign: TextAlign.start,
//                                         style: TextStyle(
//                                             color: Colors.black,
//                                             fontSize: 10,
//                                             fontWeight: FontWeight.bold),
//                                       ),
//                                       onChanged: (String? newVal) {
//                                         setState(() {
//                                           _mySelection = newVal!;
//                                           _dropdownError = null;
//                                           var id = int.parse(
//                                               _mySelection.toString());
//                                           _cariKat(id);

//                                           //print(newVal);
//                                           //  this._getNames(newVal);
//                                         });
//                                       },
//                                       value: _mySelection,
//                                     ),
//                                   )),
//                               _dropdownError == null
//                                   ? SizedBox.shrink()
//                                   : Text(
//                                       _dropdownError ?? "",
//                                       style: TextStyle(color: Colors.red),
//                                     ),
//                             ],
//                           ),
//                           Container(
//                             margin:
//                                 EdgeInsets.only(left: 10, top: 10, right: 10),
//                             //  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                             width: 340,
//                             height: 40,
//                             decoration: BoxDecoration(
//                                 color: Colors.grey,
//                                 borderRadius: BorderRadius.circular(10)),
//                             child: TextFormField(
//                               style: TextStyle(color: Color(0xFF000000)),
//                               cursorColor: Color(0xFF9b9b9b),
//                               keyboardType: TextInputType.text,
//                               controller: teSeach,
//                               onChanged: (value) {
//                                 setState(() {
//                                   filterSeach(value);
//                                 });
//                               },
//                               decoration: InputDecoration(
//                                 fillColor: Colors.grey,
//                                 prefixIcon: Icon(
//                                   Icons.search,
//                                   color: Colors.white,
//                                 ),
//                                 hintText: "Pencarian",
//                                 enabledBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(5.0),
//                                   borderSide: BorderSide(
//                                     color: Colors.white,
//                                     width: 2.0,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                   _buildList(),

//                   //
//                 ],
//               );

//               //   return Text(teSeach.text);
//             },
//           ),
//         );
//       },
//     );
//   }

//   var afterDisc;
//   void hitungDiskon(String query) async {
//     if (query.isNotEmpty) {
//       var price = int.parse(harga.text);
//       int disc = int.parse(diskon.text);
//       afterDisc = (disc * price) / 100;
//       var input = price - afterDisc;
//       var jml = int.parse(plusMinus.text);

//       setState(() {
//         hasilDiskon = int.parse(input.toStringAsFixed(0));
//         afterDisc;
//         var total = hasilDiskon * jml;
//         priceAfterDiscount =
//             TextEditingController(text: hasilDiskon.toString());
//         subTotal = TextEditingController(text: total.toString());

//         //  print(jml);
//       });

//       return;
//     } else {
//       setState(() {
//         items = [];
//         items = allProduk;
//       });
//     }
//   }

//   var hasilJumlah;
//   void hitungJumlahHarga(String query) async {
//     if (query.isNotEmpty) {
//       var jumlah = int.parse(plusMinus.text);
//       var price = int.parse(harga.text);

//       setState(() {
//         hasilJumlah = jumlah * price;

//         subTotal = TextEditingController(text: hasilJumlah.toString());
//       });

//       return;
//     } else {
//       setState(() {
//         items = [];
//         items = allProduk;
//       });
//     }
//   }

//   void showDialogWithCount(items) {
//     harga = TextEditingController(text: items['harga_jual'].toString());

//     subTotal = TextEditingController(text: items['harga_jual'].toString());

//     var idBarang = items['id'];
//     var disc;
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           content: StatefulBuilder(
//             // You need this, notice the parameters below:
//             builder: (BuildContext context, StateSetter setState) {
//               return SingleChildScrollView(
//                 //  color: Color.fromARGB(255, 226, 222, 222),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                       margin: EdgeInsets.only(),
//                       child: Text(items['nama_barang'].toString(),
//                           style: TextStyle(
//                               fontSize: 15,
//                               color: Colors.blue,
//                               fontWeight: FontWeight.bold)),
//                     ),
//                     Container(
//                       child: Divider(
//                         color: Color.fromARGB(255, 3, 87, 156),
//                         thickness: 3,
//                         indent: 0,
//                         endIndent: 0,
//                       ),
//                     ),
//                     Container(
//                       child: Text("Jumlah Barang",
//                           style: TextStyle(
//                             fontSize: 15,
//                             color: Colors.blue,
//                           )),
//                     ),
//                     Row(
//                       // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         GestureDetector(
//                           onTap: () {
//                             _sink.add(++initValue);

//                             // ignore: unused_local_variable
//                             var hasilTambah = initValue *
//                                 int.parse(items['harga_jual'].toString());

//                             int output;
//                             if (diskon.text != "") {
//                               output = initValue * hasilDiskon;
//                               hasilTambah = output;
//                             }

//                             // print("hasilllll $hasil");
//                             setState(() {
//                               subTotal = TextEditingController(
//                                   text: hasilTambah.toString());
//                             });
//                           },
//                           child: Container(
//                             child: const Image(
//                               image: AssetImage('images/plus.png'),
//                               width: 40,
//                               height: 40,
//                             ),
//                           ),
//                         ),
//                         SizedBox(
//                           width: 50,
//                           height: 40,
//                           child: TextField(
//                             style: TextStyle(color: Color(0xFF000000)),
//                             cursorColor: Color(0xFF9b9b9b),
//                             keyboardType: TextInputType.text,
//                             controller: plusMinus,
//                             onChanged: (value) {
//                               setState(() {
//                                 hitungJumlahHarga(value);
//                               });
//                             },
//                             decoration: InputDecoration(
//                               fillColor: Colors.grey,

//                               //  hintText: "Pencarian",
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(5.0),
//                                 borderSide: BorderSide(
//                                   color: Colors.white,
//                                   width: 2.0,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         GestureDetector(
//                           onTap: () {
//                             _sink.add(--initValue);

//                             var hasilKurang = initValue *
//                                 int.parse(items['harga_jual'].toString());
//                             int output;
//                             if (diskon.text != "") {
//                               output = initValue * hasilDiskon;
//                               hasilKurang = output;
//                             }
//                             setState(() {
//                               subTotal = TextEditingController(
//                                   text: hasilKurang.toString());
//                             });
//                           },
//                           child: Container(
//                             child: const Image(
//                               image: AssetImage('images/minus.png'),
//                               width: 40,
//                               height: 40,
//                             ),
//                           ),
//                         )
//                       ],
//                     ),
//                     Container(
//                       margin: EdgeInsets.only(top: 10),
//                       child: Text("Price",
//                           style: TextStyle(
//                             fontSize: 15,
//                             color: Colors.blue,
//                           )),
//                     ),
//                     Container(
//                       margin: EdgeInsets.only(top: 5),
//                       child: TextField(
//                         style: TextStyle(color: Color(0xFF000000)),
//                         cursorColor: Color(0xFF9b9b9b),
//                         keyboardType: TextInputType.text,
//                         controller: harga,
//                         decoration: InputDecoration(
//                           fillColor: Color.fromARGB(255, 204, 201, 201),
//                           filled: true,
//                           //  hintText: "Pencarian",
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(5.0),
//                             borderSide: BorderSide(
//                               color: Color.fromARGB(255, 5, 81, 143),
//                               width: 2.0,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Container(
//                       margin: EdgeInsets.only(top: 10),
//                       child: Text("Diskon(%)",
//                           style: TextStyle(
//                             fontSize: 15,
//                             color: Colors.blue,
//                           )),
//                     ),
//                     Container(
//                       margin: EdgeInsets.only(top: 5),
//                       child: TextField(
//                         style: TextStyle(color: Color(0xFF000000)),
//                         cursorColor: Color(0xFF9b9b9b),
//                         keyboardType: TextInputType.text,
//                         controller: diskon,
//                         onChanged: (value) {
//                           setState(() {
//                             hitungDiskon(value);
//                           });
//                         },
//                         decoration: InputDecoration(
//                           fillColor: Color.fromARGB(255, 255, 255, 255),
//                           filled: true,
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(5.0),
//                             borderSide: BorderSide(
//                               color: Color.fromARGB(255, 5, 81, 143),
//                               width: 2.0,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Container(
//                       margin: EdgeInsets.only(top: 10),
//                       child: Text("Harga Setelah Di Diskon",
//                           style: TextStyle(
//                             fontSize: 15,
//                             color: Colors.blue,
//                           )),
//                     ),
//                     Container(
//                       child: TextField(
//                         style: TextStyle(color: Color(0xFF000000)),
//                         cursorColor: Color(0xFF9b9b9b),
//                         keyboardType: TextInputType.text,
//                         controller: priceAfterDiscount,
//                         decoration: InputDecoration(
//                           fillColor: Color.fromARGB(255, 255, 255, 255),
//                           filled: true,
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(5.0),
//                             borderSide: BorderSide(
//                               color: Color.fromARGB(255, 5, 81, 143),
//                               width: 2.0,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Container(
//                       margin: EdgeInsets.only(top: 10),
//                       child: Text("Sub Total",
//                           style: TextStyle(
//                             fontSize: 15,
//                             color: Colors.blue,
//                           )),
//                     ),
//                     Container(
//                       child: TextField(
//                         style: TextStyle(color: Color(0xFF000000)),
//                         cursorColor: Color(0xFF9b9b9b),
//                         keyboardType: TextInputType.text,
//                         controller: subTotal,
//                         decoration: InputDecoration(
//                           fillColor: Color.fromARGB(255, 255, 255, 255),
//                           filled: true,
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(5.0),
//                             borderSide: BorderSide(
//                               color: Color.fromARGB(255, 5, 81, 143),
//                               width: 2.0,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Container(
//                       margin: EdgeInsets.only(top: 5),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           SizedBox(
//                               width: 110,
//                               child: FloatingActionButton.extended(
//                                 backgroundColor:
//                                     Color.fromARGB(255, 95, 151, 236),
//                                 label: Text(
//                                   'Simpan',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                                 onPressed: () async {
//                                   var jml = int.parse(plusMinus.text);
//                                   var harga = int.parse(subTotal.text);
//                                   if (afterDisc != null) {
//                                     disc = (afterDisc.round());
//                                   } else {
//                                     disc = 0;
//                                   }
//                                   //    var status = 1;

//                                   TransaksiDetailPembelianModel course =
//                                       TransaksiDetailPembelianModel({
//                                     'id_barang': idBarang,
//                                     'qty': jml,
//                                     'harga': -harga,
//                                     'status': 1,
//                                     'diskon': disc,
//                                   });
//                                   await helper!
//                                       .createDetailTransaksiPembelian(course);

//                                   refreshJumlahPembelian();

//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                         builder: (context) => TransPengembalian(
//                                               tanggal: widget.tanggal,
//                                             )),
//                                   );
//                                 },
//                               )),
//                           SizedBox(
//                               width: 110,
//                               child: FloatingActionButton.extended(
//                                   backgroundColor:
//                                       Color.fromARGB(255, 95, 151, 236),
//                                   label: Text(
//                                     'Batal',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                   onPressed: () async {})),
//                         ],
//                       ),
//                     )
//                   ],
//                 ),
//               );

//               //   return Text(teSeach.text);
//             },
//           ),
//         );
//       },
//     );
//   }

//   void refreshKategori() {
//     if (helper != null) {
//       helper!.allCategori().then((courses) {
//         setState(() {
//           allKategori = courses;
//           Katitems = allKategori;
//           _isLoading = false;
//         });
//       });
//     }
//   }

//   void _refreshProdukCari(id) async {
//     if (helper != null) {
//       helper!.cariKategori(id).then((product) {
//         setState(() {
//           allProduk = product;
//           items = allProduk;
//         });
//       });
//     }
//   }

//   void _cariKat(int id) async {
//     await helper!.cariKategori(id);

//     _refreshProdukCari(id);
//   }

//   void filterSeach(String query) async {
//     var dummySearchList = allProduk;
//     if (query.isNotEmpty) {
//       var dummyListData = [];
//       for (var item in dummySearchList) {
//         var course = ProdukModel.fromMap(item);
//         if (course.namaBarang!.toLowerCase().contains(query.toLowerCase())) {
//           dummyListData.add(item);
//         }
//       }
//       setState(() {
//         items = [];
//         items.addAll(dummyListData);
//       });

//       return;
//     } else {
//       setState(() {
//         items = [];
//         items = allProduk;
//       });
//     }
//   }

//   Expanded _buildList() {
//     // print("seleksiii $items");

//     return Expanded(
//       child: ListView.builder(
//         itemCount: items.length,
//         shrinkWrap: true,
//         physics: NeverScrollableScrollPhysics(),
//         itemBuilder: (context, index) {
//           // ProdukModel? course = ProdukModel.fromMap(items[index]);
//           return GestureDetector(
//             onTap: () {
//               Navigator.pop(context);
//               showDialogWithCount(items[index]);
//             },
//             child: Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(5),
//                 // color: Colors.white,
//               ),
//               height: 60,
//               width: double.infinity,
//               child: Material(
//                 elevation: 4.0,
//                 borderRadius: BorderRadius.circular(5.0),
//                 color: index % 2 == 0
//                     ? Colors.white
//                     : Color.fromARGB(255, 226, 232, 230),
//                 child: Center(
//                   child: Row(
//                     //    mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Column(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Container(
//                             padding: EdgeInsets.only(top: 9, left: 9),
//                             child: Text(
//                                 "${items[index]['kode']} (${items[index]['stok']})",
//                                 style: TextStyle(
//                                     fontSize: 15, color: Colors.blue)),
//                           ),
//                           Container(
//                             padding: EdgeInsets.only(top: 15, left: 9),
//                             child: Text(items[index]['nama_barang'].toString(),
//                                 style: TextStyle(fontSize: 13)),
//                           ),
//                         ],
//                       ),
//                       Spacer(),
//                       Container(
//                         padding: EdgeInsets.only(top: 15, right: 10),
//                         child: Text("IDR ${items[index]['harga_jual']}",
//                             style: TextStyle(fontSize: 13)),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
