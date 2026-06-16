import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
//import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:kasirapp/master_data/tambahProduk.dart';
import 'package:kasirapp/model/penerimaanModel.dart';
import 'package:kasirapp/helpers/dbkasir.dart';

import 'package:kasirapp/model/rupiahCurrency.dart';

//import 'package:kasirapp/master_data/tambahKategori.dart';

import 'package:kasirapp/network_utils/api.dart';
import 'package:kasirapp/screen/customInput.dart';
import 'package:kasirapp/screen/home.dart';
import 'package:kasirapp/sync/syncServicePkAc.dart';
import 'package:kasirapp/sync/syncServiceSupplier.dart';
import 'package:kasirapp/transaksi/barangMasuk.dart';
import 'package:kasirapp/transaksi/penerimaan.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screen/menu1.dart';

//import 'package:firebase_messaging/firebase_messaging.dart';

class TambahBarangMasuk extends StatefulWidget {
  final String? scannedBarcode;
  const TambahBarangMasuk({Key? key, this.scannedBarcode}) : super(key: key);
  @override
  _TambahBarangMasukState createState() => _TambahBarangMasukState();
}

class _TambahBarangMasukState extends State<TambahBarangMasuk> {
  //MobileScannerController? _cameraController;
  final _noTransaksiController = TextEditingController();
  final _tanggalController = TextEditingController();
  final _qtyController = TextEditingController();
  final _hargaController = TextEditingController();
  final _keteranganController = TextEditingController();
  TextEditingController kodeBarang = TextEditingController();
  TextEditingController namaBarang = TextEditingController();
  TextEditingController hargaJual = TextEditingController();
  TextEditingController hargaBeli = TextEditingController();
  TextEditingController stok = TextEditingController();

  final syncServicePkAc = SyncServicePkAc();

  final syncServiceSupplier = SyncServiceSupplier();

  KasirHelper? helper;
  bool _isLoading = false;
  bool _isScanning = false;
  // File? imageFile;

  var kodes = [];

  var current;
  var currentString;

  @override
  void initState() {
    super.initState();
    helper = KasirHelper();
    _loadSupplier();

    initAll(); // Panggil fungsi initAll untuk inisialisasi data dan load produk

    lastProduk();

    // Cek apakah ada barcode yang di scan dari halaman sebelumnya
  }

  var kodeToko;
  Future<void> _initData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    await syncServiceSupplier.syncSupplier();

    setState(() {
      kodeToko = pref.getString('kode_toko');
    });

