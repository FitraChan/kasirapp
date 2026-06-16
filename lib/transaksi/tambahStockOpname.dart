import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:kasirapp/network_utils/api.dart';
import 'package:kasirapp/transaksi/stockOpname.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class TambahStockOpname extends StatefulWidget {
  final Map<String, dynamic>? stockOpnameData;

  const TambahStockOpname({Key? key, this.stockOpnameData}) : super(key: key);

  @override
  _TambahStockOpnameState createState() => _TambahStockOpnameState();
}

class _TambahStockOpnameState extends State<TambahStockOpname> {
  final _tanggalController = TextEditingController();
  final _keteranganController = TextEditingController();
  final _stokFisikController = TextEditingController();

  KasirHelper? helper;
  bool _isLoading = false;

  List<Map<String, dynamic>> _listProduk = [];
  int? selectedProdukId;
  String? selectedProdukKode;
  String? selectedProdukNama;
  double? stokSistem;

  TextEditingController _produkController = TextEditingController();

  bool get isEdit => widget.stockOpnameData != null;

  @override
  void initState() {
    super.initState();
    helper = KasirHelper();
    loadProduk();

    if (isEdit) {
      selectedProdukId = widget.stockOpnameData!['produk_id'];
      selectedProdukKode = widget.stockOpnameData!['kode_produk'];
      selectedProdukNama = widget.stockOpnameData!['nama_produk'];
      stokSistem =
          double.parse(widget.stockOpnameData!['stok_sistem'].toString());
      _stokFisikController.text =
          widget.stockOpnameData!['stok_fisik'].toString();
      _tanggalController.text = widget.stockOpnameData!['tanggal'] ?? '';
      _keteranganController.text = widget.stockOpnameData!['keterangan'] ?? '';
      _produkController.text = selectedProdukNama ?? '';
    } else {
      _tanggalController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
  }

  Future<void> loadProduk() async {
    final dataProduk = await helper!.allProdukAutoComplete();
    setState(() {
      _listProduk = dataProduk;
    });
  }

  void hitungSelisih() {
    setState(() {});
  }

  double? get selisih {
    if (stokSistem == null || _stokFisikController.text.isEmpty) return null;
    double stokFisik = double.tryParse(_stokFisikController.text) ?? 0;
    return stokFisik - stokSistem!;
  }

  void simpanData() async {
    if (selectedProdukId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih produk terlebih dahulu')),
      );
      return;
    }

    if (_stokFisikController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stok fisik harus diisi')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    double stokFisik = double.parse(_stokFisikController.text);
    double selisihValue = stokFisik - stokSistem!;

    SharedPreferences pref = await SharedPreferences.getInstance();
    String user = pref.getString('user') ?? 'Admin';

    Map<String, dynamic> data = {
      'produk_id': selectedProdukId,
      'kode_produk': selectedProdukKode,
      'nama_produk': selectedProdukNama,
      'stok_sistem': stokSistem.toString(),
      'stok_fisik': stokFisik.toString(),
      'selisih': selisihValue.toString(),
      'keterangan': _keteranganController.text,
      'tanggal': _tanggalController.text,
      'created_by': user,
      'is_sync': 0,
    };

    if (isEdit) {
      await helper!.updateStockOpname(data, widget.stockOpnameData!['id']);

      // Update stok produk jika ada selisih
      if (selisihValue != 0) {
        int stokBaru = (stokSistem! + selisihValue).toInt();
        final dbClient = KasirHelper.db;
        await dbClient!.rawUpdate('UPDATE tb_produk SET stok = ? WHERE id = ?',
            [stokBaru, selectedProdukId!]);
      }
    } else {
      await helper!.insertStockOpname(data);

      await sendToMysql(
        selectedProdukKode!,
        stokFisik,
        stokSistem!,
        _keteranganController.text,
        _tanggalController.text,
      );

      // Update stok produk jika ada selisih
      if (selisihValue != 0) {
        int stokBaru = (stokSistem! + selisihValue).toInt();
        final dbClient = KasirHelper.db;
        await dbClient!.rawUpdate('UPDATE tb_produk SET stok = ? WHERE id = ?',
            [stokBaru, selectedProdukId!]);
      }
    }

    setState(() {
      _isLoading = false;
    });

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) => const StockOpname(title: 'Stock Opname')),
      (route) => false,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(isEdit
              ? 'Data stock opname berhasil diupdate'
              : 'Stock opname berhasil disimpan')),
    );
  }

  Future<bool> sendToMysql(String kodeProduk, stokFisik, double stokSistem,
      String keterangan, String tanggal) async {
    try {
      Map<String, dynamic> data = {
        'kode_produk': kodeProduk,
        'stok_sistem': stokSistem,
        'stok_fisik': stokFisik,
        'keterangan': keterangan,
        'tanggal': tanggal,
        'created_by': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      };

      String url = "simpanStockOpname";

      final response = await Network().getData_post(data, url);

      if (response.statusCode == 200) {
        var result = json.decode(response.body);
        print('Sukses send to MySQL: $result');
        return true;
      } else {
        print('Failed to send to MySQL. Status: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error send to MySQL: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Stock Opname' : 'Tambah Stock Opname',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
          onTap: _isLoading ? null : simpanData,
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
                  : Text(
                      isEdit ? "UPDATE DATA" : "SIMPAN DATA",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Produk Autocomplete
        buildProdukAutocomplete('nama_barang', 'Nama Produk'),

        // Stok Sistem (Read-only)
        _buildReadOnlyField(
          'Stok Sistem',
          stokSistem?.toStringAsFixed(0) ?? '-',
          Icons.inventory_2,
        ),

        // Tanggal
        buildDateField('Tanggal', _tanggalController, Icons.calendar_today),

        // Stok Fisik
        buildField(
            'Stok Fisik', _stokFisikController, Icons.format_list_numbered,
            keyboard: TextInputType.number),

        // Selisih (Auto-calculated)
        _buildSelisihField(),

        // Keterangan
        buildField('Keterangan', _keteranganController, Icons.notes),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        readOnly: true,
        controller: TextEditingController(text: value),
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
      ),
    );
  }

  Widget _buildSelisihField() {
    double? selisihValue = selisih;
    Color selisihColor = selisihValue == null
        ? Colors.grey
        : selisihValue < 0
            ? Colors.red
            : selisihValue > 0
                ? Colors.green
                : Colors.blue;

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selisihColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: selisihColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(
              selisihValue == null
                  ? Icons.help_outline
                  : selisihValue < 0
                      ? Icons.trending_down
                      : selisihValue > 0
                          ? Icons.trending_up
                          : Icons.check_circle,
              color: selisihColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selisih',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selisihValue == null
                        ? '-'
                        : selisihValue.toStringAsFixed(0),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: selisihColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProdukAutocomplete(String kolom, String label) {
    if (isEdit) {
      return _buildReadOnlyField(
        label,
        selectedProdukNama ?? '-',
        Icons.inventory,
      );
    }

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
          selectedProdukKode = option['kode'];
          selectedProdukNama = option[kolom];
          stokSistem = double.tryParse(option['stok']?.toString() ?? '0') ?? 0;
          _produkController.text = option[kolom];
        });
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        _produkController = controller;

        return Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: const Icon(Icons.inventory),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        );
      },
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

  Widget buildField(
    String hint,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
  }) {
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
        onChanged: (_) => hitungSelisih(),
      ),
    );
  }

  @override
  void dispose() {
    _tanggalController.dispose();
    _keteranganController.dispose();
    _stokFisikController.dispose();
    // _produkController is managed by Autocomplete, don't dispose it here
    super.dispose();
  }
}
