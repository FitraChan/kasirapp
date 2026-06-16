import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:kasirapp/model/currencyFormatter.dart';

import 'package:kasirapp/model/produkModel.dart';
import 'package:kasirapp/master_data/master.dart';
import 'package:kasirapp/master_data/tambahProduk.dart';

import 'package:kasirapp/master_data/editProduk.dart';
import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:kasirapp/network_utils/api.dart';
import 'package:kasirapp/screen/cobaDetail.dart';

import 'package:kasirapp/screen/home.dart';
import 'package:kasirapp/sync/restoreAll.dart';
import 'package:intl/intl.dart';
import 'package:kasirapp/sync/syncServiceKategori.dart';
import 'package:kasirapp/sync/syncServiceProduk.dart';
import 'package:kasirapp/sync/syncServicePkAc.dart';

import 'package:kasirapp/transaksi/stockOpname.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../screen/menu1.dart';

class Produk extends StatefulWidget {
  const Produk({Key? key, required this.title, required this.tambah})
      : super(key: key);
  final String title;
  final int tambah;
  @override
  _ProdukState createState() => _ProdukState();
}

class _ProdukState extends State<Produk> {
  //TextEditingController teSeach = TextEditingController();
  final PagingController<int, Map<String, dynamic>> _pagingController =
      PagingController(firstPageKey: 0);

  String? _dropdownError;
  String? _mySelection;
  KasirHelper? helper;
  Image? image;
  List<ProdukModel>? images;

  bool click = true;

  List filteredNames = [];

  bool _isLoading = true;
  var items = [];
  int jumlah = 0;
  var transactions = [];
  var pembayaran = [];

  var detailTransactions = [];
  var allProduk = [];

  var semuaProduk = [];
  var allKategori = [];
  var allTransaksi = [];
  var allDetailTransaksi = [];
  var allPembayaran = [];
  var Katitems = [];

  //bool loadData = true;
  List dataKat = [];

  void _refreshProduk() async {
    if (helper != null) {
      helper!.allProduk().then((product) {
        setState(() {
          allProduk = product;
          items = allProduk;
          _isLoading = false;
        });
      });
    }
  }

  bool sudahSync = false;
  bool sudahSyncPkAc = false;

  int selectedKategori = 0; // contoh default id_kategori
  String? selectedProduk;
  final syncServiceProduk = SyncServiceProduk();
  final syncServiceKategori = SyncServiceKategori();
  final syncServicePkAc = SyncServicePkAc();
  var jumlahKategori = 0;
  var jumlahPkAc = 0;

  bool sudahSyncKategori = false;

  var kodeToko;
  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    // super.initState();
    helper = KasirHelper();

