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

//import 'package:kasirapp/master_data/tambahKategori.dart';

import 'package:kasirapp/network_utils/api.dart';
import 'package:kasirapp/screen/home.dart';

import '../screen/menu1.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class CobaTambah extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Perfect Shoes',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        fontFamily: 'Roboto',
      ),
      home: ShoeHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ShoeHomePage extends StatefulWidget {
  @override
  _ShoeHomePageState createState() => _ShoeHomePageState();
}

class _ShoeHomePageState extends State<ShoeHomePage> {
  File? imageFile;
  String status = '';
  TextEditingController kodeBarang = TextEditingController();

  TextEditingController scan = TextEditingController();

  TextEditingController kodeOrScan = TextEditingController();

  TextEditingController namaBarang = TextEditingController();
  TextEditingController hargaJual = TextEditingController();
//  TextEditingController hargaGrosir = TextEditingController();
  //String? gambar;
  TextEditingController hargaBeli = TextEditingController();
  TextEditingController stok = TextEditingController();

  TextEditingController hargaGoFood = TextEditingController();
  TextEditingController hargaShopeeFood = TextEditingController();

  TextEditingController keterangan = TextEditingController();
  // TextEditingController satuan = TextEditingController();
  String errMessage = 'Error Uploading Image';
  GlobalKey<AutoCompleteTextFieldState<Item>> key = GlobalKey();
  String? _dropdownError;
  String? _mySelection;
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
  final TextEditingController _searchController = TextEditingController();
  AutoCompleteTextField<Item>? _autoCompleteTextField;

  var getKode;
  bool _showItemBuilder = true;

