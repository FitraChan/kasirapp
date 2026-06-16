import 'package:flutter/material.dart';
import 'package:kasirapp/model/pengeluaranModel.dart';
import 'package:kasirapp/network_utils/api.dart';
import 'package:kasirapp/screen/home.dart';
// import 'package:kasirapp/master_data/tambahKategori.dart';
import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:kasirapp/transaksi/pengeluaran.dart';
import '../screen/menu1.dart';
//import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

//import 'package:firebase_messaging/firebase_messaging.dart';

class EditPengeluaran extends StatefulWidget {
  PengeluaranModel pengeluaranModel;
  // final int index;
  EditPengeluaran({Key? key, required this.pengeluaranModel}) : super(key: key);

  @override
  _EditPengeluaranState createState() => _EditPengeluaranState();
}

class _EditPengeluaranState extends State<EditPengeluaran> {
  TextEditingController _namaController = TextEditingController();

  TextEditingController _nilaiController = TextEditingController();
  bool _isLoading = false;
  KasirHelper? helper;

  List data = [];
  String? email;

  @override
  void initState() {
    //  gambar = widget.produkModel.gambar.toString();

    _namaController = TextEditingController(
        text: widget.pengeluaranModel.keterangan.toString());
    // hargaGrosir =
    //     TextEditingController(text: widget.produkModel.hargaGrosir.toString());
    _nilaiController =
        TextEditingController(text: widget.pengeluaranModel.nilai.toString());

    helper = KasirHelper();

    super.initState();
  }

  String? base64Image;
  //String? imagePath;
  sendToMysql(id, keterangan, nilai) async {
    // imageFile = File(imagePath!);
    Map data = {
      'id': id.toString(),
      'keterangan': keterangan,
      'nilai': nilai,
    };

    String url;

    url = 'update_pengeluaran';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Pengeluaran',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Detail Pengeluaran",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                /// Nama
                TextFormField(
                  controller: _namaController,
                  decoration: InputDecoration(
                    labelText: "Nama Pengeluaran",
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// Nilai
                TextFormField(
                  controller: _nilaiController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Nilai (Rp)",
                    prefixIcon: const Icon(Icons.attach_money),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                /// Tombol Simpan
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isLoading ? null : _simpan,
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            "Update",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _simpan() async {
    if (_namaController.text.isEmpty || _nilaiController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lengkapi data terlebih dahulu")),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });

    final id = int.parse(widget.pengeluaranModel.id.toString());

    await helper!.updatePengeluaran(
      id,
      _namaController.text,
      _nilaiController.text,
    );

    await sendToMysql(id, _namaController.text, _nilaiController.text);

    // Navigator.pop(context, true); // 🔥 penting
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const Pengeluaran(
                title: '',
                tambah: 1,
              )),
    );

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nilaiController.dispose();

    super.dispose();
  }
}
