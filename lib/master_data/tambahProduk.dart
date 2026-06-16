import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:flutter/services.dart';
//import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:kasirapp/model/kategoriModel.dart';
import 'package:kasirapp/model/produkModel.dart';
import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:kasirapp/master_data/produk.dart';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:kasirapp/model/rupiahCurrency.dart';
import 'package:kasirapp/screen/customInput.dart';
import 'package:kasirapp/transaksi/tambahBarangMasuk.dart';

import 'package:kasirapp/network_utils/api.dart';
import 'package:kasirapp/screen/home.dart';
//import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screen/menu1.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class TambahProduk extends StatefulWidget {
  @override
  TambahProduk({Key? key, required this.dariBarangMasuk, this.scannedBarcode})
      : super(key: key);

  final int dariBarangMasuk;
  final String? scannedBarcode;

  _TambahProdukState createState() => _TambahProdukState();
}

class _TambahProdukState extends State<TambahProduk> {
  File? imageFile;
  String status = '';
  TextEditingController kodeBarang = TextEditingController();

  TextEditingController scan = TextEditingController();

  TextEditingController kodeOrScan = TextEditingController();

  TextEditingController namaBarang = TextEditingController();
  TextEditingController hargaJual = TextEditingController();

  TextEditingController hargaBeli = TextEditingController();
  TextEditingController stok = TextEditingController();

  TextEditingController hargaGoFood = TextEditingController();
  TextEditingController hargaShopeeFood = TextEditingController();

  TextEditingController keterangan = TextEditingController();
  // TextEditingController satuan = TextEditingController();
  String errMessage = 'Error Uploading Image';
  GlobalKey<AutoCompleteTextFieldState<Item>> key = GlobalKey();
  String? _dropdownError;

  String? barcodeScanRes;

  KasirHelper? helper;

  List data = [];
  String? email;

  String? namaKategori;
  bool _isLoading = true;
  String _scanBarcode = '';
  var allKategori = [];
  var Katitems = [];
  var items = [];

  var kodes = [];
  var idProduk;

  var idProdukLokal;

  final TextEditingController _searchController = TextEditingController();
  AutoCompleteTextField<Item>? _autoCompleteTextField;

  var getKode;
  bool _showItemBuilder = true;

  @override
  void initState() {
    super.initState();
    helper = KasirHelper();
    loadKategori();
    loadPkac();
    //  _searchController.addListener(_loadItems);
    // _autoCompleteTextField = AutoCompleteTextField<Item>(
    //   controller: _searchController,
    //   suggestions: _suggestions,
    //   clearOnSubmit: false,
    //   style: const TextStyle(color: Colors.black, fontSize: 15),
    //   decoration: InputDecoration(
    //       border:
    //           OutlineInputBorder(borderRadius: BorderRadius.circular(20.5))),
    //   itemFilter: (item, query) =>
    //       item.name.toLowerCase().contains(query.toLowerCase()),
    //   itemSorter: (a, b) => a.id.compareTo(b.id),
    //   itemSubmitted: (item) {
    //     setState(() {
    //       _searchController.text = item.name;
    //       _mySelection = item.id.toString();
    //       _showItemBuilder = false;
    //     });
    //     // Navigator.of(context).pop();
    //   },
    //   itemBuilder: (context, item) {
    //     return _showItemBuilder
    //         ? Container(
    //             padding: const EdgeInsets.all(20.0),
    //             child: Row(
    //               children: <Widget>[
    //                 Text(
    //                   item.name,
    //                   style: const TextStyle(color: Colors.black),
    //                 )
    //               ],
    //             ),
    //           )
    //         : Container();
    //   },
    //   key: key,
    // );

    helper!.idProd().then((product) {
      if (widget.scannedBarcode != null && widget.scannedBarcode!.isNotEmpty) {
        _handleBarcodeResult(widget.scannedBarcode!);
      }
      setState(() {
        items = product;

        final lastId = items.isNotEmpty
            ? int.tryParse(items.first['id'].toString()) ?? 0
            : 0;

        idProdukLokal = (lastId + 1).toString().padLeft(5, '0');
      });
    });

    lastProduk();
    helper!.allCategori().then((courses) {
      setState(() {
        allKategori = courses;
        Katitems = allKategori;
        _isLoading = false;
      });
    });
  }

  final dbClient = KasirHelper.db;

  // Future<bool> doesDataExist(kode) async {
  //   final List<Map<String, dynamic>> data = await dbClient!.query(
  //     'tb_produk',
  //     where: 'kode = ?',
  //     whereArgs: [kode],
  //   );

  //   return data.isNotEmpty;
  // }

  String removeCurrencyFormat(String formattedValue) {
    // Hapus semua karakter yang bukan angka
    String cleanValue = formattedValue.replaceAll(RegExp(r'[^\d]'), '');

    return cleanValue;
  }