    //  _loadData();
    _refreshProduk();

    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey, selectedKategori, _currentSearch, selectedProduk);
    });

    int jumlah = await helper!.countProduk();

    if (!sudahSync) {
      sudahSync = true;

      if (jumlah == 0) {
        await syncServiceProduk.syncAllServer();
      } else {
        await syncServiceProduk.syncProduk();
      }

      _refreshProduk();
      _pagingController.refresh();
    }

    int jumlahKategori = await helper!.countKategori();

    if (!sudahSyncKategori && jumlahKategori == 0) {
      sudahSyncKategori = true;
      await syncServiceKategori.syncAll();
    }
    SharedPreferences pref = await SharedPreferences.getInstance();

    kodeToko = pref.getString('kode_toko');

    if (kodeToko == '00001') {
      int jumlahPkAc = await helper!.countPkAc(); // sudah return int

      if (!sudahSyncPkAc) {
        sudahSyncPkAc = true;

        if (jumlahPkAc == 0) {
          await syncServicePkAc.syncAll();
        }
      }

      await syncServicePkAc.syncPkAc();
      helper!.allPkAc().then((courses) {
        setState(() {
          allKategori = courses;
          allKategori = [
            {'id': 0, 'nama': 'All'}, // Tambahkan ini di awal
            ...courses,
          ];
          Katitems = allKategori;
          _isLoading = false;
        });
      });
    } else {
      await syncServiceKategori.syncKategori();

      helper!.allCategori().then((courses) {
        setState(() {
          allKategori = courses;

          allKategori = [
            {'id': 0, 'nama_kategori': 'All'}, // Tambahkan ini di awal
            ...courses,
          ];
          Katitems = allKategori;
          _isLoading = false;
        });
      });
    }
    helper!.allNamaProduk().then((product) {
      setState(() {
        allProduk = product;
        items = allProduk;

        _isLoading = false;
      });
    });
    // }

    helper!.allTransaksiPembelian().then((courses) {
      setState(() {
        allTransaksi = courses;
        transactions = allTransaksi;
        _isLoading = false;
      });
    });
  }

  Timer? _debounce;
  String _currentSearch = '';
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _currentSearch = query;
      });
      _pagingController.refresh(); // refresh paginated list
    });
  }

  Future<void> _fetchPage(int pageKey, kat, keyword, produk) async {
    try {
      final newItems = await helper!.allProdukPageKeyword(
          itemsPerPage, pageKey, kat, keyword, produk ?? "");
      // newItems.clear();
      final isLastPage = newItems.length < itemsPerPage;
      if (!mounted) return; // Cegah update setelah dispose
      //  _pagingController.refresh(); // trigger fetch data dari awal
      if (isLastPage) {
        // _pagingController.clear();
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + itemsPerPage;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  void _changeKategori(int newKat) {
    selectedKategori = newKat;
    _pagingController.refresh(); // trigger fetch data dari awal
  }

  void _changeProduk(String produk) {
    selectedProduk = produk;
    _pagingController.refresh(); // trigger fetch data dari awal
  }

  KasirHelper helpers = KasirHelper();
  var newData;
  final int itemsPerPage = 20;
  int currentPage = 0;

  var listPenjualan = [];

  bool isLoading = false;

  Future<int> createProduk(ProdukModel kat) async {
    final dbClient = KasirHelper.db;
    // Database? db = await createDatabase();

    return dbClient!.insert('tb_produk', kat.toMap());
  }

  restoreToMysql() async {
    await syncServiceProduk.syncAllServer();
    await syncServiceKategori.syncAll();
    _refreshProduk();
    _pagingController.refresh();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    // teSeach.dispose(); // <- jika kamu pakai ini
    _debounce?.cancel(); // <- juga aman dibatalkan di sini
    super.dispose();
  }

  String selectedBrand = "Nike";
  int? selectedIndex;
  int? selectedIndexProduk;

  String? selectedBrandProduk;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Color(0xFFF6F7FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.restore),
                    onPressed: () {
                      restoreToMysql();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.inventory_2),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const StockOpname(title: 'Stock Opname')),
                      );
                    },
                    tooltip: 'Stock Opname',
                  ),
                  IconButton(
                    icon: const Icon(Icons.home),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Home(
                                  title: '',
                                )),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text("Perfect Dress",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              Text("For perfect style",
                  style: TextStyle(color: Colors.grey[600])),

              // Search Bar
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _onSearchChanged(value);
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "Search for dress",
                          border: InputBorder.none,
                          icon: Icon(Icons.search),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: Colors.deepOrange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.tune, color: Colors.white),
                  ),
                ],
              ),

              // Brand Filter
              SizedBox(height: 20),
              SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: allKategori.length,
                  itemBuilder: (context, index) {
                    // ProdukModel? course = ProdukModel.fromMap(_data[index]);

                    final brand = allKategori[index]['nama_kategori'] ??
                        allKategori[index]['nama'];
                    final isSelected = selectedBrand == brand;

                    bool pilih = selectedIndex == index;
                    // bool isSelected = selectedIndex == index;

                    return GestureDetector(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(brand),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              selectedBrand = brand;

                              selectedIndex = index;

                              _changeKategori(allKategori[index]['id']);
                            });
                          },
                          selectedColor: Colors.deepOrange,
                          backgroundColor: Colors.grey[200],
                          labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black),
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 16),

              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedBrandProduk,
                    hint: const Text(
                      "Pilih Brand",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down,
                        color: Color.fromARGB(255, 22, 21, 20)),
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    items: [
                      const DropdownMenuItem<String>(
                        value: "ALL",
                        child: Text(
                          "Semua Produk",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                      ...items.map((produk) {
                        return DropdownMenuItem<String>(
                          value: produk['kode'].toString(),
                          child: Text(
                            produk['nama_barang'],
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        print(selectedBrandProduk);
                        print(value);
                        selectedBrandProduk = value;
                      });

                      if (value == "ALL") {
                        // tampilkan semua produk
                        _changeProduk("");
                      } else {
                        // filter berdasarkan produk dipilih
                        _changeProduk(value!);
                      }
                    },
                  ),
                ),
              ),

              // Products Grid
              SizedBox(height: 16),
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : Expanded(
                      child: PagedGridView<int, Map<String, dynamic>>(
                      pagingController: _pagingController,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.68,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      builderDelegate:
                          PagedChildBuilderDelegate<Map<String, dynamic>>(
                        itemBuilder: (context, item, index) {
                          ProdukModel course = ProdukModel.fromMap(item);

                          var jml = item['jml'];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditProduk(produkModel: course),
                                ),
                              );
                            },
                            onLongPress: () {
                              showAlertDialog(
                                  context, item['id'], item['kode']);
                            },
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(children: [
                                    ClipRRect(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(8)),
                                        child: course.gambar != ""
                                            ? UtilityProduk
                                                .imageFromBase64String(
                                                    course.gambar!)
                                            : Image.asset(
                                                'images/no_image.png')),
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 5, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: course.stok! <= 3
                                              ? Colors.redAccent
                                              : Colors.deepOrange,
                                          borderRadius: BorderRadius.only(
                                            bottomRight: Radius.circular(12),
                                          ),
                                        ),
                                        child: Text(
                                          'Stok: ${course.stok}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 6),
                                    child: Text(
                                      '${course.namaBarang}',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: Text(
                                      '${currencyFormatter.format(course.hargaJual.toString())}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // KIRI: Icon love
                                        Row(
                                          children: [
                                            Icon(Icons.favorite_border,
                                                size: 14,
                                                color: Colors.grey[600]),
                                          ],
                                        ),

                                        // KANAN: Rating + Jumlah terjual
                                        Row(
                                          children: [
                                            Icon(Icons.star,
                                                size: 12, color: Colors.amber),
                                            SizedBox(width: 2),
                                            Text(
                                              4.5.toStringAsFixed(1),
                                              style: TextStyle(fontSize: 12),
                                            ),
                                            SizedBox(width: 6),
                                            Text(
                                              "| " +
                                                  jml.toString() +
                                                  " Item Sold",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600]),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  kodeToko == '00001'
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 7),
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                                'PK : ' +
                                                    item['nama_pk'].toString(),
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600])),
                                          ))
                                      : Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 7),
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                                'Kategori : ' +
                                                    item['nama_kategori']
                                                        .toString(),
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600])),
                                          )),

                                  SizedBox(height: 4),
                                  // Padding(
                                  //   padding: const EdgeInsets.symmetric(
                                  //       horizontal: 2),
                                  //   child: Align(
                                  //     alignment: Alignment.centerRight,
                                  //     child: TextButton(
                                  //       onPressed: () {
                                  //         Navigator.push(
                                  //           context,
                                  //           MaterialPageRoute(
                                  //             builder: (context) => CobaDetail(
                                  //               id: course.id ?? 0,
                                  //             ),
                                  //           ),
                                  //         );
                                  //       },
                                  //       child: Row(
                                  //         mainAxisSize: MainAxisSize.min,
                                  //         children: [
                                  //           Icon(Icons.info_outline,
                                  //               size: 12,
                                  //               color: Colors.grey[700]),
                                  //           SizedBox(width: 4),
                                  //           Text(
                                  //             'Detail',
                                  //             style: TextStyle(
                                  //                 fontSize: 12,
                                  //                 color: Colors.grey[700]),
                                  //           ),
                                  //         ],
                                  //       ),
                                  //       style: TextButton.styleFrom(
                                  //         padding: EdgeInsets.symmetric(
                                  //             horizontal: 6, vertical: 2),
                                  //         minimumSize: Size(0, 0),
                                  //         tapTargetSize:
                                  //             MaterialTapTargetSize.shrinkWrap,
                                  //         backgroundColor: Colors.grey[100],
                                  //         shape: RoundedRectangleBorder(
                                  //           borderRadius:
                                  //               BorderRadius.circular(4),
                                  //         ),
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TambahProduk(
                      dariBarangMasuk: 0,
                    )),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white, // makes the icon white
      ),
    );
  }

  final currencyFormatter = CurrencyFormatter();
  showAlertDialog(BuildContext context, int id, String kode) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Yes"),
      onPressed: () {
        _deleteItem(id, kode);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("AlertDialog"),
      content: const Text("Apa Yakin Anda Akan Menghapus?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _deleteItem(int id, String kode) async {
    await helper!.deleteProduk(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a Produk!'),
    ));
    //  _refreshProduk();

    Navigator.of(context).pop(false);

    sendToMysql(kode);

    _pagingController.refresh(); // refresh paginated list
  }

  void sendToMysql(id) async {
    // imageFile = File(imagePath!);

    String url;

    url = 'delete_produk/$id';

    // final response = await htpp.post(Uri.parse(url), body: data);
    final response = await Network().getData_get(url);
    // var c = json.decode(response.body);

    if (response.statusCode == 200) {
      print('sukses');
    } else {
      print(response.body);
      throw Exception('Failed to load album');
    }
  }
}

class UtilityProduk {
  static Image imageFromBase64String(String base64String) {
    return Image.memory(
      base64Decode(base64String),
      fit: BoxFit.cover,
      height: 120,
      width: double.infinity, // pastikan ditambahkan
    );
  }
}
