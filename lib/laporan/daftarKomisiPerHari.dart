import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kasirapp/model/rupiahCurrency.dart';
import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:kasirapp/model/currencyFormatter.dart';
import 'package:kasirapp/network_utils/api.dart';
import 'package:kasirapp/screen/home.dart';

class DaftarTransaksi extends StatefulWidget {
  const DaftarTransaksi({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _DaftarTransaksiState createState() => _DaftarTransaksiState();
}

class _DaftarTransaksiState extends State<DaftarTransaksi> {
  KasirHelper? helper;
  final currencyFormatter = CurrencyFormatter();
  bool _isLoading = true;
  Map<int, TextEditingController> komisiControllers = {};
  Set<int> loadingIndexes = {};

  DateTime? selectedDate;
  final TextEditingController dateController = TextEditingController();
  var tang;

  @override
  void initState() {
    super.initState();
    helper = KasirHelper();

    _loadTransaksi(tang);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dateController.text = "${picked.day.toString().padLeft(2, '0')}-"
            "${picked.month.toString().padLeft(2, '0')}-"
            "${picked.year}";
      });

      _loadDataByDate(); // kalau mau langsung reload
    }
  }

  Future<void> _loadDataByDate() async {
    if (selectedDate == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      _loadTransaksi(selectedDate);
      // panggil API atau filter list lokal
      //   print("Load data tanggal: $selectedDate");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List listKomisi = [];

  int _currentPage = 0;
  int _rowsPerPage = 15;

  final rupiahFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  void _loadTransaksi(tang) async {
    try {
      String url;
      var date = DateTime.parse(DateTime.now().toString());

      var tanggalNow = DateFormat('yyyy-MM-dd').format(date);

      if (tang != null) {
        String formattedDate = DateFormat('yyyy-MM-dd').format(tang);
        url = '${'showKomisi/' + formattedDate}';
      } else {
        url = 'showKomisi/$tanggalNow';
      }
      //var url = 'showKomisi';
      final response = await Network().getData_get(url);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List dataList = jsonResponse['data'];

        setState(() {
          listKomisi = dataList;

          // ✅ INIT CONTROLLER DI SINI
          komisiControllers.clear();
          for (int i = 0; i < listKomisi.length; i++) {
            final item = listKomisi[i];
            final total = int.tryParse(item['total_transaksi'].toString()) ?? 0;

            komisiControllers[i] = TextEditingController(
              text: rupiahFormat.format(total),
            );
          }

          _isLoading = false;
        });
      } else {
        print(response.body);
      }
    } catch (e) {
      print('Error loading transaksi: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List get paginatedData {
    final start = _currentPage * _rowsPerPage;
    final end = start + _rowsPerPage;
    return listKomisi.sublist(
      start,
      end > listKomisi.length ? listKomisi.length : end,
    );
  }

  String removeCurrencyFormat(String formattedValue) {
    // Hapus semua karakter yang bukan angka
    String cleanValue = formattedValue.replaceAll(RegExp(r'[^\d]'), '');

    return cleanValue;
  }

  void _saveKomisi(int index) async {
    setState(() {
      loadingIndexes.add(index);
    });
    final komisiValue = komisiControllers[index]?.text ?? '0';

    final komisiCleaned = komisiValue.replaceAll(RegExp(r'[^0-9]'), '');

    final item = listKomisi[index];
    final idKomisi =
        item['id'] ?? item['id_komisi']; // Ambil id komisi dari item

    Map data = {
      'id_komisi': idKomisi, // ✅ Tambahkan ini
      'total_transaksi': komisiCleaned,
    };
    try {
      // Update local list
      listKomisi[index]['total_transaksi'] = komisiCleaned;
      final response = await Network().getData_post(data, 'simpanKomisi');

      if (response.statusCode == 200) {
        await helper!.sync(item['id'], 'id', 'tb_komisi_penjualan');

        setState(() {
          loadingIndexes.remove(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Komisi berhasil diperbarui')),
        );
      } else {
        setState(() {
          loadingIndexes.remove(index);
        });
        print(response.body);
        throw Exception('Failed to load album');
      }

      setState(() {});
    } catch (e) {
      setState(() {
        loadingIndexes.remove(index);
      });
      print('Error saving komisi: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void dispose() {
    // Dispose semua TextEditingController
    for (var controller in komisiControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Home(title: "")),
          );
          return Future.value(true);
        },
        child: Scaffold(
            backgroundColor: const Color(0xFFF5F6FA),
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.red[900],
              title: const Text(
                'Daftar Transaksi',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
            ),
            body: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildContent()));
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterSection(),
          const SizedBox(height: 20),
          _buildTableSection(),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.red),
            const SizedBox(width: 10),
            SizedBox(
              width: 200,
              child: TextField(
                controller: dateController,
                readOnly: true,
                onTap: _pickDate,
                decoration: InputDecoration(
                  hintText: "Pilih Tanggal",
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableSection() {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(Colors.red[50]),
                    dataRowHeight: 60,
                    headingTextStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    columns: const [
                      DataColumn(label: Text('No')),
                      DataColumn(label: Text('Nama')),
                      DataColumn(label: Text('Qty')),
                      DataColumn(label: Text('Harga')),
                      DataColumn(label: Text('Komisi')),
                      DataColumn(label: Text('Gambar')),
                      DataColumn(label: Text('Aksi')),
                    ],
                    rows: List.generate(
                      paginatedData.length,
                      (index) {
                        final item = paginatedData[index];
                        final realIndex = _currentPage * _rowsPerPage + index;

                        var harga = item['harga_jual'] == null
                            ? ""
                            : item['harga_jual'];

                        return DataRow(
                          cells: [
                            DataCell(Text('${realIndex + 1}')),
                            DataCell(Text(item['nama_user'] ?? '-')),
                            DataCell(Text('${item['qty'] ?? 0}')),
                            DataCell(
                              Text(
                                'Rp${currencyFormatter.format(harga)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: 120,
                                child: TextFormField(
                                  controller: komisiControllers[realIndex],
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    CurrencyInputFormatter(),
                                  ],
                                  decoration: const InputDecoration(
                                    hintText: 'Rp 0',
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              item['gambar'] != null && item['gambar'] != ''
                                  ? InkWell(
                                      onTap: () {
                                        showImageDialog(
                                            context, item['gambar']);
                                      },
                                      child: Text(
                                        "detail",
                                        style: TextStyle(
                                          color: Colors.blue,
                                        ),
                                      ),
                                    )
                                  : const Text('-'),
                            ),
                            DataCell(
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,

                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  disabledBackgroundColor:
                                      Colors.blue, // tetap biru
                                  disabledForegroundColor:
                                      Colors.white, // teks tetap putih
                                ),
                                onPressed: loadingIndexes.contains(realIndex)
                                    ? null
                                    : () => _saveKomisi(realIndex),
                                child: loadingIndexes.contains(realIndex)
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Simpan'),
                              ),
                            )
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _buildPagination(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          onPressed:
              _currentPage > 0 ? () => setState(() => _currentPage--) : null,
          icon: const Icon(Icons.chevron_left),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Page ${_currentPage + 1} / ${(listKomisi.length / _rowsPerPage).ceil()}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        IconButton(
          onPressed: (_currentPage + 1) * _rowsPerPage < listKomisi.length
              ? () => setState(() => _currentPage++)
              : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  void showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InteractiveViewer(
            panEnabled: true,
            minScale: 0.5,
            maxScale: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Gambar gagal dimuat'),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