  setStatus(String message) {
    setState(() {
      status = message;
    });
  }

  List<Item> _suggestions = [];

  // void _loadItems() async {
  //   _showItemBuilder = true;
  //   final query = _searchController.text.toLowerCase();

  //   print(query);
  //   final db = KasirHelper.db;

  //   final result = await db!.rawQuery(
  //       'SELECT * FROM tb_kategori where nama_kategori LIKE  ?', ['%$query%']);

  //   setState(() {
  //     _suggestions = result
  //         .map((e) =>
  //             Item(id: e['id'] as int, name: e['nama_kategori'].toString()))
  //         .toList();
  //   });

  //   _autoCompleteTextField?.updateSuggestions(_suggestions);
  // }

  Container tambahProd() {
    kodeBarang = TextEditingController(text: (idProduk ?? idProdukLokal));

    scan = TextEditingController(text: _scanBarcode);

    // _scanBarcode

    if (_scanBarcode != "") {
      kodeOrScan = scan;
    } else {
      kodeOrScan = kodeBarang;
    }
    return Container(
      child: Column(
        children: [
          //     String hint, IconData icon, TextEditingController? controller,
          // {bool obscure = false})
          Row(
            children: [
              Expanded(
                child: CustomInput.textField(
                  "Kode Barang",
                  Icons.code,
                  kodeOrScan,
                  readOnly: true,
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: Icon(Icons.qr_code_scanner, color: Colors.blue),
                onPressed: () async {
                  _openBarcodeScanner();
                },
              )
            ],
          ),
          const SizedBox(height: 15),
          CustomInput.textField(
              "Nama Barang", Icons.production_quantity_limits, namaBarang),
          const SizedBox(height: 15),

          kodeToko == '00001' ? buildPkAcDropdown() : buildKategori(),

          const SizedBox(height: 15),
          CustomInput.angka(
              "Harga Jual (Normal)", Icons.price_change_rounded, hargaJual),
          const SizedBox(height: 15),
          CustomInput.angka(
              "Harga Go Food", Icons.price_change_rounded, hargaGoFood),
          const SizedBox(height: 15),
          CustomInput.angka(
              "Harga Shopee Food", Icons.price_change_rounded, hargaShopeeFood),
          const SizedBox(height: 15),
          CustomInput.angka(
              "Harga Beli", Icons.price_change_rounded, hargaBeli),
          const SizedBox(height: 15),
          CustomInput.number("Stok", Icons.production_quantity_limits, stok),
          const SizedBox(height: 15),
          CustomInput.textArea("Keterangan", Icons.book_online, keterangan),
          Container(
            margin: const EdgeInsets.only(top: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          imageFile!,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Text(
                        'Belum ada gambar yang dipilih.',
                        style: TextStyle(fontSize: 14),
                      ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: myAlertImage,
                  icon: const Icon(Icons.upload),
                  label: const Text("Upload Foto",
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _listKategori = [];

  TextEditingController _kategoriController = TextEditingController();

  Future<void> loadKategori() async {
    final dataKategori =
        await helper!.kategori(); // sesuaikan dengan helper kamu
    setState(() {
      _listKategori = List<Map<String, dynamic>>.from(dataKategori);
    });
  }

  List<Map<String, dynamic>> _listPkAc = [];
  int? selectedPkId;
  TextEditingController _pkController = TextEditingController();

  Future<void> loadPkac() async {
    final dataPk =
        await helper!.allPkAutoComplete(); // sesuaikan dengan helper kamu
    setState(() {
      _listPkAc = List<Map<String, dynamic>>.from(dataPk);
    });
  }

  int? selectedKategoriId;

  Widget buildPkAcDropdown() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: selectedPkId != null ? selectedPkId.toString() : null,
        decoration: InputDecoration(
          labelText: "Pk Ac",
          prefixIcon: const Icon(Icons.store),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        items: _listPkAc.map((supplier) {
          return DropdownMenuItem<String>(
            value: supplier['id'].toString(),
            child: Text(supplier['nama']),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedPkId = value != null ? int.parse(value) : null;
          });
        },
      ),
    );
  }

  Widget buildKategori() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value:
            selectedKategoriId != null ? selectedKategoriId.toString() : null,
        decoration: InputDecoration(
          labelText: "Kategori",
          prefixIcon: const Icon(Icons.store),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        items: _listKategori.map((supplier) {
          return DropdownMenuItem<String>(
            value: supplier['id'].toString(),
            child: Text(supplier['nama_kategori']),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedKategoriId = value != null ? int.parse(value) : null;
          });
        },
      ),
    );
  }

  bool _isScanning = false;

  void _openBarcodeScanner() async {
    setState(() {
      _isScanning = true;
    });

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => BarcodeScannerScreen(
    //       onBarcodeDetected: (barcode) {
    //         // Navigator.pop(context, barcode); // Mengembalikan hasil scan
    //       },
    //     ),
    //   ),
    // ).then((barcode) {
    //   if (barcode != null) {
    //     _handleBarcodeResult(barcode);
    //   }
    // });
  }

  var kodeToko;

  void _handleBarcodeResult(String barcode) {
    setState(() {
      _scanBarcode = barcode;
      kodeOrScan.text = barcode;
      _isScanning = false;
    });
  }

  void myAlertImage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: const Text('Pilih Sumber Gambar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  getImage(ImageSource.gallery);
                },
                icon: const Icon(Icons.photo_library),
                label: const Text("Dari Galeri"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  getImage(ImageSource.camera);
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text("Dari Kamera"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  final picker = ImagePicker();

  Future getImage(ImageSource media) async {
    final img =
        await picker.pickImage(source: media, maxHeight: 1024, maxWidth: 1024);
    setState(() {
      imageFile = File(img!.path);
    });
  }

  Future<Uint8List> resizeImage(
      Uint8List imageBytes, int maxWidth, int maxHeight) async {
    Uint8List result = await FlutterImageCompress.compressWithList(
      imageBytes,
      minWidth: maxWidth,
      minHeight: maxHeight,
      quality: 100,
    );

    return result;
  }

  void lastProduk() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    kodeToko = pref.getString('kode_toko');

    final response = await Network().getData_get('lastProduk');
    var c = json.decode(response.body);

    if (response.statusCode == 200) {
      //  print('sukses');
      int number = int.parse(c); // 10
      // idProduk = c + 1;

      setState(() {
        idProduk = (number + 1).toString().padLeft(c.length, '0');
      });
    } else {
      throw Exception('Failed to load album');
    }
  }

  String? base64Image;
  //String? imagePath;

  void sendToMysql(id, nama, kode, idKat, beli, jual, stoks, createdAt, shopee,
      go_food, keterangan, idPk) async {
    try {
      String fileName = imageFile!.path.split('/').last;

      base64Image = base64Encode(imageFile!.readAsBytesSync());

      Uint8List imageBytes = base64Decode(base64Image!.split(',').last);

      Uint8List resizedImage = await resizeImage(imageBytes, 200, 200);

      String base64ImageResized = base64Encode(resizedImage);

      Map data = {
        'id': id.toString(),
        'nama_barang': nama,
        'kode': kode,
        'id_kategori': idKat,
        'id_pk': idPk,
        'harga_beli': beli,
        //'harga_grosir': grosir,
        'harga_jual': jual ?? 0,
        'shopee_food': shopee ?? 0,
        'go_food': go_food ?? 0,
        //'satuan': satuan,
        'stok': stoks,
        'base': base64ImageResized,
        'image': fileName,
        'created_at': createdAt,
        'keterangan': keterangan
      };

      String url;

      url = 'add_produk_mobile';

      // final response = await htpp.post(Uri.parse(url), body: data);
      final response = await Network().getData_post(data, url);
      // var c = json.decode(response.body);

      if (response.statusCode == 200) {
        // print('sukses');
        await helper!.sync(kode, 'kode', 'tb_produk');
      } else {
        print(response.body);
        EasyLoading.show(status: response.body);
      }
    } on Exception catch (exception) {
      // only executed if error is of type Exception

      EasyLoading.showSuccess(exception.toString());
    } catch (error) {
      // EasyLoading.show(status: error.toString());
      EasyLoading.showSuccess(error.toString());
      // executed for errors of all types other than Exception
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(false);
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: Colors.green.shade700,
        body: Column(
          children: [
            const SizedBox(height: 80),
            const Text(
              "ECOMMERCE",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const Text(
              "Store",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                padding: const EdgeInsets.all(20),
                child: ListView(
                  children: [
                    // Tab Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Tambah Produk",
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 30),
                    tambahProd(),
                    // Form Fields

                    const SizedBox(height: 30),

                    // Sign In Button
                    ElevatedButton(
                      onPressed: () async {
                        var date = DateTime.parse(DateTime.now().toString());

                        var tanggalNow =
                            DateFormat('yyyy-MM-dd HH:mm').format(date);
                        String hargaBeliFormattedValue = removeCurrencyFormat(
                            hargaBeli.text); // Mendapatkan nilai dari TextField

                        String hargaJualFormattedValue =
                            removeCurrencyFormat(hargaJual.text);

                        String hargaShopeeFormattedValue =
                            removeCurrencyFormat(hargaShopeeFood.text);

                        String hargaGoFoodFormattedValue =
                            removeCurrencyFormat(hargaGoFood.text);

                        var hargaBeliParse = int.parse(hargaBeliFormattedValue);
                        var hargaJualParse = int.parse(hargaJualFormattedValue);

                        var hargaShoopeParse =
                            int.parse(hargaShopeeFormattedValue);

                        var hargaGofoodParse =
                            int.parse(hargaGoFoodFormattedValue);

                        int? idKat;

                        int? idPk;

                        // var idKategoriFinal =
                        //     kodeToko == '00001' ? idPk : idKat;

                        if (kodeToko == '00001') {
                          idPk =
                              int.tryParse(selectedPkId?.toString() ?? '') ?? 0;
                        } else {
                          idKat = int.tryParse(
                                  selectedKategoriId?.toString() ?? '') ??
                              0;
                        }
                        var stoks = int.parse(stok.text);
                        var createdAt = tanggalNow;
                        String? imgString;
                        if (imageFile != null) {
                          imgString = Utility.base64String(
                              imageFile!.readAsBytesSync());
                        } else {
                          imgString = null;
                        }
                        // Photo photo = Photo(0, imgString);

                        ProdukModel course = ProdukModel({
                          'nama_barang': namaBarang.text,
                          'kode': kodeOrScan.text,
                          'harga_jual': hargaJualParse ?? 0,
                          'harga_shopee_food': hargaShoopeParse ?? 0,
                          'harga_go_food': hargaGofoodParse ?? 0,
                          'harga_beli': hargaBeliParse ?? 0,
                          'stok': stoks,
                          'id_pk': idPk,
                          'id_kategori': idKat,
                          'gambar': imgString,
                          'tanggal_sekarang': createdAt,
                          'keterangan': keterangan.text,
                        });

                        await helper!.createProduk(course);
                        // Navigator.of(context).pop();

                        if (widget.dariBarangMasuk == 1) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const TambahBarangMasuk()),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Produk(
                                      title: '',
                                      tambah: 1,
                                    )),
                          );
                        }
                        sendToMysql(
                            0,
                            namaBarang.text,
                            kodeOrScan.text,
                            idKat,
                            hargaBeliParse,
                            //  hargaGrosirParse,
                            hargaJualParse,
                            //satuan.text,
                            stoks,
                            // imgString,
                            createdAt,
                            hargaShoopeParse,
                            hargaGofoodParse,
                            keterangan.text,
                            idPk);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        "Simpan",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Utility {
  static Image imageFromBase64String(String base64String) {
    return Image.memory(
      base64Decode(base64String),
      fit: BoxFit.fill,
    );
  }

  static Uint8List dataFromBase64String(String base64String) {
    return base64Decode(base64String);
  }

  static String base64String(Uint8List data) {
    return base64Encode(data);
  }
}

class Item {
  final int id;
  final String name;

  Item({required this.id, required this.name});
}

// class BarcodeScannerScreen extends StatefulWidget {
//   final Function(String) onBarcodeDetected;

//   const BarcodeScannerScreen({
//     Key? key,
//     required this.onBarcodeDetected,
//   }) : super(key: key);

//   @override
//   _BarcodeScannerScreenState createState() => _BarcodeScannerScreenState();
// }

// class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
//   MobileScannerController? _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = MobileScannerController(
//       formats: [
//         BarcodeFormat.qrCode,
//         BarcodeFormat.code128,
//         BarcodeFormat.code39,
//         BarcodeFormat.ean13,
//         BarcodeFormat.ean8
//       ],
//     );
//   }

//   @override
//   void dispose() {
//     _controller?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Scan Barcode'),
//         backgroundColor: Colors.black,
//         foregroundColor: Colors.white,
//         leading: IconButton(
//           icon: const Icon(Icons.close),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//       ),
//       body: Stack(
//         children: [
//           // Camera preview
//           if (_controller != null)
//             MobileScanner(
//               controller: _controller!,
//               onDetect: (capture) {
//                 if (!mounted) return;

//                 final List<Barcode> barcodes = capture.barcodes;
//                 if (barcodes.isNotEmpty) {
//                   final barcode = barcodes.first;
//                   if (barcode.rawValue != null) {
//                     widget.onBarcodeDetected(barcode.rawValue!);
//                     // Navigator.of(context).pop();

//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => TambahProduk(
//                                 dariBarangMasuk: 0,
//                                 scannedBarcode: barcode.rawValue,
//                               )),
//                     );
//                   }
//                 }
//               },
//             ),

//           // Overlay untuk area scan
//           Center(
//             child: Container(
//               width: 250,
//               height: 250,
//               decoration: BoxDecoration(
//                 border: Border.all(
//                   color: Colors.white,
//                   width: 3,
//                 ),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//             ),
//           ),

//           // Petunjuk scan
//           const Positioned(
//             bottom: 50,
//             left: 0,
//             right: 0,
//             child: Text(
//               'Arahkan kamera ke barcode untuk scan',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
