import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:kasirapp/model/rupiahCurrency.dart';
import 'package:kasirapp/network_utils/api.dart';
import 'package:kasirapp/screen/home.dart';
import 'package:kasirapp/sync/syncServicePkAc.dart';
import 'package:kasirapp/sync/syncServiceSupplier.dart';
import 'package:kasirapp/transaksi/barangMasuk.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditBarangMasuk extends StatefulWidget {
  final Map<String, dynamic> barangMasuk;
  const EditBarangMasuk({Key? key, required this.barangMasuk})
      : super(key: key);

  @override
  _EditBarangMasukState createState() => _EditBarangMasukState();
}

class _EditBarangMasukState extends State<EditBarangMasuk> {
  final _tanggalController = TextEditingController();
  final _qtyController = TextEditingController();
  final _hargaController = TextEditingController();
  final _keteranganController = TextEditingController();

  final syncServicePkAc = SyncServicePkAc();
  final syncServiceSupplier = SyncServiceSupplier();

  KasirHelper? helper;
  bool _isLoading = false;

  var kodeToko;

  @override
  void initState() {
    super.initState();
    helper = KasirHelper();
    _loadSupplier();
    loadProduk();
    _initData();

    _tanggalController.text = widget.barangMasuk['tanggal'] ?? '';
    _qtyController.text = (widget.barangMasuk['qty'] ?? 0).toString();
    _hargaController.text = (widget.barangMasuk['harga_beli'] ?? 0).toString();
    _keteranganController.text = widget.barangMasuk['keterangan'] ?? '';
  }

  Future<void> _initData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await syncServiceSupplier.syncSupplier();
    setState(() {
      kodeToko = pref.getString('kode_toko');
    });
    if (kodeToko == '00001') {
      await syncServicePkAc.syncPkAc();
      loadPkac();
    } else {
      _loadKategori();
    }
  }

  String removeCurrencyFormat(String formattedValue) {
    return formattedValue.replaceAll(RegExp(r'[^\d]'), '');
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
              'Edit Barang Masuk',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
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
                child: _buildForm(),
              ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(20),
            child: GestureDetector(
              onTap: _updateData,
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFB71C1C), Color(0xFFD32F2F)],
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
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white))
                      : const Text(
                          "UPDATE DATA",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ));
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildDateField(
          "Tanggal (YYYY-MM-DD)",
          _tanggalController,
          Icons.date_range,
        ),
        buildSupplierDropdown(),
        buildField("Qty", _qtyController, Icons.production_quantity_limits,
            keyboard: TextInputType.number),
        buildCurrencyField("Harga Beli", _hargaController, Icons.attach_money,
            keyboard: TextInputType.number),
        buildMetodeBayarDropdown(),
        buildField("Keterangan", _keteranganController, Icons.notes),
      ],
    );
  }

  Future<void> _updateData() async {
    String hargaFormattedValue = removeCurrencyFormat(_hargaController.text);
    int hargaParse = int.parse(hargaFormattedValue);
    int qty = int.tryParse(_qtyController.text) ?? 0;
    int total = hargaParse * qty;

    String tanggalInput = _tanggalController.text.trim();
    String tanggalFinal = tanggalInput.isEmpty
        ? DateTime.now().toString().split(' ')[0]
        : tanggalInput;

    Map<String, dynamic> data = {
      "id": widget.barangMasuk['id'],
      "no_transaksi": widget.barangMasuk['no_transaksi'],
      "tanggal": tanggalFinal,
      "produk_id": widget.barangMasuk['produk_id'],
      "qty": qty,
      "kode_produk": widget.barangMasuk['kode_produk'],
      "kode_supplier":
          _selectedSupplierKode ?? widget.barangMasuk['kode_supplier'],
      "harga_beli": hargaParse,
      "total": total,
      "metode_pembayaran":
          _metodeBayar ?? widget.barangMasuk['metode_pembayaran'],
      "keterangan": _keteranganController.text,
      "updated_at": DateTime.now().toString(),
    };

    await helper!.updateBarangMasuk(data);

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const BarangMasuk(title: '', tambah: 1)),
    );

    await _sendToMysqlUpdate(data);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Data berhasil diupdate")),
    );
  }

  Future<void> _sendToMysqlUpdate(Map<String, dynamic> data) async {
    try {
      setState(() => _isLoading = true);

      Map<String, String> body = {
        'id': data['id'].toString(),
        'no_transaksi': data['no_transaksi'].toString(),
        'tanggal': data['tanggal'].toString(),
        "kode_produk": data['kode_produk'].toString(),
        "kode_supplier": data['kode_supplier'].toString(),
        'qty': data['qty'].toString(),
        'harga_beli': data['harga_beli'].toString(),
        'total': data['total'].toString(),
        'keterangan': data['keterangan'].toString(),
        'metode_pembayaran': data['metode_pembayaran'].toString(),
      };

      String url = 'update_barang_masuk';
      final response = await Network().getData_post(body, url);

      if (response.statusCode == 200) {
        setState(() => _isLoading = false);
        //  await helper!.sync(data['id'], 'id', 'barang_masuk');
        print('✅ Update sync ke MySQL sukses');
      } else {
        setState(() => _isLoading = false);
        print('❌ Error: ${response.body}');
        throw Exception('Gagal update ke server');
      }
    } catch (e) {
      EasyLoading.showError(e.toString());
    }
  }

  List<Map<String, dynamic>> _listProduk = [];
  int? selectedProdukId;
  TextEditingController _produkController = TextEditingController();

  Future<void> loadProduk() async {
    final dataProduk = await helper!.allProdukAutoComplete();
    setState(() {
      _listProduk = dataProduk;
    });
  }

  List<Map<String, dynamic>> _listPkAc = [];
  int? selectedPkId;
  TextEditingController _pkController = TextEditingController();

  Future<void> loadPkac() async {
    final dataPk = await helper!.allPkAutoComplete();
    setState(() {
      _listPkAc = List<Map<String, dynamic>>.from(dataPk);
    });
  }

  List<Map<String, dynamic>> _supplierList = [];
  String? _selectedSupplierKode;

  void _loadSupplier() async {
    final data = await helper!.supplier();
    setState(() {
      _supplierList = List<Map<String, dynamic>>.from(data);
      _selectedSupplierKode = widget.barangMasuk['kode_supplier'];
    });
  }

  List<Map<String, dynamic>> _kategoriList = [];
  String? _selectedKategoriKode;

  void _loadKategori() async {
    final data = await helper!.kategori();
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
          prefixIcon: const Icon(Icons.category),
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
      padding: const EdgeInsets.only(bottom: 15),
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

  String _metodeBayar = "cash";
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
          DropdownMenuItem(value: "cash", child: Text("Cash")),
          DropdownMenuItem(value: "hutang", child: Text("Hutang")),
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
    _tanggalController.dispose();
    _qtyController.dispose();
    _hargaController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }
}
