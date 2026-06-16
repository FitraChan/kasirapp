// import 'package:bluetooth_print/bluetooth_print.dart';
// import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:kasirapp/model/currencyFormatter.dart';
import 'package:kasirapp/model/transaksiPembelianModel.dart';
import 'package:kasirapp/network_utils/api.dart';
import 'package:kasirapp/transaksi/printerenum.dart';
import 'package:kasirapp/transaksi/transPenjualan.dart';

class PrintingPemesanan extends StatefulWidget {
  const PrintingPemesanan(
      {Key? key,
      required this.detailTransaksi,
      required this.all,
      required this.tot,
      //  required this.idUser,
      required this.createdAt,
      required this.namaTrans})
      : super(key: key);

  final List detailTransaksi;
  final List all;
  final tot;

  //final idUser;

  final createdAt;
  final namaTrans;

  @override
  _PrintingPemesananState createState() => _PrintingPemesananState();
}

class _PrintingPemesananState extends State<PrintingPemesanan> {
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? selectedDevice;
  final oCcy = NumberFormat.decimalPattern();

  BlueThermalPrinter printer = BlueThermalPrinter.instance;
  var current;

  var currentString;
  var currentStringDb;
  var pembelian = [];
  var selectDetailPembelian = [];
  var idTrx;

  KasirHelper? helper;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    current = DateTime.parse(DateTime.now().toString());
    helper = KasirHelper();
    currentString = DateFormat('dd-MM-yyyy HH:mm').format(current);

    currentStringDb = DateFormat('yyyy-MM-dd HH:mm:ss').format(current);

    TransaksiPembelianModel beli = TransaksiPembelianModel({
      'total': widget.tot,
      'id_pembeli': idUser,
      'keterangan': widget.namaTrans,
      'created_at': currentStringDb,
    });

    helper!.createTransaksiPembelian(beli);

    if (helper != null) {
      helper!.idPembelian().then((courses) {
        setState(() {
          //allDetailTrans = courses;
          pembelian = courses;
          idTrx = pembelian.first['id'];
          //_isLoading = false;

          helper!.updateDetailTransaksiPembelianPemesanan(idTrx);
        });

        mysqlCreatePembayaran(widget.tot, idTrx, idUser, currentStringDb);
      });
    }

    // getDevices();
  }

  String? name;
  int? idUser;
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
        // nim = user['str_user_name'];
      });
    }
  }

  void mysqlCreatePembayaran(total, idTrx, idUser, createdAt) async {
    Map data = {
      'total': widget.tot,
      'id_transaksi': idTrx,
      'id_pembeli': idUser,
      'status_bayar': 1,
      'created_at': createdAt,
    };

    String url;

    url = 'save_pemesanan_didepan';

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

  void getDevices() async {
    _devices = await printer.getBondedDevices();
    setState(() {});
  }

  Future<BluetoothDevice?> loadBluetoothDevice() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? deviceAddress = prefs.getString('selected_device');
    // String? deviceAddress = 'RPP210A';

    print(deviceAddress);

    // Gunakan alamat Bluetooth untuk mendapatkan kembali objek BluetoothDevice
    _devices = await printer.getBondedDevices();
    BluetoothDevice? selectedDevicess = _devices
        .map((result) => result)
        .firstWhere((device) => device.name == deviceAddress);

    return selectedDevicess;

    //return null;
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
                'Warmindo',
                style: TextStyle(color: Colors.white),
              ),

              //30,150,244,255
              backgroundColor: const Color.fromARGB(255, 30, 150, 244),
            ),
            backgroundColor: const Color.fromARGB(255, 0, 44, 66),
            body: Center(
              child: Column(children: [
                const SizedBox(
                  height: 10,
                ),
                Container(
                  alignment: Alignment.topCenter,
                  width: 100,
                  height: 90,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/check.png'),
                      fit: BoxFit.fill,
                    ),
                    //shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 10),
                        width: 150,
                        child: FloatingActionButton.extended(
                          heroTag: 'uniqueTag1',

                          onPressed: () async {
                            BluetoothDevice? selectedDevicedd =
                                await loadBluetoothDevice();
                            printer.connect(selectedDevicedd!);
                          },
                          label: const Text('Connect'), //rgba(31,139,227,255)
                          backgroundColor:
                              const Color.fromARGB(255, 31, 139, 227),
                          foregroundColor: Colors.white,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 10),
                        width: 150,
                        child: FloatingActionButton.extended(
                          heroTag: 'uniqueTag2',

                          onPressed: () async {
                            if ((await printer.isConnected)!) {
                              cetakPrint();
                              // printer.disconnect();

                              // printer.dispose();

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
                              getDevices();
                              BluetoothDevice? selectedDevicedd =
                                  await loadBluetoothDevice();
                              printer.connect(selectedDevicedd!);
                              cetakPrint();
                              // printer.disconnect();
                            }
                          },
                          label: const Text('Print'), //rgba(254,152,0,255)
                          backgroundColor:
                              const Color.fromARGB(255, 254, 152, 0),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ]),
              ]),
            )));
  }

  final currencyFormatter = CurrencyFormatter();

  Future<void> cetakPrint() async {
    printer.printNewLine();
    printer.printCustom("WARMINDO", Size.boldMedium.val, Alignn.center.val);

    printer.printNewLine();

    printer.printLeftRight("Tanggal:", "$currentString", Size.bold.val,
        charset: "windows-1250");

    printer.printLeftRight("Kasir:", "$name", Size.bold.val,
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
