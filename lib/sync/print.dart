// import 'package:bluetooth_print/bluetooth_print.dart';
// import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Print extends StatefulWidget {
  const Print({Key? key}) : super(key: key);

  @override
  _PrintState createState() => _PrintState();
}

class _PrintState extends State<Print> {
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? selectedDevice;

  BlueThermalPrinter printer = BlueThermalPrinter.instance;

  @override
  void initState() {
    super.initState();
    //WidgetsBinding.instance.addPostFrameCallback((_) => initPrinter());
    getDevices();
  }

  void getDevices() async {
    _devices = await printer.getBondedDevices();
    setState(() {});
  }

  Future<void> saveSelectedBluetoothDevice(
      BluetoothDevice deviceAddress) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('selected_device', deviceAddress.name.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Bluetooth devices')),
        body: Center(
          child: Column(children: [
            DropdownButton<BluetoothDevice>(
              value: selectedDevice,
              hint: const Text('Thernal'),
              onChanged: (device) {
                setState(() {
                  selectedDevice = device;
                });
              },
              items: _devices
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.name.toString()),
                      ))
                  .toList(),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () {
                  printer.connect(selectedDevice!);

                  saveSelectedBluetoothDevice(selectedDevice!);
                },
                child: const Text('Connect')),
            ElevatedButton(
                onPressed: () {
                  printer.disconnect();
                },
                child: const Text("DIsconnect")),
            ElevatedButton(
                onPressed: () async {
                  if ((await printer.isConnected)!) {}
                },
                child: const Text("Print"))
          ]),
        ));
  }

  // Future<void> _startPrint(BluetoothDevice device) async {
  //   if (device.address != null) {
  //     await bluetoothPrint.connect(device);

  //     Map<String, dynamic> config = {};
  //     List<LineText> list = [];

  //     list.add(
  //       LineText(
  //         type: LineText.TYPE_TEXT,
  //         content: "Grocery App",
  //         weight: 2,
  //         width: 2,
  //         height: 2,
  //         align: LineText.ALIGN_CENTER,
  //         linefeed: 1,
  //       ),
  //     );

  //     for (var i = 0; i < widget.detailTransaksi.length; i++) {
  //       list.add(
  //         LineText(
  //           type: LineText.TYPE_TEXT,
  //           content: widget.detailTransaksi[i]['nama_barang'],
  //           weight: 0,
  //           align: LineText.ALIGN_LEFT,
  //           linefeed: 1,
  //         ),
  //       );

  //       // list.add(
  //       //   LineText(
  //       //     type: LineText.TYPE_TEXT,
  //       //     content:
  //       //         "${f.format(widget.detailTransaksi[i]['harga_barang'])} x ${widget.detailTransaksi[i]['qty']}",
  //       //     align: LineText.ALIGN_LEFT,
  //       //     linefeed: 1,
  //       //   ),
  //       // );
  //     }
  //   }
  // }

  @override
  void dispose() {
    printer.disconnect();

    super.dispose();
  }
}
