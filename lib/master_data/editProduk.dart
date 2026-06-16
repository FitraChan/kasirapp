import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:flutter/services.dart';
//import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:kasirapp/model/produkModel.dart';
import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:kasirapp/master_data/produk.dart';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';

//import 'package:kasirapp/master_data/tambahKategori.dart';

import 'package:kasirapp/network_utils/api.dart';

import 'package:flutter_image_compress/flutter_image_compress.dart';

class EditProduk extends StatefulWidget {
  @override
  ProdukModel produkModel;
  EditProduk({Key? key, required this.produkModel}) : super(key: key);
  _EditProdukState createState() => _EditProdukState();
}

class _EditProdukState extends State<EditProduk> {
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
  String _selectedValue = "";

  var getKode;
  bool _showItemBuilder = true;
  String? idKategori;
  String? gambar;

  @override
  void initState() {
    super.initState();
    helper = KasirHelper();
    // hargaGoFood.text = '0';
    // hargaShopeeFood.text = '0';

    _searchController.addListener(_loadItems);
    _selectedValue = widget.produkModel.idKategori.toString();
    gambar = widget.produkModel.gambar.toString();

    namaBarang.text = widget.produkModel.namaBarang!;
    hargaJual =
        TextEditingController(text: widget.produkModel.hargaJual.toString());
    // hargaGrosir =
    //     TextEditingController(text: widget.produkModel.hargaGrosir.toString());
    hargaBeli =
        TextEditingController(text: widget.produkModel.hargaBeli.toString());
    stok = TextEditingController(text: widget.produkModel.stok.toString());
    // satuan.text = widget.produkModel.satuan!;

    hargaGoFood =
        TextEditingController(text: widget.produkModel.hargaGoFood.toString());

    keterangan =
        TextEditingController(text: widget.produkModel.keterangan.toString());
    hargaShopeeFood = TextEditingController(
        text: widget.produkModel.hargaShopeeFood.toString());

    kodeBarang.text = widget.produkModel.kode!;
    idKategori = widget.produkModel.idKategori.toString();

    //idController = widget.produkModel.id!;

    scan = TextEditingController(text: _scanBarcode);
    helper = KasirHelper();
    helper!.allCategori().then((courses) {
      setState(() {
        allKategori = courses;
        Katitems = allKategori;
        //_isLoading = false;
      });
    });
  }

  List<Item> _suggestions = [];

  void _loadItems() async {
    _showItemBuilder = true;
    final query = _searchController.text.toLowerCase();

    // print(query);
    final db = KasirHelper.db;
    // final result = await db!.rawQuery(
    //     "SELECT * FROM tb_kategori where nama_kategori LIKE '%$query%'"

    //     );

    final result = await db!.rawQuery(
        'SELECT * FROM tb_kategori where nama_kategori LIKE  ?', ['%$query%']);
    // }

    setState(() {
      _suggestions = result
          .map((e) =>
              Item(id: e['id'] as int, name: e['nama_kategori'].toString()))
          .toList();
    });

    _autoCompleteTextField?.updateSuggestions(_suggestions);
  }

