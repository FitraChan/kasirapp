// import 'package:bluetooth_print/bluetooth_print.dart';
// import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:intl/intl.dart';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:kasirapp/network_utils/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:kasirapp/model/currencyFormatter.dart';
import 'package:kasirapp/transaksi/printerenum.dart';
import 'package:kasirapp/transaksi/transPenjualan.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PrintingWidget extends StatefulWidget {
  const PrintingWidget(
      {Key? key,
      required this.idTrans,
      required this.detailTransaksi,
      required this.all,
      required this.tot,
      required this.dibayar,
      required this.kembalian,
      required this.nama})
      : super(key: key);

  final idTrans;
  final List detailTransaksi;
  final List all;
  final tot;
  final dibayar;
  final kembalian;
  final nama;

  @override
  _PrintingWidgetState createState() => _PrintingWidgetState();
}

class _PrintingWidgetState extends State<PrintingWidget> {
  File? imageFile;
  bool _isLoading = false;

  List<BluetoothDevice> _devices = [];
  BluetoothDevice? selectedDevice;
  final oCcy = NumberFormat.decimalPattern();

  BlueThermalPrinter printer = BlueThermalPrinter.instance;
  var current;
  var currentString;

  var totalBayar;
  var kembalian;
  var allPembayaran = [];

  KasirHelper? helper;

  final currencyFormatter = CurrencyFormatter();

  @override
  void initState() {
    super.initState();
    helper = KasirHelper();

    if (helper != null) {}

    if (helper != null) {
      helper!.pembayaranLast().then((course) {
        setState(() {
          allPembayaran = course;
          totalBayar = allPembayaran.first['dibayar'];
          kembalian = allPembayaran.first['kembalian'];

          //_isLoading = false;
        });
      });
    }
    //WidgetsBinding.instance.addPostFrameCallback((_) => initPrinter());
    current = DateTime.parse(DateTime.now().toString());

    currentString = DateFormat('dd-MM-yyyy HH:mm').format(current);
    //getDevices();
  }

  void getDevices() async {
    _devices = await printer.getBondedDevices();
    setState(() {});
  }

  Future<BluetoothDevice?> loadBluetoothDevice() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? deviceAddress = prefs.getString('selected_device');
    //  String? deviceAddress = 'RPP210A';
    print(deviceAddress);

    // Gunakan alamat Bluetooth untuk mendapatkan kembali objek BluetoothDevice
    _devices = await printer.getBondedDevices();
    BluetoothDevice? selectedDevicess = _devices
        .map((result) => result)
        .firstWhere((device) => device.name == deviceAddress);