    // toko ac
    if (kodeToko == '00001') {
      await syncServicePkAc.syncPkAc();
      loadPkac();
    } else {
      _loadKategori();
    }
  }

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

  // Fungsi untuk menangani hasil scan barcode
  void _handleBarcodeResult(String barcode) {
    // Cari produk berdasarkan barcode
    final produk = _listProduk.firstWhere(
      (p) =>
          p['kode'].toString() == barcode || p['barcode'].toString() == barcode,
      orElse: () => {},
    );

    if (produk.isNotEmpty) {
      setState(() {
        selectedProdukId = produk['id'];

        if (kodeToko == '00001') {
          selectedPkId = produk['id_pk'] != null
              ? int.tryParse(produk['id_pk'].toString())
              : null;
        }
        _produkController.text = produk['nama_barang'];
        if (produk['harga_beli'] != null) {
          String hargaBeli = produk['harga_beli'].toString();
          final formatter = NumberFormat.currency(
            locale: 'id_ID',
            symbol: 'Rp ',
            decimalDigits: 0,
          );
          _hargaController.text = formatter.format(int.parse(hargaBeli));
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Produk ditemukan: ${produk['nama_barang']}'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Produk dengan barcode $barcode tidak ditemukan'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  final dbClient = KasirHelper.db;

  String removeCurrencyFormat(String formattedValue) {
    // Hapus semua karakter yang bukan angka
    String cleanValue = formattedValue.replaceAll(RegExp(r'[^\d]'), '');

    return cleanValue;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop(false);
          return Future.value(true);
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Tambah Barang Masuk',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.home, color: Colors.black),
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
          ),
          //  drawer: const Menu(),
          backgroundColor: Colors.grey[300],
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 8,
              shadowColor: Colors.grey.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: tambahProd(),
              ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(20),
            child: GestureDetector(
              onTap: simpanData,
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFB71C1C),
                      Color(0xFFD32F2F),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: _isLoading
                      ? const Text("Please wait...",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ))
                      : const Text(
                          "SIMPAN DATA",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ),
          // floatingActionButton: FloatingActionButton(
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //           builder: (context) => TambahProduk(
          //                 dariBarangMasuk: 1,
          //               )),
          //     );
          //   },
          //   backgroundColor: Colors.blue,
          //   child: const Icon(
          //     Icons.add,
          //     color: Colors.white,
          //   ),
          // ),

          // Tombol scan barcode
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: FloatingActionButton(
            onPressed: _openBarcodeScanner,
            backgroundColor: Colors.green,
            child: const Icon(
              Icons.qr_code_scanner,
              color: Colors.white,
            ),
          ),
        ));
  }

  // void myAlertImage() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  //         title: const Text('Pilih Sumber Gambar'),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: <Widget>[
  //             ElevatedButton.icon(
  //               onPressed: () {
  //                 Navigator.pop(context);
  //                 getImage(ImageSource.gallery);
  //               },
  //               icon: const Icon(Icons.photo_library),
  //               label: const Text("Dari Galeri"),
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: Colors.green,
  //                 shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(8)),
  //               ),
  //             ),
  //             const SizedBox(height: 10),
  //             ElevatedButton.icon(
  //               onPressed: () {
  //                 Navigator.pop(context);
  //                 getImage(ImageSource.camera);
  //               },
  //               icon: const Icon(Icons.camera_alt),
  //               label: const Text("Dari Kamera"),
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: Colors.green,
  //                 shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(8)),
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  // final picker = ImagePicker();

  // Future getImage(ImageSource media) async {
  //   final img =
  //       await picker.pickImage(source: media, maxHeight: 1024, maxWidth: 1024);
  //   setState(() {
  //     imageFile = File(img!.path);
  //   });
  // }

  void simpanData() async {
    String hargaFormattedValue = removeCurrencyFormat(_hargaController.text);
    int hargaParse = int.parse(hargaFormattedValue);
    int qty = int.tryParse(_qtyController.text) ?? 0;
    int total = hargaParse * qty;
    final dataProduk;
    if (selectedPkId != null) {
      dataProduk = await helper!
          .getProdukIdByPkDanNama(selectedPkId!, _produkController.text);

      if (dataProduk == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Produk Di Gudang tidak ditemukan")),
        );
        return;
      }
    } else {
      dataProduk = await helper!.getProdukId(selectedProdukId);
    }

    int produkId = dataProduk['id'];
    String kodeProduk = dataProduk['kode'];

    String tanggalInput = _tanggalController.text.trim();

    String tanggalFinal = tanggalInput.isEmpty
        ? DateTime.now().toString().split(' ')[0] // ambil yyyy-MM-dd
        : tanggalInput;

    Map<String, dynamic> data = {
      "tanggal": tanggalFinal,
      "produk_id": produkId,
      "qty": qty,
      "kode_produk": kodeProduk,
      "kode_supplier": _selectedSupplierKode,
      "harga_beli": hargaParse,
      "total": total,
      "metode_pembayaran": _metodeBayar,
      "keterangan": _keteranganController.text,
      "created_at": DateTime.now().toString(),
      "updated_at": DateTime.now().toString(),
    };

    final result = await helper!.insertBarangMasuk(data);

    // 🔥 Ambil ulang data yang sudah punya no_transaksi
    final insertedData = await helper!.getById('barang_masuk', result['id']);

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const BarangMasuk(
                title: '',
                tambah: 1,
              )),
    );

    await sendToMysql(
        result['id'], insertedData, kodeProduk, result['kode_hutang']);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Data berhasil disimpan")),
    );
  }

  Future<void> sendToMysql(int id, Map<String, dynamic> localData, kodeProduk,
      String kodeHutang) async {
    try {
      setState(() {
        _isLoading = true;
      });

      Map<String, String> body = {
        'id': id.toString(),
        'no_transaksi': localData['no_transaksi']?.toString() ?? '',
        'tanggal': localData['tanggal']?.toString() ?? '',
        "kode_produk": kodeProduk,
        "kode_supplier": _selectedSupplierKode.toString(),
        'qty': localData['qty']?.toString() ?? '0',
        'kode_hutang': kodeHutang.toString() ?? '0',
        'harga_beli': localData['harga_beli']?.toString() ?? '0',
        'total': localData['total']?.toString() ?? '0',
        'keterangan': localData['keterangan']?.toString() ?? '',
        'metode_pembayaran': localData['metode_pembayaran']?.toString() ?? '',
      };

      String url = 'createBarangMasuk';

      final response = await Network().getData_post(body, url);

      if (response.statusCode == 200) {
        setState(() {
          _isLoading = false;
        });
        await helper!.sync(id, 'id', 'barang_masuk');

        print('✅ Sync ke MySQL sukses');
      } else {
        setState(() {
          _isLoading = false;
        });
        print('❌ Error: ${response.body}');
        throw Exception('Gagal sync ke server');
      }
    } catch (e) {
      EasyLoading.showError(e.toString());
    }
  }

  Container tambahProd() {
    return Container(
      margin: const EdgeInsets.all(8),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: [
            //     Container(
            //       decoration: BoxDecoration(
            //         color: Colors.green.shade700,
            //         borderRadius: BorderRadius.circular(8),
            //       ),
            //       child: IconButton(
            //         onPressed: null,
            //         icon: const Icon(Icons.add, color: Colors.white),
            //       ),
            //     ),
            //   ],
            // ),

            /// NO TRANSAKSI
            ///
            ///
            ///

            /// TANGGAL
            buildDateField(
              "Tanggal (YYYY-MM-DD)",
              _tanggalController,
              Icons.date_range,
            ),

            buildProdukAutocomplete('nama_barang', "Nama Produk"),
            kodeToko == '00001' ? buildPkAcDropdown() : Container(),

            buildSupplierDropdown(),

            /// QTY
            buildField("Qty", _qtyController, Icons.production_quantity_limits,
                keyboard: TextInputType.number),

            /// HARGA BELI
            buildCurrencyField(
                "Harga Beli", _hargaController, Icons.attach_money,
                keyboard: TextInputType.number),

            buildMetodeBayarDropdown(),

            /// KETERANGAN
            buildField("Keterangan", _keteranganController, Icons.notes),
          ],
        ),
      ),
    );
  }

  Future<void> initAll() async {
    await _initData(); // ⬅️ tunggu dulu
    await loadProduk(); // ⬅️ baru load produk

    if (widget.scannedBarcode != null && widget.scannedBarcode!.isNotEmpty) {
      _handleBarcodeResult(widget.scannedBarcode!);
    }
  }

  List<Map<String, dynamic>> _listProduk = [];
  int? selectedProdukId;
  TextEditingController _produkController = TextEditingController();

  Future<void> loadProduk() async {
    final dataProduk =
        await helper!.allProdukAutoComplete(); // sesuaikan dengan helper kamu
    setState(() {
      _listProduk = dataProduk;
    });
  }

  var idProduk;

  void lastProduk() async {
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
      print(response.body);
      throw Exception('Failed to load album');
    }
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

  List<Map<String, dynamic>> _supplierList = [];
  String? _selectedSupplierKode;

  void _loadSupplier() async {
    final data = await helper!.supplier(); // dari KasirHelper
    setState(() {
      _supplierList = List<Map<String, dynamic>>.from(data);
    });
  }

  List<Map<String, dynamic>> _kategoriList = [];
  String? _selectedKategoriKode;

  void _loadKategori() async {
    final data = await helper!.kategori(); // dari KasirHelper
    setState(() {
      _kategoriList = List<Map<String, dynamic>>.from(data);
    });
  }

  Widget buildSupplierDropdown() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: _selectedSupplierKode,
        decoration: InputDecoration(
          labelText: "Supplier",
          prefixIcon: const Icon(Icons.store),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        items: _supplierList.map((supplier) {
          return DropdownMenuItem<String>(
            value: supplier['kode_supplier'].toString(),
            child: Text(supplier['nama']),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedSupplierKode = value;
          });
        },
      ),
    );
  }

  Widget buildKategoriDropdown() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: _selectedKategoriKode,
        decoration: InputDecoration(
          labelText: "Kategori",
          prefixIcon: const Icon(Icons.store),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        items: _kategoriList.map((kategori) {
          return DropdownMenuItem<String>(
            value: kategori['kode'].toString(),
            child: Text(kategori['nama_kategori']),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedKategoriKode = value;
          });
        },
      ),
    );
  }

  Widget buildDateField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: TextField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );

          if (pickedDate != null) {
            controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
          }
        },
      ),
    );
  }

  Widget buildProdukAutocomplete(kolom, String label) {
    return Autocomplete<Map<String, dynamic>>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<Map<String, dynamic>>.empty();
        }

        return _listProduk.where((produk) {
          return produk[kolom]
              .toString()
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        });
      },
      displayStringForOption: (option) => option[kolom],
      onSelected: (option) {
        setState(() {
          selectedProdukId = option['id'];
          _produkController.text = option[kolom];
          if (option['harga_beli'] != null) {
            String hargaBeli = option['harga_beli'].toString();
            final formatter = NumberFormat.currency(
              locale: 'id_ID',
              symbol: 'Rp ',
              decimalDigits: 0,
            );
            _hargaController.text = formatter.format(int.parse(hargaBeli));
          }
        });
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        _produkController = controller;

        return Container(
            margin: const EdgeInsets.only(top: 1, bottom: 10),
            width: 260,
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: label,
                prefixIcon: const Icon(Icons.inventory),
                border: const OutlineInputBorder(),
              ),
            ));
      },
    );
  }

  String _metodeBayar = "hutang";
  Widget buildMetodeBayarDropdown() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: _metodeBayar,
        decoration: InputDecoration(
          labelText: "Metode Bayar",
          prefixIcon: const Icon(Icons.payment),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        items: const [
          DropdownMenuItem(
            value: "hutang",
            child: Text("Hutang"),
          ),
          DropdownMenuItem(
            value: "cash",
            child: Text("Cash"),
          ),
        ],
        onChanged: (value) {
          setState(() {
            _metodeBayar = value!;
          });
        },
      ),
    );
  }

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

  Widget buildField(
      String hint, TextEditingController controller, IconData icon,
      {TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: hint,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget buildCurrencyField(
      String hint, TextEditingController controller, IconData icon,
      {TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          CurrencyInputFormatter(),
        ],
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: hint,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Membersihkan sumber daya saat widget dihapus
    // myController.dispose();

    _noTransaksiController.dispose();
    _tanggalController.dispose();
    _qtyController.dispose();
    _hargaController.dispose();
    _keteranganController.dispose();

    super.dispose();
  }
}

// Widget Scanner Barcode
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
//                           builder: (context) => TambahBarangMasuk(
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

// Custom formatter untuk currency
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Hapus semua karakter yang bukan angka
    String cleanValue = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Format sebagai currency
    if (cleanValue.isNotEmpty) {
      final formatter = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      );
      String formattedValue = formatter.format(int.parse(cleanValue));

      return TextEditingValue(
        text: formattedValue,
        selection: TextSelection.collapsed(offset: formattedValue.length),
      );
    }

    return newValue;
  }
}