  @override
  void initState() {
    super.initState();
    helper = KasirHelper();
    // hargaGoFood.text = '0';
    // hargaShopeeFood.text = '0';

    _searchController.addListener(_loadItems);
    _autoCompleteTextField = AutoCompleteTextField<Item>(
      controller: _searchController,
      suggestions: _suggestions,
      clearOnSubmit: false,
      style: const TextStyle(color: Colors.black, fontSize: 15),
      decoration: InputDecoration(
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(20.5))),
      itemFilter: (item, query) =>
          item.name.toLowerCase().contains(query.toLowerCase()),
      itemSorter: (a, b) => a.id.compareTo(b.id),
      itemSubmitted: (item) {
        setState(() {
          _searchController.text = item.name;
          _mySelection = item.id.toString();
          _showItemBuilder = false;
        });
        // Navigator.of(context).pop();
      },
      itemBuilder: (context, item) {
        return _showItemBuilder
            ? Container(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      item.name,
                      style: const TextStyle(color: Colors.black),
                    )
                  ],
                ),
              )
            : Container();
      },
      key: key,
    );

    helper!.idProd().then((product) {
      setState(() {
        items = product;
        idProduk = items.first['id'] + 1;
      });
    });
    helper!.allCategori().then((courses) {
      setState(() {
        allKategori = courses;
        Katitems = allKategori;
        _isLoading = false;
      });
    });
  }

  final dbClient = KasirHelper.db;

  Future<bool> doesDataExist(kode) async {
    final List<Map<String, dynamic>> data = await dbClient!.query(
      'tb_produk',
      where: 'kode = ?',
      whereArgs: [kode],
    );

    return data.isNotEmpty;
  }

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

  void _loadItems() async {
    _showItemBuilder = true;
    final query = _searchController.text.toLowerCase();

    print(query);
    final db = KasirHelper.db;

    final result = await db!.rawQuery(
        'SELECT * FROM tb_kategori where nama_kategori LIKE  ?', ['%$query%']);

    setState(() {
      _suggestions = result
          .map((e) =>
              Item(id: e['id'] as int, name: e['nama_kategori'].toString()))
          .toList();
    });

    _autoCompleteTextField?.updateSuggestions(_suggestions);
  }

  Container tambahProd() {
    kodeBarang =
        TextEditingController(text: (idProduk ?? 1).toString().padLeft(5, '0'));

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
          _buildTextField("Kode Barang", Icons.code, kodeOrScan,
              readOnly: true),
          const SizedBox(height: 15),
          _buildTextField(
              "Nama Barang", Icons.production_quantity_limits, namaBarang),
          const SizedBox(height: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Text("Kategori", style: TextStyle(color: Colors.black)),
              ),
              Container(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _autoCompleteTextField!,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),
          _buildTextFieldAngka(
              "Harga Jual (Normal)", Icons.price_change_rounded, hargaJual),
          const SizedBox(height: 15),
          _buildTextFieldAngka(
              "Harga Go Food", Icons.price_change_rounded, hargaGoFood),
          const SizedBox(height: 15),
          _buildTextFieldAngka(
              "Harga Shopee Food", Icons.price_change_rounded, hargaShopeeFood),
          const SizedBox(height: 15),
          _buildTextFieldAngka(
              "Harga Beli", Icons.price_change_rounded, hargaBeli),
          const SizedBox(height: 15),
          _buildTextFieldNumber("Stok", Icons.production_quantity_limits, stok),
          const SizedBox(height: 15),
          _buildTextArea("Keterangan", Icons.book_online, keterangan),
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
      // maxWidth: maxWidth,
      // maxHeight: maxHeight,
    );

    return result;
  }

  String? base64Image;
  //String? imagePath;

  void sendToMysql(id, nama, kode, idKat, beli, jual, stoks, createdAt, shopee,
      go_food, keterangan) async {
    // imageFile = File(imagePath!);
    try {
      String fileName = imageFile!.path.split('/').last;

      // //Utility.base64String(imageFile!.readAsBytesSync());

      base64Image = base64Encode(imageFile!.readAsBytesSync());
      base64Image = base64Encode(imageFile!.readAsBytesSync());

      Uint8List imageBytes = base64Decode(base64Image!.split(',').last);

      Uint8List resizedImage = await resizeImage(imageBytes, 200, 200);

      String base64ImageResized = base64Encode(resizedImage);

      Map data = {
        'id': id.toString(),
        'nama_barang': nama,
        'kode': kode,
        'id_kategori': idKat,
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
        print('sukses');
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
                        //var hargaGrosirParse = int.parse(hargaGrosir.text);
                        var hargaJualParse = int.parse(hargaJualFormattedValue);

                        var hargaShoopeParse =
                            int.parse(hargaShopeeFormattedValue);

                        var hargaGofoodParse =
                            int.parse(hargaGoFoodFormattedValue);

                        var idKat = int.parse(_mySelection.toString());
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
                          // 'harga_grosir': hargaGrosirParse,
                          'harga_beli': hargaBeliParse ?? 0,
                          //   'satuan': satuan.text,
                          'stok': stoks,
                          'id_kategori': idKat,
                          'gambar': imgString,
                          'tanggal_sekarang': createdAt,
                          'keterangan': keterangan.text,
                        });

                        final bool dataExists =
                            await doesDataExist(kodeOrScan.text);

                        if (dataExists) {
                          Fluttertoast.showToast(
                            msg: "Kode Barang Ada Yang Sama",
                            toastLength: Toast
                                .LENGTH_SHORT, // Duration for which the toast should be visible
                            gravity: ToastGravity
                                .BOTTOM, // Position of the toast on the screen
                            // Font size of the message
                          );

                          return;
                        }
                        await helper!.createProduk(course);
                        // Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Produk(
                                    title: '',
                                    tambah: 0,
                                  )),
                        );
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
                            keterangan.text);
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

  Widget _buildTextField(
    String hint,
    IconData icon,
    TextEditingController? controller, {
    bool obscure = false,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Text(hint, style: TextStyle(color: Colors.black)),
        ),
        TextFormField(
          obscureText: obscure,
          controller: controller,
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.grey.shade100,
          ),
        )
      ],
    );
  }

  Widget _buildTextArea(
    String hint,
    IconData icon,
    TextEditingController? controller, {
    bool obscure = false,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Text(hint, style: TextStyle(color: Colors.black)),
        ),
        TextFormField(
          maxLines: 6,
          obscureText: obscure,
          controller: controller,
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.grey.shade100,
          ),
        )
      ],
    );
  }

  Widget _buildTextFieldAngka(
      String hint, IconData icon, TextEditingController? controller,
      {bool obscure = false}) {
    if (controller == null || controller.text.isEmpty) {
      controller!.text = '0';
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Text(hint, style: TextStyle(color: Colors.black)),
        ),
        TextFormField(
          obscureText: obscure,
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            CurrencyInputFormatter(),
          ],
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.grey.shade100,
          ),
        )
      ],
    );
  }

  Widget _buildTextFieldNumber(
      String hint, IconData icon, TextEditingController? controller,
      {bool obscure = false}) {
    if (controller == null || controller.text.isEmpty) {
      controller!.text = '0';
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Text(hint, style: TextStyle(color: Colors.black)),
        ),
        TextFormField(
          obscureText: obscure,
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.grey.shade100,
          ),
        )
      ],
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