  simpan() async {
    var hargaBeliParse = int.tryParse(hargaBeli.text ?? '') ?? 0;
    //var hargaGrosirParse = int.parse(hargaGrosir.text);
    var hargaJualParse = int.tryParse(hargaJual.text ?? '') ?? 0;
    var idKat = int.parse(_mySelection.toString());
    var idProduk = int.parse(widget.produkModel.id.toString());
    var stoks = int.parse(stok.text);

    var hargaGoFoodParse = int.tryParse(hargaGoFood.text ?? '') ?? 0;
    var hargaShoopeFoodParse = int.tryParse(hargaShopeeFood.text ?? '') ?? 0;
    String? imgString;
    if (gambar != 'null' && imageFile == null) {
      imgString = gambar.toString();
    } else if (imageFile != null) {
      imgString = UtilityEdit.base64String(imageFile!.readAsBytesSync());
    } else {
      imgString = null;
    }

    var date = DateTime.parse(DateTime.now().toString());

    var tanggalNow = DateFormat('yyyy-MM-dd HH:mm').format(date);
    ProdukModel course = ProdukModel({
      'nama_barang': namaBarang.text,
      'kode': kodeOrScan.text,
      'harga_jual': hargaJualParse ?? 0,
      //'harga_grosir': hargaGrosirParse,
      'harga_beli': hargaBeliParse ?? 0,
      'harga_shopee_food': hargaShoopeFoodParse ?? 0,
      'harga_go_food': hargaGoFoodParse ?? 0,
      // 'satuan': satuan.text,
      'id_kategori': idKat,
      'stok': stoks,
      'id': idProduk,
      'gambar': imgString,
      'tanggal_sekarang': tanggalNow,
      'keterangan': keterangan.text,
    });

    //   int id = await helper!.createProduk(course);
    int id = await helper!.updateProduk(course);

    //Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const Produk(
                title: '',
                tambah: 0,
              )),
    );
    sendToMysql(
        id,
        namaBarang.text,
        kodeOrScan.text,
        idKat,
        hargaBeliParse,
        // hargaGrosirParse,
        hargaJualParse,
        // satuan.text,
        stoks,
        // imgString,
        tanggalNow,
        hargaGoFoodParse,
        hargaShoopeFoodParse,
        imgString,
        keterangan.text);
  }

  String? base64Image;
  String? imagePath;
  void sendToMysql(id, nama, kode, idKat, beli, jual, stoks, tanggal,
      hargaGoFood, hargaShoopeFood, pict, keterangan) async {
    Map data;

    if (imageFile != null) {
      String fileName = imageFile!.path.split('/').last;

      base64Image = base64Encode(imageFile!.readAsBytesSync());

      data = {
        'id': id.toString(),
        'nama_barang': nama,
        'kode': kode,
        'id_kategori': idKat,
        'harga_beli': beli,
        // 'harga_grosir': grosir,
        'harga_jual': jual,
        //'satuan': satuan,
        'stok': stoks,
        'shopee_food': hargaShopeeFood.text,
        'go_food': hargaGoFood,
        'created_at': tanggal,
        'base': base64Image,
        'image': fileName,
        'keterangan': keterangan,
      };
    } else {
      data = {
        'id': id.toString(),
        'nama_barang': nama,
        'kode': kode,
        'id_kategori': idKat,
        'harga_beli': beli,
        // 'harga_grosir': grosir,
        'harga_jual': jual,
        //'satuan': satuan,
        'stok': stoks,
        'shopee_food': hargaShopeeFood.text,
        'go_food': hargaGoFood,
        'created_at': tanggal,
        // 'base': base64Image,

        'keterangan': keterangan,
      };
    }

    String url;

    url = 'add_produk_mobile';

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

  final picker = ImagePicker();

  Future getImage(ImageSource media) async {
    final img =
        await picker.pickImage(source: media, maxHeight: 1024, maxWidth: 1024);
    setState(() {
      imageFile = File(img!.path);
    });
  }

  Container editProd() {
    // _scanBarcode

    if (_scanBarcode != "") {
      kodeOrScan = scan;
    } else {
      kodeOrScan = kodeBarang;
    }

    if (idKategori != null && _mySelection == null) {
      _mySelection = idKategori;
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
                margin: const EdgeInsets.only(top: 8),
                child: Row(children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    width: 260,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.grey, // Warna border
                        width: 1.0, // Ketebalan border
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        icon: const Icon(Icons.arrow_drop_down),
                        iconSize: 30,
                        items: Katitems.map((item) {
                          return DropdownMenuItem<String>(
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
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onChanged: (String? newVal) {
                          setState(() {
                            _mySelection = newVal;
                            _dropdownError = null;
                          });
                        },
                        value: (Katitems.any((item) =>
                                item['id'].toString() == _mySelection))
                            ? _mySelection
                            : null,
                      ),
                    ),
                  ),
                  _dropdownError == null
                      ? const SizedBox.shrink()
                      : Text(
                          _dropdownError ?? "",
                          style: const TextStyle(color: Colors.red),
                        ),
                ]),
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

          _buildTextArea("Keterangan", Icons.book, keterangan),
          const SizedBox(height: 15),
          Container(
            margin: const EdgeInsets.only(top: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(imageFile!.path),
                          height: 100,
                          width: 100,
                        ))
                    : Container(
                        margin: const EdgeInsets.only(top: 10.0, left: 10.0),
                        child: gambar != null
                            ? UtilityEdit.imageFromBase64String(
                                gambar.toString())
                            : Container(
                                width: 50,
                                height: 50,
                                // margin:
                                //     const EdgeInsets.only(top: 15.0, right: 10.0),
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage('images/no_image.png'),
                                    fit: BoxFit.fill,
                                  ),
                                  //shape: BoxShape.circle,
                                ))),
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

  @override
  void dispose() {
    // Membersihkan sumber daya saat widget dihapus
    // myController.dispose();
    _searchController.dispose();
    kodeOrScan.dispose();
    hargaJual.dispose();
    hargaBeli.dispose();
    stok.dispose();
    namaBarang.dispose();

    super.dispose();
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
                        const Text("Edit Produk",
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 30),
                    editProd(),
                    // Form Fields

                    const SizedBox(height: 30),

                    // Sign In Button
                    ElevatedButton(
                      onPressed: () async {
                        simpan();
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
          //maxLength: 13,
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

class UtilityEdit {
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
