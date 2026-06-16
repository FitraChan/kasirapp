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

class KomisiUser extends StatefulWidget {
  const KomisiUser({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _KomisiUserState createState() => _KomisiUserState();
}

class _KomisiUserState extends State<KomisiUser> {
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

  List listKomisi = [];

  int _currentPage = 0;
  int _rowsPerPage = 5;

  void _loadTransaksi(tang) async {
    try {
      String url;
      var date = DateTime.parse(DateTime.now().toString());

      var tanggalNow = DateFormat('yyyy-MM-dd').format(date);

      if (tang != null) {
        String formattedDate = DateFormat('yyyy-MM-dd').format(tang);
        url = '${'komisiUser/' + formattedDate}';
      } else {
        url = 'komisiUser/$tanggalNow';
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
            komisiControllers[i] = TextEditingController(
              text: listKomisi[i]['total_transaksi']?.toString() ?? '',
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
          appBar: AppBar(
            title: const Text('Daftar Transaksi'),
            backgroundColor: Colors.red[900],
            leading: IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const Home(title: "")),
                );
              },
            ),
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(children: [
                  /// ===== FILTER TANGGAL =====
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Text(
                          "Filter Bulan:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 180,
                          child: TextField(
                            controller: dateController,
                            readOnly: true,
                            onTap: () {
                              _onPressed(context: context);
                            },
                            decoration: InputDecoration(
                              hintText: "Pilih Bulan",
                              suffixIcon: const Icon(Icons.calendar_today),
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        children: [
                          DataTable(
                              columnSpacing: 14, // makin kecil = makin mepet
                              horizontalMargin: 8,
                              columns: const [
                                DataColumn(label: Text('No')),
                                DataColumn(label: Text('Nama')),
                                DataColumn(label: Text('Qty')),
                                DataColumn(label: Text('Harga Jual')),
                                DataColumn(label: Text('Komisi')),
                                DataColumn(label: Text('Gambar')),
                              ],
                              rows: List.generate(
                                paginatedData.length,
                                (index) {
                                  final item = paginatedData[index];
                                  final realIndex =
                                      _currentPage * _rowsPerPage + index;

                                  var totTransaksi =
                                      item['total_transaksi'] == null
                                          ? ""
                                          : item['total_transaksi'];

                                  // komisiControllers[realIndex]!.text =
                                  //     currencyFormatter.format(
                                  //         komisiControllers[realIndex]?.text ??
                                  //             '0');

                                  return DataRow(
                                    cells: [
                                      DataCell(Text('${realIndex + 1}')),
                                      DataCell(Text(item['nama_user'] ?? '-')),
                                      DataCell(Text('${item['qty'] ?? 0}')),
                                      DataCell(
                                        Text(
                                          'Rp${currencyFormatter.format(item['harga_jual'] ?? 0)}',
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          'Rp${currencyFormatter.format(totTransaksi ?? 0)}',
                                        ),
                                      ),
                                      DataCell(
                                        item['gambar'] != null &&
                                                item['gambar'] != ''
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
                                    ],
                                  );
                                },
                              )),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: _currentPage > 0
                                    ? () => setState(() => _currentPage--)
                                    : null,
                                icon: const Icon(Icons.chevron_left),
                              ),
                              Text(
                                'Page ${_currentPage + 1} / ${(listKomisi.length / _rowsPerPage).ceil()}',
                              ),
                              IconButton(
                                onPressed: (_currentPage + 1) * _rowsPerPage <
                                        listKomisi.length
                                    ? () => setState(() => _currentPage++)
                                    : null,
                                icon: const Icon(Icons.chevron_right),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ])),
    );
  }

  var bulan;

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
