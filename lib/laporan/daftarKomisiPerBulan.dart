import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kasirapp/model/rupiahCurrency.dart';
import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:kasirapp/model/currencyFormatter.dart';
import 'package:kasirapp/network_utils/api.dart';
import 'package:kasirapp/screen/home.dart';
import 'package:month_year_picker/month_year_picker.dart';

class DaftarTransaksiBulanan extends StatefulWidget {
  const DaftarTransaksiBulanan({Key? key, required this.title})
      : super(key: key);
  final String title;

  @override
  _DaftarTransaksiBulananState createState() => _DaftarTransaksiBulananState();
}

class _DaftarTransaksiBulananState extends State<DaftarTransaksiBulanan> {
  KasirHelper? helper;
  final currencyFormatter = CurrencyFormatter();
  bool _isLoading = true;
  Map<int, TextEditingController> komisiControllers = {};
  Set<int> loadingIndexes = {};

  DateTime? selectedDate;
  final TextEditingController dateController = TextEditingController();
  var tang;
  var bulan;

  @override
  void initState() {
    super.initState();
    helper = KasirHelper();

    _loadTransaksi(tang);
  }

  // Future<void> _pickDate() async {
  //   final picked = await showDatePicker(
  //     context: context,
  //     initialDate: selectedDate ?? DateTime.now(),
  //     firstDate: DateTime(2020),
  //     lastDate: DateTime(2100),
  //   );

  //   if (picked != null) {
  //     setState(() {
  //       selectedDate = picked;
  //       dateController.text = "${picked.day.toString().padLeft(2, '0')}-"
  //           "${picked.month.toString().padLeft(2, '0')}-"
  //           "${picked.year}";
  //     });

  //     _loadDataByDate(); // kalau mau langsung reload
  //   }
  // }

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
        //String formattedDate = DateFormat('yyyy-MM-dd').format(tang);
        url = '${'showKomisiBulanan/' + tang}';
      } else {
        url = 'showKomisiBulanan/$tanggalNow';
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

  DateTime? _selected;
  var tanggals;
  Future<void> _onPressed({
    required BuildContext context,
    String? locale,
  }) async {
    final localeObj = locale != null ? Locale(locale) : null;
    final selected = await showMonthYearPicker(
      context: context,
      initialDate: _selected ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: localeObj,
    );

    if (selected != null) {
      setState(() {
        _selected = selected;

        var dates = DateTime.parse(_selected.toString());

        tanggals = DateFormat('yMMMM').format(dates);
        bulan = DateFormat('yyyy-MM-dd').format(dates);

        _loadTransaksi(bulan);
      });
    }
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
          backgroundColor: const Color(0xFFF4F6F9),
          appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            backgroundColor: Colors.red[900],
            title: const Text(
              'Daftar Transaksi Bulanan',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildContent(),
        ));
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFilterCard(),
          const SizedBox(height: 20),
          Expanded(child: _buildTableCard()),
        ],
      ),
    );
  }

  Widget _buildFilterCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, color: Colors.red),
            const SizedBox(width: 12),
            SizedBox(
              width: 200,
              child: TextField(
                controller: dateController,
                readOnly: true,
                onTap: () => _onPressed(context: context),
                decoration: InputDecoration(
                  hintText: "Pilih Bulan",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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

  Widget _buildTableCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
                child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical, // 👉 Scroll atas bawah

                child: DataTable(
                  columnSpacing: 24,
                  horizontalMargin: 16,
                  dataRowHeight: 60,
                  headingRowHeight: 55,
                  headingRowColor:
                      MaterialStateProperty.all(Colors.red.shade50),
                  headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  columns: const [
                    DataColumn(label: Text('No')),
                    DataColumn(label: Text('Nama')),
                    DataColumn(label: Text('Qty')),
                    DataColumn(label: Text('Harga Jual')),
                    DataColumn(label: Text('Komisi')),
                    DataColumn(label: Text('Gambar')),
                    DataColumn(label: Text('Aksi')),
                  ],
                  rows: List.generate(
                    paginatedData.length,
                    (index) {
                      final item = paginatedData[index];
                      final realIndex = _currentPage * _rowsPerPage + index;
                      var harga =
                          item['harga_jual'] == null ? "" : item['harga_jual'];
                      return DataRow(
                        cells: [
                          DataCell(Text('${realIndex + 1}')),
                          DataCell(Text(item['nama_user'] ?? '-')),
                          DataCell(Text('${item['qty'] ?? 0}')),
                          DataCell(
                            Text(
                              'Rp${currencyFormatter.format(harga)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
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
                                    onTap: () => showImageDialog(
                                        context, item['gambar']),
                                    child: const Text(
                                      "Detail",
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.w500),
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
            )),
            const SizedBox(height: 10),
            _buildPaginationModern(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationModern() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          onPressed:
              _currentPage > 0 ? () => setState(() => _currentPage--) : null,
          icon: const Icon(Icons.chevron_left),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
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