    return selectedDevicess;
  }

  final ImagePicker _picker = ImagePicker();

  // Future<void> openCamera() async {
  //   try {
  //     final XFile? photo = await _picker.pickImage(
  //       source: ImageSource.camera,
  //       imageQuality: 70, // kompres (0–100)
  //     );

  //     if (photo != null) {
  //       imageFile = File(photo.path);

  //       print('Foto tersimpan di: ${imageFile!.path}');

  //       // 👉 lanjutkan:
  //       // - upload ke server
  //       // - convert base64
  //       // - simpan ke SQLite
  //     }
  //   } catch (e) {
  //     print('Gagal membuka kamera: $e');
  //   }
  // }

  Future getImage(ImageSource media) async {
    final img =
        await _picker.pickImage(source: media, maxHeight: 1024, maxWidth: 1024);
    setState(() {
      imageFile = File(img!.path);
    });
  }

  @override
  Widget build(BuildContext context) {
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
              title: const Text(
                'Cashier',
                style: TextStyle(color: Colors.white),
              ),

              //30,150,244,255
              backgroundColor: const Color.fromARGB(255, 30, 150, 244),
            ),

            //rgba(0,44,66,255)
            backgroundColor: const Color.fromARGB(255, 0, 44, 66),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),

                  // ICON
                  SizedBox(
                    width: 100,
                    height: 90,
                    child: Image.asset(
                      'images/check.png',
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // LABEL
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "Total Pembayaran",
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          "Kembalian",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 6),

                  // VALUE
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          totalBayar != null
                              ? currencyFormatter.format(totalBayar.toString())
                              : '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          kembalian != null
                              ? currencyFormatter.format(kembalian.toString())
                              : '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // BUTTONS
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: FloatingActionButton.extended(
                            heroTag: 'connectBtn',
                            onPressed: () async {
                              BluetoothDevice? device =
                                  await loadBluetoothDevice();
                              if (device != null) {
                                printer.connect(device);
                              }
                            },
                            label: const Text('Connect'),
                            backgroundColor:
                                const Color.fromARGB(255, 31, 139, 227),
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FloatingActionButton.extended(
                            heroTag: 'printBtn',
                            onPressed: () async {
                              if ((await printer.isConnected)!) {
                                cetakPrint();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const TransPenjualan(
                                      tanggal: '',
                                      delivery: "1",
                                      idPembayaran: 0,
                                    ),
                                  ),
                                );
                              } else {
                                BluetoothDevice? device =
                                    await loadBluetoothDevice();
                                if (device != null) {
                                  await printer.connect(device);
                                  cetakPrint();
                                }
                              }
                            },
                            label: const Text('Print'),
                            backgroundColor:
                                const Color.fromARGB(255, 254, 152, 0),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      height: 48,
                      width: 200,
                      child: FloatingActionButton.extended(
                        heroTag: 'connectBtn1',
                        onPressed: () async {
                          getImage(ImageSource.camera);
                        },
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Kamera'),
                        backgroundColor: const Color(0xFF455A64),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 5),

                  Container(
                    // margin: const EdgeInsets.only(top: 10.0),
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
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white),
                              ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 5),
                  if (imageFile != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        height: 48,
                        width: 100,
                        child: FloatingActionButton.extended(
                          heroTag: 'connectBtn2',
                          onPressed: () async {
                            sendToMysql();
                          },
                          // icon: const Icon(Icons.camera_alt),
                          icon: const Icon(Icons.save),

                          label:
                              Text(_isLoading ? 'Tunggu Sebentar...' : 'Save'),
                          backgroundColor:
                              const Color.fromARGB(255, 138, 153, 158),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            )));
  }

  String? base64Image;
  //String? imagePath;

  void sendToMysql() async {
    try {
      String fileName = imageFile!.path.split('/').last;
      base64Image = base64Encode(imageFile!.readAsBytesSync());
      Uint8List imageBytes = base64Decode(base64Image!.split(',').last);
      Uint8List resizedImage = await resizeImage(imageBytes, 200, 200);
      String base64ImageResized = base64Encode(resizedImage);
      setState(() {
        _isLoading = true;
      });
      Map data = {
        'id_transaksi': widget.idTrans.toString(),
        'base': base64ImageResized,
        'image': fileName,
      };

      String url;

      url = 'updateGambarTransaksi';

      // final response = await htpp.post(Uri.parse(url), body: data);
      final response = await Network().getData_post(data, url);
      // var c = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          _isLoading = false;
        });
        EasyLoading.showSuccess(
          'Data Berhasil Di Save',
          duration: const Duration(seconds: 2),
        );
      } else {
        print(response.body);

        EasyLoading.showSuccess(
          response.body,
          duration: const Duration(seconds: 2),
        );
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

  Future<void> cetakPrint() async {
    printer.printNewLine();
    printer.printCustom("WARMINDO", Size.boldMedium.val, Alignn.center.val);

    printer.printNewLine();

    printer.printLeftRight("Tanggal:", "$currentString", Size.bold.val,
        charset: "windows-1250");

    printer.printLeftRight("Kasir:", "${widget.nama}", Size.bold.val,
        charset: "windows-1250");

    printer.printCustom(
        "--------------------------------", Size.bold.val, Alignn.center.val);

    //  printer.printNewLine();

    for (var i = 0; i < widget.detailTransaksi.length; i++) {
      printer.printLeftRight(
          "${widget.detailTransaksi[i]['nama_barang']}", "", Size.bold.val,
          charset: "windows-1250");

      printer.printLeftRight(
          "${(widget.detailTransaksi[i]['qty'])} x ${oCcy.format(widget.detailTransaksi[i]['harga_jual'])}.00 =",
          "${oCcy.format(widget.detailTransaksi[i]['harga'])}.00",
          Size.bold.val,
          charset: "windows-1250");

      for (var a = 0; a < widget.all[i].length; a++) {
        printer.printLeftRight(
            "${widget.all[a][i]['nama_barang']}", "", Size.bold.val,
            charset: "windows-1250");

        printer.printLeftRight(
            "${(widget.all[a][i]['qty'])} x ${oCcy.format(widget.all[a][i]['harga_jual'])}.00 =",
            "${oCcy.format(widget.all[a][i]['harga'])}.00",
            Size.bold.val,
            charset: "windows-1250");
      }
    }
    printer.printCustom(
        "--------------------------------", Size.bold.val, Alignn.center.val);
    // printer.printNewLine();

    printer.printLeftRight("Total:", "${widget.tot}.00", Size.bold.val,
        charset: "windows-1250");
    //  printer.printNewLine();
    printer.printLeftRight("Dibayar:", "${widget.dibayar}", Size.bold.val,
        charset: "windows-1250");
    //printer.printNewLine();

    printer.printLeftRight("Kembalian:", "${widget.kembalian}", Size.bold.val,
        charset: "windows-1250");

    printer.printNewLine();
    printer.printCustom("Thank You", Size.bold.val, Alignn.center.val);

    printer.paperCut();
  }

  @override
  void dispose() {
    // printer.disconnect();
    super.dispose();
  }
}
