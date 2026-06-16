import 'package:flutter/material.dart';
import 'package:kasirapp/model/penerimaanModel.dart';
import 'package:kasirapp/network_utils/api.dart';
import 'package:kasirapp/screen/home.dart';
// import 'package:kasirapp/master_data/tambahKategori.dart';
import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:kasirapp/transaksi/penerimaan.dart';
import '../screen/menu1.dart';
//import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

//import 'package:firebase_messaging/firebase_messaging.dart';

class EditPenerimaan extends StatefulWidget {
  PenerimaanModel penerimaanModel;
  // final int index;
  EditPenerimaan({Key? key, required this.penerimaanModel}) : super(key: key);

  @override
  _EditPenerimaanState createState() => _EditPenerimaanState();
}

class _EditPenerimaanState extends State<EditPenerimaan> {
  TextEditingController _namaController = TextEditingController();

  TextEditingController _nilaiController = TextEditingController();

  KasirHelper? helper;

  List data = [];
  String? email;

  @override
  void initState() {
    //  gambar = widget.produkModel.gambar.toString();

    _namaController = TextEditingController(
        text: widget.penerimaanModel.keterangan.toString());
    // hargaGrosir =
    //     TextEditingController(text: widget.produkModel.hargaGrosir.toString());
    _nilaiController =
        TextEditingController(text: widget.penerimaanModel.nilai.toString());

    helper = KasirHelper();

    super.initState();
  }

  simpan() async {
    // var nilaiParse = int.parse(_nilaiController.text);
    //var hargaGrosirParse = int.parse(hargaGrosir.text);
    var id = int.parse(widget.penerimaanModel.id.toString());

    // String imgString = Utility.base64String(imageFile!.readAsBytesSync());
    await helper!
        .updatePenerimaan(id, _namaController.text, _nilaiController.text);

    //Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const Penerimaan(
                title: '',
                tambah: 1,
              )),
    );
    sendToMysql(id, _namaController.text, _nilaiController.text);
  }

  String? base64Image;
  //String? imagePath;
  void sendToMysql(id, keterangan, nilai) async {
    // imageFile = File(imagePath!);
    Map data = {
      'id': id.toString(),
      'keterangan': keterangan,
      'nilai': nilai,
    };

    String url;

    url = 'update_penerimaan';

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
              'Edit Penerimaan',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: const BackButton(),
          ),
          backgroundColor: Colors.grey[300],
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                const Text(
                  "Detail Penerimaan",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        /// Nama
                        TextFormField(
                          controller: _namaController,
                          decoration: InputDecoration(
                            labelText: "Nama Penerimaan",
                            prefixIcon: const Icon(Icons.description_outlined),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// Nilai
                        TextFormField(
                          controller: _nilaiController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Nilai",
                            prefixIcon: const Icon(Icons.payments_outlined),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                /// Tombol Simpan
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      simpan();
                    },
                    child: const Text(
                      "Simpan Perubahan",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ));
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nilaiController.dispose();

    super.dispose();
  }
}
