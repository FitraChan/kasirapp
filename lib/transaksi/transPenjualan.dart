import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:kasirapp/master_data/tambahProduk.dart';
import 'package:kasirapp/provider/counter_provider.dart';
import 'package:intl/intl.dart';
import 'package:kasirapp/provider/produk_profider.dart';
import 'package:kasirapp/provider/idTransaksi_provider.dart';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kasirapp/sync/syncServiceKategori.dart';
import 'package:kasirapp/sync/syncServicePkAc.dart';
import 'package:kasirapp/sync/syncServiceProduk.dart';
import 'package:kasirapp/transaksi/pembayaranHutang.dart';
import 'package:kasirapp/transaksi/pembayaranPesanDidepan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kasirapp/model/currencyFormatter.dart';

import 'package:kasirapp/model/produkModel.dart';
import 'package:kasirapp/model/rupiahCurrency.dart';
import 'package:kasirapp/model/subTransaksiDetailPembelianModel.dart';
import 'package:kasirapp/model/transaksiDetailPembelianModel.dart';
import 'package:intl/intl.dart';
import 'package:kasirapp/network_utils/api.dart';
import 'package:kasirapp/screen/home.dart';
import 'package:kasirapp/screen/login.dart';
import 'package:kasirapp/screen/menu2.dart';
import 'package:kasirapp/sync/print.dart';
import 'package:kasirapp/transaksi/detailPembelian.dart';
import 'package:kasirapp/transaksi/penjualan.dart';
import 'package:kasirapp/transaksi/pembayaranTunai.dart';

import 'package:carousel_slider/carousel_slider.dart';

import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:kasirapp/transaksi/print_pemesanan.dart';

import '../screen/menu1.dart';

//import 'package:dio/dio.dart';

class TransPenjualan extends ConsumerStatefulWidget {
  // idPembayara = 2 artinya pembayaran di depan
  // selain itu mboh..
  const TransPenjualan(
      {Key? key,
      required this.tanggal,
      required this.delivery,
      required this.idPembayaran})
      : super(key: key);
  final String tanggal;
  final String delivery;
  final int idPembayaran; // Default pembayaran

  @override
  //_TransPenjualanState createState() => _TransPenjualanState();

  ConsumerState<ConsumerStatefulWidget> createState() => _TransPenjualanState();
}

class _TransPenjualanState extends ConsumerState<TransPenjualan> {
  final TextEditingController _filter = TextEditingController();

  final PagingController<int, Map<String, dynamic>> _pagingController =
      PagingController(firstPageKey: 0);
  String? email;
  //String? nim;
  String? notificationText;
  String? kewajiban;
  String? bayar;
  String? tunggakan;
  String? _dropdownError;
  String? _mySelection;
  var Katitems = [];

  var produkScanResult = [];
  var allKategori = [];
  TextEditingController scan = TextEditingController();

  var allDetailTrans = [];
  var DetailTrans = [];
  KasirHelper? helper;
  TextEditingController teSeach = TextEditingController();
  TextEditingController plusMinus = TextEditingController();
  // TextEditingController plusMinusToping = TextEditingController();

  List<TextEditingController> plusMinusToping = [];
  TextEditingController inputHarga = TextEditingController();
  // late TextEditingController diskon = TextEditingController();
  TextEditingController priceAfterDiscount = TextEditingController();
  TextEditingController subTotal = TextEditingController();
  TextEditingController namaTransaksi = TextEditingController();
  TextEditingController catatan = TextEditingController();
  String? drop = "";
  final TextEditingController _searchController = TextEditingController();
  AutoCompleteTextField<Item>? _autoCompleteTextField;

  GlobalKey<AutoCompleteTextFieldState<Item>> key = GlobalKey();

  //List<GlobalKey<AutoCompleteTextFieldState<Item>>> key = List.generate(10, (index) => GlobalKey());

  List names = [];
  var items = [];

  var produkDropdown = [];

  List filteredNames = [];
  //var allProduk = [];
  var allPembayaran = [];
  var pembayaran = [];
  var count;
  var createdAt;
  var countDisc;
  var idTransaksiForBayar;
  var scanResult;

  var allSubPembayaran = [];
  var subPembayaran = [];
  var subCount;

  bool _isLoading = false;
  bool _isLoadingProduk = false;
  String? tot;
  String? kode;
  final oCcy = NumberFormat.decimalPattern();

  bool loadData = true;
  bool _showItemBuilder = true;

  final _streamController = StreamController<int>();
  final _streamControllerToping = StreamController<int>();

  Stream<int> get _stream => _streamController.stream;
  Stream<int> get _streamToping => _streamControllerToping.stream;

  Sink<int> get _sink => _streamController.sink;
  int initValue = 1;
  List data = [];

  List<Map<String, dynamic>> dataProduk = [];

  List<Map<String, dynamic>> additionalData = [];
  int selectedKategori = 0; // contoh default id_kategori
  String? selectedProduk;

  int hasilDiskon = 1;
  var current;
  var currentString;
  //var showJumlahTrx = [];
  var _data = [];
  num totaly = 0;
  String _currentSearch = '';
  var con1; // kategori
  var con2; // pencarian nama produk
  var con3; // stok
  var con4; // kategori dalam container

  final syncServiceProduk = SyncServiceProduk();
  final syncServiceKategori = SyncServiceKategori();

  final syncServicePkAc = SyncServicePkAc();

  var kodeTransaksi;
  var kodeTransaksiPref;
  var allProduk = [];
  @override
  void initState() {
    super.initState();
    _initData();
  }

  bool sudahSync = false;
  var jumlah = 0;
  Future<void> _initData() async {
    helper = KasirHelper();

    konfigurasi();

    ref.read(dynamicListProvider.notifier).fetchJumlahTransaksi();

    ref.read(produkProvider.notifier).produk();

    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey, selectedKategori, _currentSearch, selectedProduk);
    });

    //   Future.delayed(Duration(seconds: 2));
    current = DateTime.parse(DateTime.now().toString());
    currentString = DateFormat('yyyy-MM-dd HH:mm:ss').format(current);

    //await syncKategori();

    // await sync();

    _searchController.addListener(_loadItems);
    _autoCompleteTextField = AutoCompleteTextField<Item>(
      controller: _searchController,
      suggestions: _suggestions,

      clearOnSubmit: false,
      style: const TextStyle(color: Colors.black, fontSize: 15),
      decoration: InputDecoration(
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(20.5))),
      itemFilter: (item, query) =>
          item.name.toLowerCase().contains(query.toLowerCase()),
      itemSorter: (a, b) => a.id.compareTo(b.id),
      //onFocusChanged: _onDropdownChanged,
      itemSubmitted: (item) {
        //  if (item.name != '') {
        // _searchController.clear();
        //}
        setState(() {
          additionalData = [
            {
              'name': item.name,
              'id': item.id,
              'harga': item.harga,
              'kode': item.kode
            }
          ];

          dataProduk.addAll(additionalData);

          Navigator.pop(context);

          showDialogWithCount(kumpulanData[0]);

          _searchController.text = item.name;
          _mySelection = item.id.toString();
          _showItemBuilder = false;
        });

        // Navigator.of(context).pop();
      },
      itemBuilder: (context, item) {
        return _showItemBuilder
            ? Container(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      item.name,
                      style: const TextStyle(color: Colors.black),
                    )
                  ],
                ),
              )
            : Container();
      },
      key: key,
    );

    refreshJumlahPembelian();
    _loadUserData();

    _loadData(0);

    if (widget.idPembayaran == 2) {
      transaksiDiDepan();
    } else {
      catatanToping();
    }
    if (helper != null) {}

    if (helper != null) {
      helper!.showPembelian().then((courses) {
        setState(() {
          allDetailTrans = courses;
          DetailTrans = allDetailTrans;
          if (DetailTrans.isNotEmpty) {
            countDisc = DetailTrans.first['diskon'];
            createdAt = DetailTrans.first['created_at'];
            idTransaksiForBayar = DetailTrans.first['id_transaksi'];
          }
        });
      });
    }

    _sink.add(initValue);
    _stream.listen((event) => plusMinus.text = event.toString());
    // _streamToping.listen((event) => plusMinusToping[0].text = event.toString());

    // normalHarga();
    // hargaGoFood();
    // hargaShopee();

    helper!.pelanggan().then((value) {
      setState(() {
        pelanggan = value;
      });
    });

    helper!.allNamaProduk().then((product) {
      setState(() {
        allProduk = product;
        produkDropdown = allProduk;

        _isLoading = false;
      });
    });

    //super.initState();
  }

  var kodeToko;
  void konfigurasi() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var config1 = localStorage.getString('kategori');
    var config2 = localStorage.getString('pencarian');
    var config3 = localStorage.getString('stok');
    var config4 = localStorage.getString('kategoriDalamContainer');
    kodeToko = localStorage.getString('kode_toko');

    //if (config1 != null && config2 != null && config3 != null && config4 != null) {
    con1 = config1;
    con2 = config2;
    con3 = config3;
    con4 = config4;
    //  } else {

    setState(() {
      con1;
      con2;
      con3;
      con4;
    });

    _isLoading = true;
    // toko ac
    if (kodeToko == '00001') {
      int jumlahPkAc = await helper!.countPkAc(); // sudah return int

      if (jumlahPkAc == 0) {
        await syncServicePkAc.syncAll();
      } else {
        await syncServicePkAc.syncPkAc();
      }

      helper!.allPkAc().then((courses) async {
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
            {'id': 0, 'nama': 'All'}, // Tambahkan ini di awal
            ...courses,
          ];
          Katitems = allKategori;
          _isLoading = false;
        });
      });
    }

    helper!.countProdukList().then((product) async {
      if (!sudahSync) {
        sudahSync = true;
        jumlah = product.first['jumlah'] as int? ?? 0;
        if (jumlah == 0) {
          setState(() {
            _isLoadingProduk = true;
          });
          await syncServiceProduk.syncAllServer();
          setState(() {
            _isLoadingProduk = false;
          });
          _pagingController.refresh();
        } else {
          await syncServiceProduk.syncProduk();
          _pagingController.refresh();
        }
      }
    });

    _isLoading = false;
    _pagingController.refresh();
  }

  var newData;
  final int itemsPerPage = 20;
  int currentPage = 0;
  Future<void> _loadData(kat) async {
    newData = await helpers.allProdukPage(
        itemsPerPage, currentPage * itemsPerPage, kat);
    setState(() {
      _data.clear();
      _data.addAll(newData);
    });
  }

  void _changeKategori(int newKat) {
    selectedKategori = newKat;
    _pagingController.refresh(); // trigger fetch data dari awal
  }

  void _changeProduk(String produk) {
    selectedProduk = produk;
    _pagingController.refresh(); // trigger fetch data dari awal
  }

  Future<void> _fetchPage(int pageKey, kat, keyword, produk) async {
    try {
      final newItems = await helper!.allProdukPageKeyword(
        itemsPerPage,
        pageKey,
        kat,
        keyword,
        produk ?? "",
      );
      // newItems.clear();
      final isLastPage = newItems.length < itemsPerPage;

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

  var allTrans = [];

  var Trans = [];
  int? idTrx = 0;
  var selectDetailPembelian = [];
  List detailTrans = [];
  List allDetailTransaksi = [];
  var p;

  // noteToping2() async {
  //   final data = await helper!.showPembelianAndToping();
  //   setState(() {
  //     _data = data;
  //   });
  // }

  List<List> AllData = [];

  List<List> all = [];

  catatanToping() async {
    try {
      // AllData = [];
      helper!.showPembelianAndToping().then((courses) {
        //  setState(() {

        _isLoading = true;
        allTrans = courses;
        // Trans = [];
        setState(() {
          Trans = allTrans;
        });

        // var id = Trans.first['id'];
        for (var x = 0; x < Trans.length; x++) {
          idTrx = 0;
          idTrx = Trans[x]['id_sub_transaksi'];

          // detailToping(idTrx);

          AllData = [];
          helper!.listSubDetailTransaksi(idTrx).then((cou) {
            selectDetailPembelian = cou;

            for (var a = 0; a < 1; a++) {
              allDetailTransaksi = cou;
              detailTrans = allDetailTransaksi;
              AllData.add(detailTrans);
            }
            setState(() {
              all = AllData;
            });

            //print(AllData);
          });
        }
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        toastLength: Toast
            .LENGTH_SHORT, // Duration for which the toast should be visible
        gravity: ToastGravity.BOTTOM, // Position of the toast on the screen
        // Font size of the message
      );
    }
  }

  transaksiDiDepan() async {
    try {
      // final id = ref.watch(selectedIdTransaksiProvider);

      final id = ref.read(selectedIdTransaksiProvider);

      // AllData = [];
      helper!.showPembelianPemesananDidepan(id).then((courses) {
        //  setState(() {

        _isLoading = true;
        allTrans = courses;
        // Trans = [];
        setState(() {
          Trans = allTrans;
        });

        // var id = Trans.first['id'];
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        toastLength: Toast
            .LENGTH_SHORT, // Duration for which the toast should be visible
        gravity: ToastGravity.BOTTOM, // Position of the toast on the screen
        // Font size of the message
      );
    }
  }

  List dataP = [];
  var a = Container();
  String? selectedBrandProduk;

  List<Item> _suggestions = [];

  void _loadItems() async {
    _showItemBuilder = true;
    final query = _searchController.text.toLowerCase();

    final db = KasirHelper.db;

    final result = await db!.rawQuery(
        'SELECT * FROM tb_produk where nama_barang LIKE  ?', ['%$query%']);

    setState(() {
      _suggestions = result
          .map((e) => Item(
              id: e['id'].toString(),
              name: e['nama_barang'].toString(),
              harga: e['harga_jual'].toString(),
              kode: e['kode'].toString()))
          .toList();
    });

    _autoCompleteTextField?.updateSuggestions(_suggestions);
  }

  normal() async {
    helper!.showPembelian().then((courses) {
      setState(() {
        allDetailTrans = courses;
        DetailTrans = allDetailTrans;
        if (DetailTrans.isNotEmpty) {
          countDisc = DetailTrans.first['diskon'];
          createdAt = DetailTrans.first['created_at'];
          idTransaksiForBayar = DetailTrans.first['id_transaksi'];
        }
      });
    });
  }

  var countTry;

  updateHarga(harga, idBarang, kode, delivery) async {
    helper!.ubahHarga(harga, idBarang, delivery).then((course) {});

    ubahHargaMysql(harga, kode);
  }

  void ubahHargaMysql(harga, idBarang) async {
    Map data = {
      'id_barang': idBarang,
      'harga': harga,
    };

    String url;

    url = 'ubahHarga';

    final response = await Network().getData_post(data, url);
    if (response.statusCode == 200) {
      print('sukses');
    } else {
      print(response.body);
      throw Exception(response);
    }
  }

  var listPenjualan = [];

  // Future<void> syncKategori() async {
  //   try {
  //     String url = 'kategoriSync';

  //     final response = await Network().getData_get(url);
  //     final dbClient = KasirHelper.db;

  //     if (response.statusCode == 200) {
  //       List listKategori = json.decode(response.body);

  //       for (var item in listKategori) {
  //         try {
  //           var id = item['id'];
  //           var kode = item['kode'];
  //           var namaKategori = item['nama_kategori'];
  //           var createdAtMysql = item['created_at'];

  //           // konversi tanggal MySQL → lokal
  //           var dateValue = DateFormat("yyyy-MM-ddTHH:mm:ssZ")
  //               .parseUTC(createdAtMysql)
  //               .subtract(const Duration(hours: 1))
  //               .toLocal();

  //           var tanggalMysql = DateFormat('yyyy-MM-dd HH:mm').format(dateValue);

  //           // cek data di sqlite
  //           final maps = await dbClient!.rawQuery(
  //             "SELECT * FROM tb_kategori WHERE kode = ?",
  //             [kode],
  //           );

  //           if (maps.isNotEmpty) {
  //             var createdAt = maps.first['created_at'];

  //             // update jika tanggal berbeda
  //             if (tanggalMysql != createdAt) {
  //               await dbClient.rawQuery('''
  //               UPDATE tb_kategori
  //               SET
  //                 nama_kategori = ?,
  //                 created_at = ?
  //               WHERE kode = ?
  //             ''', [namaKategori, tanggalMysql, kode]);
  //             }
  //           } else {
  //             // insert data baru
  //             await dbClient.rawQuery('''
  //             INSERT INTO tb_kategori
  //             (id, kode, nama_kategori, created_at)
  //             VALUES (?, ?, ?, ?)
  //           ''', [id, kode, namaKategori, tanggalMysql]);
  //           }
  //         } catch (e) {
  //           print('Error proses kategori: $e');
  //         }
  //       }
  //     } else {
  //       print('API kategori gagal: ${response.body}');
  //     }
  //   } on SocketException catch (_) {
  //     print("Tidak bisa konek ke server");
  //   } on HttpException catch (_) {
  //     print("Server tidak merespon");
  //   } on FormatException catch (_) {
  //     print("Format response salah");
  //   } catch (e) {
  //     print("Error lain: $e");
  //   }
  // }

  // Future<void> sync() async {
  //   final response = await Network().getData_get('produkSync');
  //   final dbClient = KasirHelper.db;

  //   if (response.statusCode != 200) {
  //     throw Exception('Sync gagal');
  //   }

  //   final List serverList = json.decode(response.body);

  //   // ===============================
  //   // 1️⃣ SIMPAN SEMUA KODE SERVER
  //   // ===============================
  //   final Set serverKode = serverList.map((e) => e['kode']).toSet();

  //   // ===============================
  //   // 2️⃣ UPDATE / INSERT
  //   // ===============================
  //   for (final item in serverList) {
  //     final kode = item['kode'];
  //     final hargaJual = item['harga_jual'];
  //     final nama = item['nama_barang'];
  //     final idKategori = item['id_kategori'];
  //     final createdAtMysql = item['created_at'];
  //     final hargaBeli = item['harga_beli'];
  //     final stok = item['stok'];
  //     final gambar = item['gambar'];

  //     String? imgString;

  //     final dateValue = DateFormat("yyyy-MM-ddTHH:mm:ssZ")
  //         .parseUTC(createdAtMysql)
  //         .subtract(const Duration(hours: 1))
  //         .toLocal();

  //     final tanggalMysql = DateFormat('yyyy-MM-dd HH:mm').format(dateValue);

  //     final maps = await dbClient!
  //         .rawQuery("SELECT * FROM tb_produk WHERE kode = ?", [kode]);

  //     if (maps.isNotEmpty) {
  //       final createdAt = maps.first['tanggal_sekarang'];
  //       if (tanggalMysql != createdAt) {
  //         await dbClient.rawQuery('''
  //         UPDATE tb_produk
  //         SET nama_barang = ?, harga_jual = ?, tanggal_sekarang = ?,
  //             id_kategori = ?, harga_beli = ?, stok = ?
  //         WHERE kode = ?
  //       ''', [
  //           nama,
  //           hargaJual,
  //           tanggalMysql,
  //           idKategori,
  //           hargaBeli,
  //           stok,
  //           kode
  //         ]);
  //       }
  //     } else {
  //       if (gambar != null && gambar.isNotEmpty) {
  //         final imgResponse = await http.get(Uri.parse(gambar));
  //         imgString = Utility.base64String(imgResponse.bodyBytes);
  //       }

  //       await dbClient.rawQuery('''
  //       INSERT INTO tb_produk
  //       (kode, harga_jual, nama_barang, id_kategori,
  //        tanggal_sekarang, harga_beli, stok, gambar)
  //       VALUES (?, ?, ?, ?, ?, ?, ?, ?)
  //     ''', [
  //         kode,
  //         hargaJual,
  //         nama,
  //         idKategori,
  //         tanggalMysql,
  //         hargaBeli,
  //         stok,
  //         imgString
  //       ]);
  //     }
  //   }

  //   // ===============================
  //   // 3️⃣ DELETE DATA YANG SUDAH HILANG DI SERVER
  //   // ===============================
  //   final localList = await dbClient!.rawQuery("SELECT kode FROM tb_produk");

  //   final Set localKode = localList.map((e) => e['kode']).toSet();

  //   final kodeHapus = localKode.difference(serverKode);

  //   for (final kode in kodeHapus) {
  //     await dbClient.rawQuery(
  //       "DELETE FROM tb_produk WHERE kode = ?",
  //       [kode],
  //     );
  //   }

  //   // ===============================
  //   // 4️⃣ REFRESH UI SEKALI SAJA
  //   // ===============================
  //   _pagingController.refresh();
  // }

  void refreshJumlahPembelian() async {
    if (helper != null) {
      if (widget.idPembayaran == 2) {
        final id = ref.read(selectedIdTransaksiProvider);

        helper!.hitungPembelianPemesananDiDepan(id).then((course) {
          setState(() {
            allPembayaran = course;
            pembayaran = allPembayaran;
            count = pembayaran.first['harga'];
            createdAt = pembayaran.first['created_at'];
          });
        });
      } else {
        await helper!.hitungPembelian().then((course) async {
          setState(() {
            allPembayaran = course;
            pembayaran = allPembayaran;
            count = pembayaran.first['total'];
            createdAt = pembayaran.first['created_at'];
          });
        });
      }

      helper!.hitungSubPembelian().then((course) {
        setState(() {
          allSubPembayaran = course;
          subPembayaran = allSubPembayaran;
          subCount = subPembayaran.first['harga'];
          createdAt = subPembayaran.first['created_at'];
        });
      });
    }
  }

  void produkScan(kode) async {
    if (helper != null) {
      helper!.selectProdukScan(kode).then((course) {
        setState(() {
          produkScanResult = course;
          scanResult = produkScanResult.first;
        });

        showDialogWithCount(scanResult);
      });
    }
  }

  String? level;

  var idUser;
  _loadUserData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();

    String? existingKode = localStorage.getString('kode_transaksi');

    if (existingKode != null && existingKode.isNotEmpty) {
      // ✅ Pakai transaksi lama
      kodeTransaksi = existingKode;
    } else {
      // ✅ Buat baru kalau belum ada
      kodeTransaksi =
          "TRX-${DateTime.now().millisecondsSinceEpoch.toString().substring(5, 13)}";

      await localStorage.setString('kode_transaksi', kodeTransaksi);
    }

    setState(() {
      kodeTransaksiPref = kodeTransaksi;
    });

    var a = localStorage.getString('user');

    if (a != null) {
      var user = jsonDecode(localStorage.getString('user') ?? '');

      setState(() {
        level = user['level'].toString();
        idUser = user['id'];
      });
    } else {
      // Login();

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    }
  }

  // WidgetRef? ref;

  @override
  Widget build(BuildContext context) {
    var showJumlahTrx = ref.watch(dynamicListProvider);
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return WillPopScope(
        onWillPop: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const Home(
                      title: '',
                    )),
          );
          return Future.value(true);
        },
        child: Scaffold(
          appBar: AppBar(
            elevation: 50,
            //Menambahkan TitleBar
            title: const Text(
              'Penjualan Baru',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            ),
            //Mengubah Warna Background
            backgroundColor: Colors.white,
            //Menambahkan Leading menu
            // leading: Row(
            //   children: [
            //     IconButton(
            //       icon: const Icon(
            //         Icons.delivery_dining_rounded,
            //       ),
            //       onPressed: () {
            //         _showPopupMenu(context);
            //       },
            //     ),
            //   ],
            // ),

            //Menambahkan Beberapa Action Button
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () {
                  showDialogPelanggan();
                },
              ),
              badges.Badge(
                showBadge: showJumlahTrx.isNotEmpty ? true : false,
                position: badges.BadgePosition.topEnd(top: 5, end: 2),
                badgeContent: Text(showJumlahTrx.length.toString()),
                child: IconButton(
                  icon: const Icon(Icons.trolley),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Penjualan(
                                tanggal: currentString,
                              )),
                    );
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  showDialogWithNama();
                  // _refreshProduk();
                  // showDialogWithFields();
                },
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
          drawer: level == '1' ? const Menu() : const Menu2(),
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              SingleChildScrollView(
                // keyboardDismissBehavior:
                //     ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Expanded(
                        //child:
                        Column(
                          children: [
                            namaPelangganWidget(),
                            const SizedBox(height: 5),
                            isPortrait ? contentPotrait() : contentLandScape(),
                            isPortrait
                                ? bottomBayarPotrait()
                                : bottomBayarLandScape(),
                          ],
                        ),
                        // ),
                        isPortrait ? columnCenterPotrait() : columnCenter(),
                      ],
                    ),
                  ],
                ),
              ),
              // Column(
              //   children: [
              //     Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Column(
              //           children: [
              //             namaPelangganWidget(),
              //             SizedBox(height: 5),
              //             isPortrait ? contentPotrait() : contentLandScape(),
              //             isPortrait
              //                 ? bottomBayarPotrait()
              //                 : bottomBayarLandScape(),
              //           ],
              //         ),
              //         isPortrait ? columnCenterPotrait() : columnCenter(),
              //       ],
              //     ),
              //   ],
              // ),

              // 🔥 LOADING OVERLAY
              if (_isLoading || _isLoadingProduk)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.4),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
            ],
          ),
          // ),
          // bottomNavigationBar:
        ));
  }

  String? namaPelanggan;
  int? idPelanggan;

  Widget namaPelangganWidget() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.account_circle, color: Colors.black, size: 17),
        const SizedBox(width: 4),
        Container(
          color: Colors.white,
          child: Text(
            namaPelanggan != null ? "$namaPelanggan" : "Pilih Pelanggan",
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  var delivery;

  void _showPopupMenu(BuildContext context) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RenderBox button = context.findRenderObject() as RenderBox;
    final Offset position = button.localToGlobal(Offset.zero);

    await showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(
          position,
          position.translate(9.0, button.size.height),
        ),
        Offset.zero & overlay.size,
      ),
      items: [
        const PopupMenuItem<String>(
          value: '',
          child: Text('Pilih Harga'),
        ),
        const PopupMenuItem<String>(
          value: '2',
          child: Text('Go Food'),
        ),
        const PopupMenuItem<String>(
          value: '3',
          child: Text('Shopee Food'),
        ),
        const PopupMenuItem<String>(
          value: '7',
          child: Text(''),
        ),
        const PopupMenuItem<String>(
          value: '1',
          child: Text('Normal'),
        ),
      ],
    ).then((value) {
      // This callback will be called when a menu item is selected

      if (value != null) {
        if (value == '1') {
          drop = 'Normal';
          delivery = 1;
          normal();
        } else if (value == '2') {
          drop = 'goFood';
          delivery = 2;
          normal();
        } else {
          drop = 'shopee';
          delivery = 3;
          normal();
        }
      }

      pengulangan();
    });
  }

  var allTot;

  var rekapTot;

  Container bottomBayarLandScape() {
    if (totaly == 0) {
      if (count != null) {
        tot = oCcy.format(count ?? "");
      } else {
        tot = "";
      }
    } else {
      tot = oCcy.format(totaly);
    }

    return Container(
        width: 250,
        height: 115,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 41, 88, 130),
          borderRadius: BorderRadius.circular(2), // Optional border radius
          boxShadow: const [
            BoxShadow(
              color: Colors.grey, // Shadow color
              offset: Offset(0, 3), // Offset of the shadow (x, y)
              blurRadius: 3, // Spread of the shadow
              spreadRadius: 0, // Optional spread of the shadow
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              // padding: EdgeInsets.only(bottom: 10),
              width: 250,

              decoration: BoxDecoration(
                color: Colors.grey[300],
              ),
              height: 50,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(
                    color: Colors.black26,
                    indent: 11,
                    endIndent: 11,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(right: 8, left: 8),
                        child: Text("IDR " + tot.toString(),
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Cash
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: FloatingActionButton.extended(
                      heroTag: 'uniqueTag1',
                      onPressed: () {
                        allTrans = [];
                        Trans = [];
                        AllData = [];
                        all = [];
                        if (widget.idPembayaran == 2) {
                          final id = ref.watch(selectedIdTransaksiProvider);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PembayaranPesanDidepan(
                                tanggal:
                                    widget.tanggal == '' ? currentString : '',
                                idTransaksi: id ?? 0,
                                pembayaran: 1,
                              ),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PembayaranTunai(
                                tanggal:
                                    widget.tanggal == '' ? currentString : '',
                                delivery: delivery,
                                idPelanggan: idPelanggan ?? 0,
                                kodeTransaksi: kodeTransaksiPref,
                              ),
                            ),
                          );
                        }
                      },
                      label: const Text('Bayar'),
                      backgroundColor: Colors.blue[900],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),

                // Hutang
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: FloatingActionButton.extended(
                      heroTag: 'uniqueTag3',
                      onPressed: () {
                        if (idPelanggan == null) {
                          Fluttertoast.showToast(
                            msg: "Pilih Pelanggan Terlebih Dahulu",
                            toastLength: Toast
                                .LENGTH_SHORT, // Duration for which the toast should be visible
                            gravity: ToastGravity
                                .BOTTOM, // Position of the toast on the screen
                            // Font size of the message
                          );
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PembayaranHutang(
                                tanggal:
                                    widget.tanggal == '' ? currentString : '',
                                idPelanggan: idPelanggan ?? 0),
                          ),
                        );
                      },
                      label: const Text('Hutang'),
                      backgroundColor: Colors.blue[900],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ));
  }

  Container bottomBayarPotrait() {
    if (totaly == 0) {
      if (count != null) {
        tot = oCcy.format(count ?? "");
      } else {
        tot = "";
      }
    } else {
      tot = oCcy.format(totaly);
    }

    return Container(
        width: 170,
        height: 115,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 41, 88, 130),
          borderRadius: BorderRadius.circular(2), // Optional border radius
          boxShadow: const [
            BoxShadow(
              color: Colors.grey, // Shadow color
              offset: Offset(0, 3), // Offset of the shadow (x, y)
              blurRadius: 3, // Spread of the shadow
              spreadRadius: 0, // Optional spread of the shadow
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              // padding: EdgeInsets.only(bottom: 10),
              width: 250,

              decoration: BoxDecoration(
                color: Colors.grey[300],
              ),
              height: 50,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(
                    color: Colors.black26,
                    indent: 11,
                    endIndent: 11,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(right: 8, left: 8),
                        child: Text("IDR " + tot.toString(),
                            style: const TextStyle(
                                fontSize: 21, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Cash
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: FloatingActionButton.extended(
                      heroTag: 'uniqueTag1',
                      onPressed: () {
                        allTrans = [];
                        Trans = [];
                        AllData = [];
                        all = [];
                        if (widget.idPembayaran == 2) {
                          final id = ref.watch(selectedIdTransaksiProvider);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PembayaranPesanDidepan(
                                tanggal:
                                    widget.tanggal == '' ? currentString : '',
                                idTransaksi: id ?? 0,
                                pembayaran: 1,
                              ),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PembayaranTunai(
                                tanggal:
                                    widget.tanggal == '' ? currentString : '',
                                delivery: delivery,
                                idPelanggan: idPelanggan ?? 0,
                                kodeTransaksi: kodeTransaksiPref,
                              ),
                            ),
                          );
                        }
                      },
                      label: const Text('Bayar'),
                      backgroundColor: Colors.blue[900],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),

                // Non Tunai
                // Expanded(
                //   child: Container(
                //     padding: const EdgeInsets.all(4),
                //     child: FloatingActionButton.extended(
                //       heroTag: 'uniqueTag2',
                //       onPressed: () {
                //         if (widget.idPembayaran == 2) {
                //           final id = ref.watch(selectedIdTransaksiProvider);

                //           Navigator.push(
                //             context,
                //             MaterialPageRoute(
                //               builder: (context) => PembayaranPesanDidepan(
                //                 tanggal:
                //                     widget.tanggal == '' ? currentString : '',
                //                 idTransaksi: id ?? 0,
                //                 pembayaran: 2,
                //               ),
                //             ),
                //           );
                //         } else {
                //           Navigator.push(
                //             context,
                //             MaterialPageRoute(
                //               builder: (context) => PembayaranEwallet(
                //                 tanggal:
                //                     widget.tanggal == '' ? currentString : '',
                //               ),
                //             ),
                //           );
                //         }
                //       },
                //       label: const Text('Non Tunai'),
                //       backgroundColor: Colors.blue[900],
                //       foregroundColor: Colors.white,
                //     ),
                //   ),
                // ),

                // Hutang
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: FloatingActionButton.extended(
                      heroTag: 'uniqueTag3',
                      onPressed: () {
                        if (idPelanggan == null) {
                          Fluttertoast.showToast(
                            msg: "Pilih Pelanggan Terlebih Dahulu",
                            toastLength: Toast
                                .LENGTH_SHORT, // Duration for which the toast should be visible
                            gravity: ToastGravity
                                .BOTTOM, // Position of the toast on the screen
                            // Font size of the message
                          );
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PembayaranHutang(
                                tanggal:
                                    widget.tanggal == '' ? currentString : '',
                                idPelanggan: idPelanggan ?? 0),
                          ),
                        );
                      },
                      label: const Text('Hutang'),
                      backgroundColor: Colors.blue[900],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ));
  }

  Timer? _debounce;
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _currentSearch = query;
      });
      _pagingController.refresh(); // refresh paginated list
    });
  }

  List kumpulanData = [];
  int? selectedIndex;

  String selectedBrand = "Nike";

  Widget columnCenter() {
    double screenWidth = MediaQuery.of(context).size.width;

    final border = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    );
    int crossAxisCount = (screenWidth / 150).floor();

    var screenHeight = MediaQuery.of(context).size.height - 95;
    // Indeks kategori yang dipilih
    var widthColumnCenter = MediaQuery.of(context).size.width - 250;
    return Container(
        //padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        width: widthColumnCenter,
        // height: 1200,
        height: screenHeight,
        decoration: BoxDecoration(
          color: Color(0xFFF6F7FB),
          borderRadius: BorderRadius.circular(8), // Optional border radius
          boxShadow: const [
            BoxShadow(
              color: Colors.grey, // Shadow color
              offset: Offset(0, 3), // Offset of the shadow (x, y)
              blurRadius: 6, // Spread of the shadow
              spreadRadius: 0, // Optional spread of the shadow
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            con1 == "1" ? SizedBox(height: 10) : Container(),
            con1 == "1"
                ? SizedBox(
                    height: 36,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: allKategori.length,
                      itemBuilder: (context, index) {
                        final brand = allKategori[index]['nama'] ??
                            allKategori[index]['nama_kategori'];
                        final isSelected = selectedBrand == brand;

                        bool pilih = selectedIndex == index;
                        // bool isSelected = selectedIndex == index;

                        return GestureDetector(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0, left: 8),
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
                                  color:
                                      isSelected ? Colors.white : Colors.black),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Container(),

            con1 == "1" ? SizedBox(height: 10) : Container(),
            con1 == "1"
                ? Container(
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
                            color: Colors.deepOrange),
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
                          ...produkDropdown.map((produk) {
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
                  )
                : Container(),
            SizedBox(height: 5),

            con2 == "1"
                ? Row(
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
                  )
                : Container(),
            // f
            con2 == 1 ? SizedBox(height: 5) : Container(),

            Expanded(
              child: Container(
                padding: const EdgeInsets.only(left: 5),
                child: PagedGridView<int, Map<String, dynamic>>(
                  pagingController: _pagingController,

                  //shrinkWrap: true,
                  // physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.50,
                    crossAxisSpacing: 3,
                    mainAxisSpacing: 12,
                  ),
                  builderDelegate:
                      PagedChildBuilderDelegate<Map<String, dynamic>>(
                          itemBuilder: (context, item, index) {
                    ProdukModel course = ProdukModel.fromMap(item);

                    int price = 0;

                    if (item.length > 0) {
                      if (delivery == 1 ||
                          delivery == null ||
                          delivery == '' ||
                          delivery == '1' ||
                          delivery == 'null') {
                        price = course.hargaJual ?? 0;
                      } else if (delivery == 2 || delivery == '2') {
                        price = course.hargaGoFood!;
                      } else {
                        price = course.hargaShopeeFood!;
                      }
                    }

                    return GestureDetector(
                      onTap: () {
                        final stok = course.stok ?? 0;

                        // if (stok < 5) {
                        //   // ❌ Tidak boleh lanjut
                        //   ScaffoldMessenger.of(context).showSnackBar(
                        //     const SnackBar(
                        //         content: Text(
                        //             'Stok kurang dari 5, tidak bisa dipilih')),
                        //   );
                        //   return;
                        // }
                        setState(() {
                          kumpulanData.clear();
                          kumpulanData.add(course);
                        });
                        //  Navigator.pop(context);
                        showDialogWithCount(course);
                      },
                      child: Card(
                          //width: 200,
                          // height: 150,

                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          //  padding: const EdgeInsets.all(8.0),
                          // alignment: Alignment.center,
                          child: course.gambar != null
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Expanded(
                                    //     child:
                                    ClipRRect(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(8)),
                                        //margin: const EdgeInsets.only(top: 6),
                                        child:
                                            UtilityProduk.imageFromBase64String(
                                                course.gambar!)),
                                    SizedBox(height: 1),

                                    //    ),
                                    // Expanded(
                                    //   flex: 2,
                                    //   child:
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      child: Text(
                                        '${course.namaBarang}',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    if (con4 == "1" && kodeToko == '00001')
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        child: Text(
                                          'Pk : ${item['nama_pk'].toString()}',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600]),
                                        ),
                                      ),
                                    //    ),

                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      child: Text(
                                        '${currencyFormatter2.format(int.parse(course.hargaJual.toString()))}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                    Spacer(), // Ini bantu dorong stok ke bawah
                                    con3 == "1"
                                        ? Align(
                                            alignment: Alignment.centerRight,
                                            child: Container(
                                              margin: const EdgeInsets.only(
                                                  right: 4, top: 2),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 5, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: course.stok! <= 3
                                                    ? Colors.redAccent
                                                    : Colors.deepOrange,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                'Stok: ${course.stok}',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ))
                                        : Container(),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //-----------
                                    Container(
                                        width: 100,
                                        height: 60,
                                        // margin:
                                        //     const EdgeInsets.only(top: 15.0, right: 10.0),
                                        decoration: const BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage(
                                                'images/no_image.png'),
                                            fit: BoxFit.fill,
                                          ),
                                          //shape: BoxShape.circle,
                                        )),
                                    //===========
                                    Container(
                                      margin: const EdgeInsets.only(
                                          top: 3, left: 6),
                                      child: Text(course.namaBarang.toString(),
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color: Color.fromARGB(
                                                  255, 78, 130, 173))),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(
                                          top: 3, left: 6),
                                      child: Text(
                                          oCcy.format(
                                              int.parse(price.toString())),
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color: Color.fromARGB(
                                                  255, 78, 130, 173))),
                                    ),
                                  ],
                                )),
                    );
                  }),
                ),
              ),
            )
          ],
        ));
  }

  Widget columnCenterPotrait() {
    double screenWidth = MediaQuery.of(context).size.width;

    final border = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    );
    int crossAxisCount = (screenWidth / 140).floor();

    var screenHeight = MediaQuery.of(context).size.height - 125;
    // Indeks kategori yang dipilih
    var widthColumnCenter = MediaQuery.of(context).size.width - 170;
    return Container(
        //padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        width: widthColumnCenter,
        // height: 1200,
        height: screenHeight,
        decoration: BoxDecoration(
          color: Color(0xFFF6F7FB),
          borderRadius: BorderRadius.circular(8), // Optional border radius
          boxShadow: const [
            BoxShadow(
              color: Colors.grey, // Shadow color
              offset: Offset(0, 3), // Offset of the shadow (x, y)
              blurRadius: 6, // Spread of the shadow
              spreadRadius: 0, // Optional spread of the shadow
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            con1 == "1" ? SizedBox(height: 10) : Container(),
            con1 == "1"
                ? SizedBox(
                    height: 36,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: allKategori.length,
                      itemBuilder: (context, index) {
                        // ProdukModel? course = ProdukModel.fromMap(_data[index]);

                        final brand = allKategori[index]['nama'] ??
                            allKategori[index]['nama_kategori'];
                        final isSelected = selectedBrand == brand;

                        bool pilih = selectedIndex == index;
                        // bool isSelected = selectedIndex == index;

                        return GestureDetector(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0, left: 8),
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
                                  color:
                                      isSelected ? Colors.white : Colors.black),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Container(),
            con1 == "1" ? SizedBox(height: 10) : Container(),

            // SizedBox(height: 10),

            con1 == "1"
                ? Container(
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
                            color: Colors.deepOrange),
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
                          ...produkDropdown.map((produk) {
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
                  )
                : Container(),
            SizedBox(height: 10),

            con2 == "1"
                ? Row(
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
                  )
                : Container(),
            // f
            //SizedBox(height: 20),

            con2 == 1 ? SizedBox(height: 10) : Container(),

            Expanded(
              child: Container(
                padding: const EdgeInsets.only(left: 5),
                child: PagedGridView<int, Map<String, dynamic>>(
                  pagingController: _pagingController,

                  //shrinkWrap: true,
                  // physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: con3 == "1" ? 0.52 : 0.65,
                    crossAxisSpacing: 0.5,
                    mainAxisSpacing: 1,
                  ),
                  builderDelegate:
                      PagedChildBuilderDelegate<Map<String, dynamic>>(
                          itemBuilder: (context, item, index) {
                    ProdukModel course = ProdukModel.fromMap(item);

                    int price = 0;

                    if (item.length > 0) {
                      if (delivery == 1 ||
                          delivery == null ||
                          delivery == '' ||
                          delivery == '1' ||
                          delivery == 'null') {
                        price = course.hargaJual ?? 0;
                      } else if (delivery == 2 || delivery == '2') {
                        price = course.hargaGoFood!;
                      } else {
                        price = course.hargaShopeeFood!;
                      }
                    }

                    return GestureDetector(
                      onTap: () {
                        final stok = course.stok ?? 0;

                        // if (stok < 5) {
                        //   // ❌ Tidak boleh lanjut
                        //   ScaffoldMessenger.of(context).showSnackBar(
                        //     const SnackBar(
                        //         content: Text(
                        //             'Stok kurang dari 5, tidak bisa dipilih')),
                        //   );
                        //   return;
                        // }
                        setState(() {
                          kumpulanData.clear();
                          kumpulanData.add(course);
                        });
                        //  Navigator.pop(context);
                        showDialogWithCount(course);
                      },
                      child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          child: course.gambar != null
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(8)),
                                          child: UtilityProduk
                                              .imageFromBase64String(
                                            course.gambar!,
                                          ),
                                        ),
                                        if (con3 == "1")
                                          Positioned(
                                            top: 6,
                                            left: 6,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 4, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: course.stok! <= 3
                                                    ? Colors.redAccent
                                                    : Colors.deepOrange,
                                                borderRadius: BorderRadius.only(
                                                  bottomRight:
                                                      Radius.circular(12),
                                                ),
                                              ),
                                              child: Text(
                                                '${course.stok}',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    SizedBox(height: 4),

                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      child: Text(
                                        '${course.namaBarang}',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),

                                    if (con4 == "1" && kodeToko == '00001')
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        child: Text(
                                          'PK : ${item['nama_pk'].toString()}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600]),
                                        ),
                                      ),

                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      child: Text(
                                        '${currencyFormatter2.format(int.tryParse(course.hargaJual?.toString() ?? '0') ?? 0)}',
                                        maxLines: 2,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),

                                    // Spacer(), // Ini bantu dorong stok ke bawah

                                    // con3 == "1"
                                    //     ? Align(
                                    //         alignment: Alignment.centerRight,
                                    //         child: Container(
                                    //           margin: const EdgeInsets.only(
                                    //               right: 4, top: 2, bottom: 4),
                                    //           padding: EdgeInsets.symmetric(
                                    //               horizontal: 5, vertical: 3),
                                    //           decoration: BoxDecoration(
                                    //             color: course.stok! <= 3
                                    //                 ? Colors.redAccent
                                    //                 : Colors.deepOrange,
                                    //             borderRadius:
                                    //                 BorderRadius.circular(8),
                                    //           ),
                                    //           child: Text(
                                    //             'Stok: ${course.stok}',
                                    //             style: TextStyle(
                                    //               color: Colors.white,
                                    //               fontSize: 10,
                                    //               fontWeight: FontWeight.bold,
                                    //             ),
                                    //           ),
                                    //         ),
                                    //       )
                                    //     : Container(),
                                  ],
                                )
                              : // bagian gambar null tetap aman
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //-----------
                                    Container(
                                        width: 100,
                                        height: 60,
                                        // margin:
                                        //     const EdgeInsets.only(top: 15.0, right: 10.0),
                                        decoration: const BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage(
                                                'images/no_image.png'),
                                            fit: BoxFit.fill,
                                          ),
                                          //shape: BoxShape.circle,
                                        )),
                                    //===========
                                    Container(
                                      margin: const EdgeInsets.only(
                                          top: 3, left: 6),
                                      child: Text(course.namaBarang.toString(),
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color: Color.fromARGB(
                                                  255, 78, 130, 173))),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(
                                          top: 3, left: 6),
                                      child: Text(
                                          oCcy.format(
                                              int.parse(price.toString())),
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color: Color.fromARGB(
                                                  255, 78, 130, 173))),
                                    ),
                                  ],
                                )),
                    );
                  }),
                ),
              ),
            )
          ],
        ));
  }

  @override
  void dispose() {
    _streamController.close();
    plusMinus.dispose();
    //plusMinusToping[0].dispose();
    inputHarga.dispose();
    subTotal.dispose();
    catatan.dispose();
    namaTransaksi.dispose();
    teSeach.dispose();
    _searchController.dispose();
    _pagingController.dispose();
    _debounce?.cancel(); // <- juga aman dibatalkan di sini

    // diskon.dispose();
    //priceAfterDiscount.dispose();
    super.dispose();
  }

  void _deleteItem(int id, int idTrans) async {
    await helper!.deleteDetailPembelian(id, idTrans);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a Produk!'),
    ));
    _refreshDetailPembelian();
    Navigator.of(context).pop(false);
  }

  void _deleteMysql(kodeBarang, idTrans) async {
    Map data = {'id_barang': kodeBarang, 'id_sub_transaksi': idTrans};

    String url;

    url = 'delete_detail_transaksi';

    // final response = await htpp.post(Uri.parse(url), body: data);
    final response = await Network().getData_post(data, url);
    // var c = json.decode(response.body);

    if (response.statusCode == 200) {
      print('sukses delete mysql');
    } else {
      print(response.body);
      throw Exception(response);
    }
  }

  showAlertDialog(BuildContext context, int id, int idBarang, int trans) {
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
        _deleteItem(idBarang, trans);

        _deleteMysql(id, trans);

        refreshJumlahPembelian();

        catatanToping();

        bottomBayarLandScape();
        bottomBayarPotrait();
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

  void showDialogWithCountEdit(items) {
    plusMinus = TextEditingController(text: items['qty'].toString());

    inputHarga = TextEditingController(
        text: currencyFormatter.format((items['harga_jual'].toString())));

    subTotal = TextEditingController(
        text: currencyFormatter.format((items['harga'].toString())));

    catatan = TextEditingController(text: items['catatan'].toString());

    var idBarang = items['id_barang'];

    var kodeBarang = items['kode'];

    var stok = items['stok'];

    var idTransaksi = items['id_transaksi'];

    Container limit;

    if (stok <= 10) {
      limit = Container(
          margin: const EdgeInsets.only(left: 10),
          child: DefaultTextStyle(
            style: const TextStyle(fontSize: 20.0, color: Colors.red),
            child: AnimatedTextKit(
              animatedTexts: [
                WavyAnimatedText('SISA STOK $stok'),
                //WavyAnimatedText('Look at the waves'),
              ],
              isRepeatingAnimation: true,
            ),
          ));
    } else {
      limit = Container();
    }
    var disc;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: StatefulBuilder(
            // You need this, notice the parameters below:
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                //  color: Color.fromARGB(255, 226, 222, 222),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      // crossAxisAlignment: CrossAxisAlignment.stretch,
                      // mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          // margin: const EdgeInsets.only(),
                          child: Text(items['nama_barang'].toString(),
                              style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        limit
                      ],
                    ),
                    Container(
                      child: const Divider(
                        color: Color.fromARGB(255, 3, 87, 156),
                        thickness: 3,
                        indent: 0,
                        endIndent: 0,
                      ),
                    ),
                    Container(
                      child: const Text("Jumlah Barang",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.blue,
                          )),
                    ),
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _sink.add(++initValue);

                            // ignore: unused_local_variable
                            var hasilTambah = initValue *
                                int.parse(items['harga_jual'].toString());

                            //int output;
                            // if (diskon.text != "") {
                            //   output = initValue * hasilDiskon;
                            //   hasilTambah = output;
                            // }

                            setState(() {
                              subTotal = TextEditingController(
                                  text: currencyFormatter
                                      .format((hasilTambah.toString())));
                            });
                          },
                          child: Container(
                            child: const Image(
                              image: AssetImage('images/plus.png'),
                              width: 40,
                              height: 40,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 50,
                          height: 40,
                          child: TextField(
                            style: const TextStyle(color: Color(0xFF000000)),
                            cursorColor: const Color(0xFF9b9b9b),
                            keyboardType: TextInputType.text,
                            controller: plusMinus,
                            onChanged: (value) {
                              setState(() {
                                hitungJumlahHarga(value);
                              });
                            },
                            decoration: InputDecoration(
                              fillColor: Colors.grey,

                              //  hintText: "Pencarian",
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                  width: 2.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _sink.add(--initValue);

                            var hasilKurang = initValue *
                                int.parse(items['harga_jual'].toString());
                            //  int output;
                            // if (diskon.text != "") {
                            //   output = initValue * hasilDiskon;
                            //   hasilKurang = output;
                            // }
                            setState(() {
                              subTotal = TextEditingController(
                                  text: currencyFormatter
                                      .format((hasilKurang.toString())));
                            });
                          },
                          child: Container(
                            child: const Image(
                              image: AssetImage('images/minus.png'),
                              width: 40,
                              height: 40,
                            ),
                          ),
                        )
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: const Text("Harga",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.blue,
                          )),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      child: TextField(
                        style: const TextStyle(color: Color(0xFF000000)),
                        cursorColor: const Color(0xFF9b9b9b),
                        keyboardType: TextInputType.text,
                        controller: inputHarga,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CurrencyInputFormatter(),
                        ],
                        decoration: InputDecoration(
                          fillColor: const Color.fromARGB(255, 204, 201, 201),
                          filled: true,
                          //  hintText: "Pencarian",
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 5, 81, 143),
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: const Text("Sub Total",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.blue,
                          )),
                    ),
                    Container(
                      child: TextField(
                        style: const TextStyle(color: Color(0xFF000000)),
                        cursorColor: const Color(0xFF9b9b9b),
                        keyboardType: TextInputType.text,
                        controller: subTotal,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CurrencyInputFormatter(),
                        ],
                        decoration: InputDecoration(
                          fillColor: const Color.fromARGB(255, 255, 255, 255),
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 5, 81, 143),
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: const Text("Catatan",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.blue,
                          )),
                    ),
                    Container(
                      child: TextField(
                        style: const TextStyle(color: Color(0xFF000000)),
                        cursorColor: const Color(0xFF9b9b9b),
                        keyboardType: TextInputType.text,
                        controller: catatan,
                        decoration: InputDecoration(
                          fillColor: const Color.fromARGB(255, 255, 255, 255),
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 5, 81, 143),
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                              width: 110,
                              child: FloatingActionButton.extended(
                                heroTag: 'uniqueTag36',
                                backgroundColor:
                                    const Color.fromARGB(255, 95, 151, 236),
                                label: const Text(
                                  'Simpan',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () async {
                                  String subTotFormat =
                                      removeCurrencyFormat(subTotal.text);
                                  var jml = int.parse(plusMinus.text);
                                  var harga = int.parse(subTotFormat);
                                  if (afterDisc != null) {
                                    disc = (afterDisc.round());
                                  } else {
                                    disc = 0;
                                  }

                                  await helper!
                                      .updateListDetailTransaksiPembelianTunai(
                                          idTransaksi,
                                          idBarang,
                                          jml,
                                          harga,
                                          catatan.text);

                                  refreshJumlahPembelian();

                                  // bottomBayar();

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => TransPenjualan(
                                              tanggal: currentString,
                                              delivery: delivery,
                                              idPembayaran: 0,
                                            )),
                                  );

                                  sendToMysqlEdit(
                                    idTransaksi,
                                    kodeBarang,
                                    jml,
                                    harga,
                                    disc,
                                    '',
                                    currentString,
                                  );
                                },
                              )),
                          SizedBox(
                              width: 110,
                              child: FloatingActionButton.extended(
                                  heroTag: 'uniqueTag4',
                                  backgroundColor:
                                      const Color.fromARGB(255, 95, 151, 236),
                                  label: const Text(
                                    'Batal',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  onPressed: () async {
                                    subTotal = TextEditingController(text: "");
                                    inputHarga =
                                        TextEditingController(text: "");
                                    plusMinus =
                                        TextEditingController(text: "1");
                                    //  diskon = TextEditingController(text: "");
                                    priceAfterDiscount =
                                        TextEditingController(text: "");

                                    initValue = 1;

                                    Navigator.pop(context);
                                  })),
                        ],
                      ),
                    )
                  ],
                ),
              );

              //   return Text(teSeach.text);
            },
          ),
        );
      },
    );
  }

  var fillDisc;

  void pengulangan() async {
    totaly = 0;
    var a;

    for (a = 0; a < DetailTrans.length; a++) {
      if (drop == 'Normal') {
        updateHarga(DetailTrans[a]['harga_jual'] * DetailTrans[a]['qty'],
            DetailTrans[a]['id_barang'], DetailTrans[a]['kode'], delivery);

        totaly += DetailTrans[a]['harga_jual'] * DetailTrans[a]['qty'];
      } else if (drop == 'goFood') {
        updateHarga(DetailTrans[a]['harga_go_food'] * DetailTrans[a]['qty'],
            DetailTrans[a]['id_barang'], DetailTrans[a]['kode'], delivery);
        totaly += DetailTrans[a]['harga_go_food'] * DetailTrans[a]['qty'];
      } else if (drop == 'shopee') {
        updateHarga(DetailTrans[a]['harga_shopee_food'] * DetailTrans[a]['qty'],
            DetailTrans[a]['id_barang'], DetailTrans[a]['kode'], delivery);
        totaly += DetailTrans[a]['harga_shopee_food'] * DetailTrans[a]['qty'];
      }
    }
  }

  TransaksiDetailPembelianModel? course;

  contentLandScape() {
    var screenHeight = MediaQuery.of(context).size.height - 232;

    return Container(
      //color: Colors.white,
      width: 250,
      // height: 93,
      height: screenHeight,
      child: ListView.builder(
        itemCount: Trans.length,
        //shrinkWrap: true,
        // physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          var idBarang = int.parse(Trans[index]['id_barang'].toString());

          var idTransDel =
              int.parse(Trans[index]['id_sub_transaksi'].toString());

          var kodeBarang = int.parse(Trans[index]['kode'].toString());

          Widget del;

          if (delivery == null || delivery == '') {
            delivery = widget.delivery;
          }

          if (delivery == 1 ||
              delivery == null ||
              delivery == '' ||
              delivery == '1' ||
              delivery == 'null') {
            del = Container(
              child: Text(
                  "${Trans[index]['qty']} x ${oCcy.format(int.parse(Trans[index]['harga'].toString()))}",
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold)),
            );
          } else if (delivery == 2 || delivery == '2') {
            del = Container(
              child: Text(
                  "${Trans[index]['qty']} x ${oCcy.format(int.parse(Trans[index]['harga_go_food'].toString()))}",
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold)),
            );
          } else {
            del = Container(
              child: Text(
                  "${Trans[index]['qty']} x ${oCcy.format(int.parse(Trans[index]['harga_shopee_food'].toString()))}",
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold)),
            );
          }

          //  index = 1;
          // if (index >= all.length) {
          //   index = 0;
          //   //return null;
          // }

          //print(all);
          //var panjang = 0;

          // if (all.isNotEmpty) {
          //   if (all[index].length == 1 || all[index].length == 0) {
          //     panjang = 200;
          //   } else {
          //     panjang = 90 * all[index].length;
          //   }
          // }

          // if (all.length == 0) {

          //   //index = 0;

          //   //return null;
          // }
          var kode = Trans[index]['kode'].toString();

          return GestureDetector(
            onTap: () {
              showDialogWithCountEdit(Trans[index]);
            },
            onLongPress: () {
              showAlertDialog(context, kodeBarang, idBarang, idTransDel);
            },
            child: SingleChildScrollView(
              key: ValueKey(index),
              // decoration: BoxDecoration(
              //   borderRadius: BorderRadius.circular(5),
              //   // color: Colors.white,
              // ),
              // height: panjang.toDouble(),
              // //  height: 200,
              // width: 150,
              child: Material(
                elevation: 4.0,
                borderRadius: BorderRadius.circular(5.0),
                color: index % 2 == 0
                    ? Colors.white
                    : const Color.fromARGB(255, 226, 232, 230),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,

                    //    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        key: ValueKey(Trans[index]['id']),
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.only(top: 9, left: 9),
                                child: Text(
                                  kode,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.only(top: 8, left: 9),
                                child: Text(
                                  Trans[index]['nama_barang'].toString(),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.only(top: 8, left: 9),
                                child: Text(
                                    "Catatan  : " +
                                        Trans[index]['catatan'].toString(),
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                              padding:
                                  const EdgeInsets.only(top: 15, right: 15),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      del,
                                    ],
                                  ),
                                  // nilaiDiskon,
                                ],
                              )),
                        ],
                      ),
                      //  if (all.isNotEmpty)

                      // Container(
                      //     width: 270,
                      //     height: 100,
                      //     child: ListView.builder(
                      //         itemCount: all[index].length,
                      //         // shrinkWrap: true,
                      //         // physics: const NeverScrollableScrollPhysics(),
                      //         itemBuilder: (context, index2) {
                      //           //  all.length;
                      //           // if (all.isNotEmpty)
                      //           //   for (var x = 0; x < all[index].length; x++)
                      //           return Container(
                      //             //width: 250,
                      //             // width: 300,
                      //             height: 40,
                      //             padding:
                      //                 const EdgeInsets.only(top: 2, left: 9),
                      //             decoration: BoxDecoration(
                      //                 gradient: LinearGradient(
                      //                     begin: Alignment.topCenter,
                      //                     end: Alignment.bottomCenter,
                      //                     colors: [
                      //                   Colors.white,
                      //                   Colors.grey.shade400
                      //                 ])),
                      //             child: Container(
                      //               height: 20,
                      //               child: Column(
                      //                 mainAxisAlignment:
                      //                     MainAxisAlignment.start,
                      //                 crossAxisAlignment:
                      //                     CrossAxisAlignment.start,
                      //                 children: [
                      //                   Row(
                      //                     crossAxisAlignment:
                      //                         CrossAxisAlignment.start,
                      //                     children: [
                      //                       Container(
                      //                           height: 30,
                      //                           width: 150,
                      //                           padding:
                      //                               const EdgeInsets.only(
                      //                                   top: 10, left: 9),
                      //                           child: Text(
                      //                               "- " +
                      //                                   all[index][index2][
                      //                                           'nama_barang']
                      //                                       .toString(),
                      //                               style: const TextStyle(
                      //                                   fontSize: 13,
                      //                                   fontStyle:
                      //                                       FontStyle.italic),
                      //                               key: ValueKey(index))),

                      //                       const Spacer(),
                      //                       Container(
                      //                         // width: double.infinity,
                      //                         height: 20,
                      //                         padding: const EdgeInsets.only(
                      //                             top: 8, right: 10),
                      //                         child: Row(
                      //                           children: [
                      //                             Container(
                      //                               child: Text(
                      //                                   "${all[index][index2]['qty']} x ${oCcy.format(int.parse(all[index][index2]['harga_jual'].toString()))}",
                      //                                   style: const TextStyle(
                      //                                       fontSize: 13,
                      //                                       fontStyle:
                      //                                           FontStyle
                      //                                               .italic),
                      //                                   key: ValueKey(index)),
                      //                             )
                      //                           ],
                      //                         ),
                      //                       ),
                      //                       //  ],
                      //                       //)
                      //                     ],
                      //                   ),
                      //                   // Container(
                      //                   //   padding: const EdgeInsets.only(
                      //                   //       top: 2, left: 9),
                      //                   //   child: Text(
                      //                   //       'Note : ${selectDetailPembelian[index]['catatan']}'),
                      //                   // ),
                      //                 ],
                      //               ),
                      //             ),
                      //           );
                      //           //  fillDisc,
                      //         })),
                    ],
                  ),
                ),
              ),
              //)
              //  ],
            ),
          );
        },
      ),
    );
  }

  contentPotrait() {
    var screenHeight = MediaQuery.of(context).size.height - 260;

    return Container(
      //color: Colors.white,
      width: 170,
      // height: 93,
      height: screenHeight,
      child: ListView.builder(
        itemCount: Trans.length,
        //shrinkWrap: true,
        // physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          var idBarang = int.parse(Trans[index]['id_barang'].toString());

          var idTransDel =
              int.parse(Trans[index]['id_sub_transaksi'].toString());

          var kodeBarang = int.parse(Trans[index]['kode'].toString());

          Widget del;

          if (delivery == null || delivery == '') {
            delivery = widget.delivery;
          }

          if (delivery == 1 ||
              delivery == null ||
              delivery == '' ||
              delivery == '1' ||
              delivery == 'null') {
            del = Container(
              child: Text(
                  "${Trans[index]['qty']} x ${oCcy.format(int.parse(Trans[index]['harga'].toString()))} ",
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold)),
            );
          } else if (delivery == 2 || delivery == '2') {
            del = Container(
              child: Text(
                  "${Trans[index]['qty']} x ${oCcy.format(int.parse(Trans[index]['harga_go_food'].toString()))}",
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold)),
            );
          } else {
            del = Container(
              child: Text(
                  "${Trans[index]['qty']} x ${oCcy.format(int.parse(Trans[index]['harga_shopee_food'].toString()))}",
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold)),
            );
          }

          var kode = Trans[index]['kode'].toString();

          return GestureDetector(
            onTap: () {
              showDialogWithCountEdit(Trans[index]);
            },
            onLongPress: () {
              showAlertDialog(context, kodeBarang, idBarang, idTransDel);
            },
            child: SingleChildScrollView(
              key: ValueKey(index),

              child: Material(
                elevation: 4.0,
                borderRadius: BorderRadius.circular(5.0),
                color: index % 2 == 0
                    ? Colors.white
                    : const Color.fromARGB(255, 226, 232, 230),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,

                    //    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        key: ValueKey(Trans[index]['id']),
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.only(top: 8, left: 9),
                                child: Text(
                                  Trans[index]['nama_barang'].toString(),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.only(top: 8, left: 9),
                                child: del,
                              ),
                              Container(
                                padding: const EdgeInsets.only(top: 8, left: 9),
                                child: Text(
                                    "Catatan  : " +
                                        Trans[index]['catatan'].toString(),
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          // const Spacer(),

                          // Row(
                          //   children: [
                          //     Text('Qty: '),
                          //     const Spacer(), // ⬅️ kunci fleksibel
                          //     Text(
                          //       'Rp 1.000.000',
                          //       textAlign: TextAlign.right,
                          //       overflow: TextOverflow.ellipsis,
                          //     ),
                          //   ],
                          // ),
                          // Container(
                          //     padding:
                          //         const EdgeInsets.only(top: 15, right: 15),
                          //     child: Column(
                          //       children: [
                          //         Row(
                          //           children: [
                          //             del,
                          //           ],
                          //         ),
                          //         // nilaiDiskon,
                          //       ],
                          //     )),
                        ],
                      ),
                      //  if (all.isNotEmpty)

                      // Container(
                      //     width: 270,
                      //     height: 100,
                      //     child: ListView.builder(
                      //         itemCount: all[index].length,
                      //         // shrinkWrap: true,
                      //         // physics: const NeverScrollableScrollPhysics(),
                      //         itemBuilder: (context, index2) {
                      //           //  all.length;
                      //           // if (all.isNotEmpty)
                      //           //   for (var x = 0; x < all[index].length; x++)
                      //           return Container(
                      //             //width: 250,
                      //             // width: 300,
                      //             height: 40,
                      //             padding:
                      //                 const EdgeInsets.only(top: 2, left: 9),
                      //             decoration: BoxDecoration(
                      //                 gradient: LinearGradient(
                      //                     begin: Alignment.topCenter,
                      //                     end: Alignment.bottomCenter,
                      //                     colors: [
                      //                   Colors.white,
                      //                   Colors.grey.shade400
                      //                 ])),
                      //             child: Container(
                      //               height: 20,
                      //               child: Column(
                      //                 mainAxisAlignment:
                      //                     MainAxisAlignment.start,
                      //                 crossAxisAlignment:
                      //                     CrossAxisAlignment.start,
                      //                 children: [
                      //                   Row(
                      //                     crossAxisAlignment:
                      //                         CrossAxisAlignment.start,
                      //                     children: [
                      //                       Container(
                      //                           height: 30,
                      //                           width: 150,
                      //                           padding:
                      //                               const EdgeInsets.only(
                      //                                   top: 10, left: 9),
                      //                           child: Text(
                      //                               "- " +
                      //                                   all[index][index2][
                      //                                           'nama_barang']
                      //                                       .toString(),
                      //                               style: const TextStyle(
                      //                                   fontSize: 13,
                      //                                   fontStyle:
                      //                                       FontStyle.italic),
                      //                               key: ValueKey(index))),

                      //                       const Spacer(),
                      //                       Container(
                      //                         // width: double.infinity,
                      //                         height: 20,
                      //                         padding: const EdgeInsets.only(
                      //                             top: 8, right: 10),
                      //                         child: Row(
                      //                           children: [
                      //                             Container(
                      //                               child: Text(
                      //                                   "${all[index][index2]['qty']} x ${oCcy.format(int.parse(all[index][index2]['harga_jual'].toString()))}",
                      //                                   style: const TextStyle(
                      //                                       fontSize: 13,
                      //                                       fontStyle:
                      //                                           FontStyle
                      //                                               .italic),
                      //                                   key: ValueKey(index)),
                      //                             )
                      //                           ],
                      //                         ),
                      //                       ),
                      //                       //  ],
                      //                       //)
                      //                     ],
                      //                   ),
                      //                   // Container(
                      //                   //   padding: const EdgeInsets.only(
                      //                   //       top: 2, left: 9),
                      //                   //   child: Text(
                      //                   //       'Note : ${selectDetailPembelian[index]['catatan']}'),
                      //                   // ),
                      //                 ],
                      //               ),
                      //             ),
                      //           );
                      //           //  fillDisc,
                      //         })),
                    ],
                  ),
                ),
              ),
              //)
              //  ],
            ),
          );
        },
      ),
    );
  }

  Container pesanDidepan() {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      width: 150,
      child: FloatingActionButton.extended(
        heroTag: 'uniqueTag5',
        onPressed: () {
          showDialogWithNama();
        },
        label: const Text('Bayar Nanti'),
        backgroundColor: const Color.fromARGB(255, 152, 164, 168),
        foregroundColor: Colors.black,
      ),
    );
  }

  void _refreshDetailPembelian() async {
    if (helper != null) {
      helper!.showPembelian().then((product) {
        setState(() {
          allDetailTrans = product;
          DetailTrans = allDetailTrans;

          _isLoading = false;
        });
      });
    }
  }

  void showDialogWithNama() async {
    Widget continueButton = Container(
      margin: const EdgeInsets.only(top: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
              width: 110,
              child: FloatingActionButton.extended(
                heroTag: 'uniqueTag6',
                backgroundColor: const Color.fromARGB(255, 95, 151, 236),
                label: const Text(
                  'Simpan',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onPressed: () async {
                  //    var status = 1;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PrintingPemesanan(
                              detailTransaksi: Trans,
                              all: all,
                              tot: count,
                              createdAt:
                                  widget.tanggal == '' ? currentString : '',
                              namaTrans: namaTransaksi.text,
                            )),
                  );
                },
              )),
        ],
      ),
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Nama Transaksi"),
      content: Container(
        child: TextField(
          style: const TextStyle(color: Color(0xFF000000)),
          cursorColor: const Color(0xFF9b9b9b),
          keyboardType: TextInputType.text,
          controller: namaTransaksi,
          decoration: InputDecoration(
            fillColor: const Color.fromARGB(255, 255, 255, 255),
            filled: true,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 5, 81, 143),
                width: 2.0,
              ),
            ),
          ),
        ),
      ),
      actions: [
        continueButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  var pelanggan = [];

  void showDialogPelanggan() {
    TextEditingController searchController = TextEditingController();
    List<dynamic> filteredPelanggan = List.from(pelanggan);
    Timer? debounceTimer;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            void onSearchChanged(String query) {
              if (debounceTimer?.isActive ?? false) debounceTimer!.cancel();

              debounceTimer = Timer(const Duration(milliseconds: 300), () {
                setStateDialog(() {
                  if (query.isEmpty) {
                    filteredPelanggan = List.from(pelanggan);
                  } else {
                    filteredPelanggan = pelanggan.where((p) {
                      final nama = p['nama']?.toLowerCase() ?? '';
                      return nama.contains(query.toLowerCase());
                    }).toList();
                  }
                });
              });
            }

            return AlertDialog(
              title: const Text(
                "Pilih Pelanggan",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: "Cari nama pelanggan...",
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: onSearchChanged,
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: filteredPelanggan.isEmpty
                          ? const Center(child: Text("Belum ada pelanggan"))
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: filteredPelanggan.length,
                              itemBuilder: (context, index) {
                                final p = filteredPelanggan[index];
                                return Card(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 12),
                                    leading: const CircleAvatar(
                                      backgroundColor: Colors.blueAccent,
                                      child: Icon(Icons.person,
                                          color: Colors.white),
                                    ),
                                    title: Text(
                                      p['nama'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: Text(p['no_hp'] ?? ''),
                                    onTap: () {
                                      setState(() {
                                        namaPelanggan = p['nama'];
                                        idPelanggan = p['id'];
                                      });
                                      Navigator.of(context).pop();
                                      print(
                                          "Dipilih: ${p['nama']} (${p['kode']})");
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      debounceTimer?.cancel(); // bersihkan timer saat dialog ditutup
    });
  }

  // Future<void> simpanPelanggan(int idPelanggan, nama) async {
  //   final prefs = await SharedPreferences.getInstance();

  //   await prefs.remove('id_pelanggan');
  //   await prefs.remove('nama');

  //   await prefs.setInt('id_pelanggan', idPelanggan);
  //   await prefs.setString('nama', nama);

  //   //print('ID Pelanggan disimpan: $idPelanggan');
  // }

  // void showDialogWithFields() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         content: StatefulBuilder(
  //           // You need this, notice the parameters below:
  //           builder: (BuildContext context, StateSetter setState) {
  //             return Column(
  //               children: [
  //                 Container(
  //                   decoration: BoxDecoration(
  //                     borderRadius: BorderRadius.circular(5),
  //                     //Color.fromARGB(1, 41, 87, 129),
  //                   ),
  //                   height: 130,
  //                   width: double.infinity,
  //                   child: Material(
  //                     elevation: 4.0,
  //                     borderRadius: BorderRadius.circular(5.0),
  //                     color: const Color.fromARGB(255, 42, 87, 129),
  //                     child: Column(
  //                       mainAxisAlignment: MainAxisAlignment.start,
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Row(
  //                           children: [
  //                             Container(
  //                                 margin:
  //                                     const EdgeInsets.only(left: 10, top: 10),
  //                                 padding: const EdgeInsets.symmetric(
  //                                     horizontal: 10, vertical: 5),
  //                                 width: 200,
  //                                 decoration: BoxDecoration(
  //                                     color: Colors.white,
  //                                     borderRadius: BorderRadius.circular(10)),
  //                                 child: DropdownButtonHideUnderline(
  //                                   child: DropdownButton(
  //                                     icon: const Icon(Icons.arrow_drop_down),
  //                                     iconSize: 30,
  //                                     underline: const SizedBox(),
  //                                     items: Katitems.map((item) {
  //                                       return DropdownMenuItem(
  //                                         value: item['id'].toString(),
  //                                         child: Text(item['nama_kategori']),
  //                                       );
  //                                     }).toList(),
  //                                     hint: const Text(
  //                                       "Please choose a Kategori",
  //                                       textAlign: TextAlign.start,
  //                                       style: TextStyle(
  //                                           color: Colors.black,
  //                                           fontSize: 10,
  //                                           fontWeight: FontWeight.bold),
  //                                     ),
  //                                     onChanged: (String? newVal) {
  //                                       setState(() {
  //                                         _mySelection = newVal!;
  //                                         _dropdownError = null;
  //                                         var id = int.parse(
  //                                             _mySelection.toString());
  //                                         _cariKat(id);

  //                                         //print(newVal);
  //                                         //  this._getNames(newVal);
  //                                       });
  //                                     },
  //                                     value: _mySelection,
  //                                   ),
  //                                 )),
  //                             _dropdownError == null
  //                                 ? const SizedBox.shrink()
  //                                 : Text(
  //                                     _dropdownError ?? "",
  //                                     style: const TextStyle(color: Colors.red),
  //                                   ),
  //                           ],
  //                         ),
  //                         Container(
  //                           margin: const EdgeInsets.only(
  //                               left: 10, top: 10, right: 10),
  //                           //  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  //                           width: 340,
  //                           height: 40,
  //                           decoration: BoxDecoration(
  //                               color: Colors.grey,
  //                               borderRadius: BorderRadius.circular(10)),
  //                           child: TextFormField(
  //                             style: const TextStyle(color: Color(0xFF000000)),
  //                             cursorColor: const Color(0xFF9b9b9b),
  //                             keyboardType: TextInputType.text,
  //                             controller: teSeach,
  //                             onChanged: (value) {
  //                               setState(() {
  //                                 filterSeach(value);
  //                               });
  //                             },
  //                             decoration: InputDecoration(
  //                               fillColor: Colors.grey,
  //                               prefixIcon: const Icon(
  //                                 Icons.search,
  //                                 color: Colors.white,
  //                               ),
  //                               hintText: "Pencarian",
  //                               enabledBorder: OutlineInputBorder(
  //                                 borderRadius: BorderRadius.circular(5.0),
  //                                 borderSide: const BorderSide(
  //                                   color: Colors.white,
  //                                   width: 2.0,
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                         )
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //                 // const SizedBox(
  //                 //   height: 10,
  //                 // ),
  //                 _buildList(),

  //                 //
  //               ],
  //             );

  //             //   return Text(teSeach.text);
  //           },
  //         ),
  //       );
  //     },
  //   );
  // }

  var afterDisc;

  final currencyFormatter = CurrencyFormatter();

  final currencyFormatter2 = NumberFormat.decimalPattern('id');

  KasirHelper helpers = KasirHelper();

  void _loadMoreData() {
    setState(() {
      currentPage++;
      _loadData(0);
    });
  }

  var hasilJumlah;
  void hitungJumlahHarga(String query) async {
    var allProduk = ref.watch(produkProvider);
    if (query.isNotEmpty) {
      var jumlah = int.parse(plusMinus.text);
      var price = int.parse(inputHarga.text);

      setState(() {
        hasilJumlah = jumlah * price;

        subTotal = TextEditingController(
            text: currencyFormatter.format((hasilJumlah.toString())));
      });

      return;
    } else {
      setState(() {
        _data = [];
        _data = allProduk;
      });
    }
  }

  String removeCurrencyFormat(String formattedValue) {
    // Hapus semua karakter yang bukan angka
    String cleanValue = formattedValue.replaceAll(RegExp(r'[^\d]'), '');
    // String formattedNumber =
    //     cleanValue.replaceAll(RegExp(r"(\.0{2,})|(0*)$"), "");

    String resultString = cleanValue.substring(0, cleanValue.length - 2);

    return resultString;
  }

  String removeCurrencyFormatWithRp(String formattedValue) {
    // Hapus semua karakter yang bukan angka
    return formattedValue.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
  }

  List<int> itemCounts = List.generate(10, (index) => 1);

  void showDialogWithCount(items) {
    var harBarang;
    if (delivery == 1 ||
        delivery == null ||
        delivery == '' ||
        delivery == '1' ||
        delivery == 'null') {
      inputHarga = TextEditingController(
          text: currencyFormatter.format((items.hargaJual.toString())));

      harBarang = items.hargaJual;

      subTotal = TextEditingController(
          text: currencyFormatter.format((items.hargaJual.toString())));
    } else if (delivery == 2 || delivery == '2') {
      inputHarga = TextEditingController(
          text: currencyFormatter.format((items['harga_go_food'].toString())));

      subTotal = TextEditingController(
          text: currencyFormatter.format((items['harga_go_food'].toString())));
      harBarang = items['harga_go_food'];
    } else {
      inputHarga = TextEditingController(
          text: currencyFormatter
              .format((items['harga_shopee_food'].toString())));
      harBarang = items['harga_shopee_food'];
      subTotal = TextEditingController(
          text: currencyFormatter
              .format((items['harga_shopee_food'].toString())));
    }

    var idBarang = items.id;

    var kodeBarang = items.kode;

    var stok = items.stok;

    Container limit;

    if (stok <= 10) {
      limit = Container(
          margin: const EdgeInsets.only(left: 10),
          child: DefaultTextStyle(
            style: const TextStyle(fontSize: 20.0, color: Colors.red),
            child: AnimatedTextKit(
              animatedTexts: [
                WavyAnimatedText('SISA STOK $stok'),
                //WavyAnimatedText('Look at the waves'),
              ],
              isRepeatingAnimation: true,
            ),
          ));
    } else {
      limit = Container();
    }
    var disc;

    void _removeFruitById(String id) {
      setState(() {
        dataProduk.removeWhere((fruit) => fruit['id'] == id);

        Navigator.pop(context);

        showDialogWithCount(kumpulanData[0]);

        // dataProduk;
      });
    }

    List<Item> convertToPersonList() {
      return dataProduk.map((data) => Item.fromJson(data)).toList();
    }

    List<Item> personList = convertToPersonList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// HEADER
                      Row(
                        children: [
                          Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(
                              Icons.shopping_bag_outlined,
                              color: Colors.blue,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  items.namaBarang.toString(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Kode : ${items.kode}",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      /// STOK
                      if (stok <= 10)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Sisa stok $stok",
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                        ),

                      const SizedBox(height: 20),

                      /// JUMLAH
                      const Text(
                        "Jumlah Barang",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          /// MINUS
                          GestureDetector(
                            onTap: () {
                              if (initValue > 1) {
                                _sink.add(--initValue);

                                String cleanHarga;

                                if (inputHarga.text.contains('Rp')) {
                                  cleanHarga = removeCurrencyFormatWithRp(
                                      inputHarga.text);
                                } else {
                                  cleanHarga =
                                      removeCurrencyFormat(inputHarga.text);
                                }

                                int harga = int.parse(cleanHarga);

                                var hasilKurang = initValue * harga;

                                setState(() {
                                  subTotal = TextEditingController(
                                    text: currencyFormatter.format(
                                      hasilKurang.toString(),
                                    ),
                                  );
                                });
                              }
                            },
                            child: Container(
                              height: 52,
                              width: 52,
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.remove,
                                color: Colors.red,
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          /// QTY
                          Expanded(
                            child: Container(
                              height: 55,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: TextField(
                                textAlign: TextAlign.center,
                                controller: plusMinus,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    hitungJumlahHarga(value);
                                  });
                                },
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          /// PLUS
                          GestureDetector(
                            onTap: () {
                              _sink.add(++initValue);

                              String cleanHarga;

                              if (inputHarga.text.contains('Rp')) {
                                cleanHarga =
                                    removeCurrencyFormatWithRp(inputHarga.text);
                              } else {
                                cleanHarga =
                                    removeCurrencyFormat(inputHarga.text);
                              }

                              int harga = int.parse(cleanHarga);

                              var hasilTambah = initValue * harga;

                              setState(() {
                                subTotal = TextEditingController(
                                  text: currencyFormatter.format(
                                    hasilTambah.toString(),
                                  ),
                                );
                              });
                            },
                            child: Container(
                              height: 52,
                              width: 52,
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      /// HARGA
                      const Text(
                        "Harga",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      TextField(
                        controller: inputHarga,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CurrencyInputFormatter(),
                        ],
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[100],
                          prefixIcon: const Icon(Icons.payments),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// SUBTOTAL
                      const Text(
                        "Sub Total",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xff1565C0),
                              Color(0xff42A5F5),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Total Bayar",
                              style: TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subTotal.text.isEmpty
                                  ? "Rp 0"
                                  : "Rp ${subTotal.text}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// SEARCH TOPING
                      TextField(
                        decoration: InputDecoration(
                          hintText: "Cari topping...",
                          filled: true,
                          fillColor: Colors.grey[100],
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// BUTTON
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 55,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[200],
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  "Batal",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 55,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[700],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                onPressed: () async {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  DateTime now = DateTime.now();
                                  final id =
                                      ref.watch(selectedIdTransaksiProvider);

                                  int sec = now.second;
                                  var idSub = idBarang
                                      .toString()
                                      .padLeft(4, sec.toString());

                                  var idSubInt = int.parse(idSub);

                                  String hargaFormat;
                                  if (inputHarga.text.contains('Rp')) {
                                    hargaFormat = removeCurrencyFormatWithRp(
                                        inputHarga.text);
                                  } else {
                                    hargaFormat =
                                        removeCurrencyFormat(inputHarga.text);
                                  }

                                  var jml = int.parse(plusMinus.text);
                                  //   var harga = int.parse(hargaFormat) * jml;
                                  var harga = int.parse(hargaFormat);

                                  var total = harga * jml;
                                  if (afterDisc != null) {
                                    disc = (afterDisc.round());
                                  } else {
                                    disc = 0;
                                  }
                                  //currentString = DateFormat('yyyy-MM-dd HH:mm:ss').format(current);

                                  var current2 =
                                      DateTime.parse(DateTime.now().toString());
                                  var currentString2 =
                                      DateFormat('yyyy-MM-dd HH:mm:ss')
                                          .format(current2);

                                  if (widget.idPembayaran == 2) {
                                    TransaksiDetailPembelianModel course =
                                        TransaksiDetailPembelianModel({
                                      'id_barang': idBarang,
                                      'id_sub_transaksi': 0,
                                      'id_transaksi': id,
                                      'qty': jml,
                                      'harga': harga,
                                      'id_delivery': delivery,
                                      'status': 3,
                                      'diskon': disc,
                                      'catatan': catatan.text,
                                      'created_at': currentString2,
                                      'kode_transaksi': kodeTransaksiPref,
                                      'total': total
                                    });
                                    await helper!
                                        .createDetailTransaksiPembelian(course);

                                    setState(() {
                                      _isLoading = false;
                                    });
                                  } else {
                                    TransaksiDetailPembelianModel course =
                                        TransaksiDetailPembelianModel({
                                      'id_barang': idBarang,
                                      'id_sub_transaksi': idSubInt,
                                      'qty': jml,
                                      'harga': harga,
                                      'id_delivery': delivery,
                                      'status': 1,
                                      'diskon': disc,
                                      'catatan': catatan.text,
                                      'created_at': currentString2,
                                      'kode_transaksi': kodeTransaksiPref,
                                      'total': total
                                    });
                                    await helper!
                                        .createDetailTransaksiPembelian(course);

                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }

                                  dataProduk = [];
                                  additionalData = [];
                                  plusMinusToping = [];
                                  initValue = 0;

                                  plusMinus = TextEditingController(text: "1");
                                  //  diskon = TextEditingController(text: "");

                                  Navigator.pop(context);

                                  refreshJumlahPembelian();
                                  if (widget.idPembayaran == 2) {
                                    transaksiDiDepan();
                                  } else {
                                    catatanToping();
                                  }

                                  bottomBayarLandScape();
                                  bottomBayarPotrait();

                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //       builder: (context) => TransPenjualan(
                                  //             tanggal: widget.tanggal,
                                  //             delivery: delivery.toString(),
                                  //           )),
                                  // );

                                  //catatanToping();
                                  // content();

                                  final dbClient = KasirHelper.db;

                                  if (widget.idPembayaran == 2) {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    sendToMysql(
                                        kodeBarang,
                                        jml,
                                        harga,
                                        3,
                                        disc,
                                        catatan.text,
                                        currentString2,
                                        idSubInt,
                                        id,
                                        kodeTransaksiPref,
                                        total);
                                  } else {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    sendToMysql(
                                        kodeBarang,
                                        jml,
                                        harga,
                                        1,
                                        disc,
                                        catatan.text,
                                        currentString2,
                                        idSubInt,
                                        0,
                                        kodeTransaksiPref,
                                        total);
                                  }
                                },
                                icon: const Icon(
                                  Icons.save_outlined,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  "Simpan",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void sendToMysqlEdit(
      idTrx, kodeBarang, jml, harga, disc, catatan, waktu) async {
    Map data = {
      'id_transaksi': idTrx,
      'id_barang': kodeBarang,
      'qty': jml,
      'harga': harga,
      'diskon': disc,
      'catatan': catatan,
      'created_at': waktu,
    };

    String url;

    url = 'edit_detail_transaksi_pembelian';

    // final response = await htpp.post(Uri.parse(url), body: data);
    final response = await Network().getData_post(data, url);
    // var c = json.decode(response.body);

    if (response.statusCode == 200) {
      print('sukses');
    } else {
      print(response.body);
      throw Exception(response);
    }
  }

  void sendToMysqlSub(idSub, idBarang, qty, harga) async {
    Map data = {
      'id_sub_transaksi': idSub,
      'qty': qty,
      'id_barang': idBarang,
      'harga': harga,
    };

    String url;

    url = 'simpanSubDetail';

    // final response = await htpp.post(Uri.parse(url), body: data);
    final response = await Network().getData_post(data, url);
    // var c = json.decode(response.body);

    if (response.statusCode == 200) {
      await helper!.sync(idSub, 0, 'tb_sub_detail_transaksi_pembelian');
    } else {
      print(response.body);
      throw Exception(response);
    }
  }

  void sendToMysql(id, jml, harga, sts, disc, catatan, waktu, idSub, idTrans,
      kodeTransaksiPref, total) async {
    Map data;

    if (idTrans != 0) {
      data = {
        'id_barang': id,
        'id_transaksi': idTrans,
        'qty': jml,
        'harga': harga,
        'status': sts,
        'diskon': disc,
        'catatan': catatan,
        'created_at': waktu,
        'id_sub_transaksi': idSub,
        'kode_transaksi': kodeTransaksiPref,
        'total': total
      };
    } else {
      data = {
        'id_barang': id,
        'qty': jml,
        'harga': harga,
        'status': sts,
        'diskon': disc,
        'catatan': catatan,
        'created_at': waktu,
        'id_sub_transaksi': idSub,
        'kode_transaksi': kodeTransaksiPref,
        'total': total
      };
    }

    String url;

    url = 'save_detail_trans_pembelian';

    // final response = await htpp.post(Uri.parse(url), body: data);
    final response = await Network().getData_post(data, url);
    // var c = json.decode(response.body);

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      print('sukses');

      //   await helper!.sync(idTrans, 'id', 'tb_detail_transaksi_pembelian');
    } else {
      print(response.body);

      var body = jsonDecode(response.body);

      if (response.statusCode == 401) {
        SharedPreferences localStorage = await SharedPreferences.getInstance();

        await localStorage.remove('token');
        await localStorage.remove('user');
        await localStorage.remove('shift_id');

        await localStorage.remove('kategori');
        await localStorage.remove('pencarian');
        await localStorage.remove('stok');
        await localStorage.remove('kategoriDalamContainer');

        // await _logout(localStorage);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      }
      throw Exception(response);
    }
  }

  void refreshKategori() {
    if (helper != null) {
      helper!.allCategori().then((courses) {
        setState(() {
          allKategori = courses;

          Katitems = allKategori;
          _isLoading = false;
        });
      });
    }
  }

  void filterSeach(String query) async {
    var allProduk = ref.watch(dynamicListProvider);
    var dummySearchList = allProduk;
    if (query.isNotEmpty) {
      var dummyListData = [];
      for (var item in dummySearchList) {
        var course = ProdukModel.fromMap(item);
        if (course.namaBarang!.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      }
      setState(() {
        _data = [];
        _data.addAll(dummyListData);
      });

      return;
    } else {
      setState(() {
        _data = [];
        _data = allProduk;
      });
    }
  }

  Expanded _buildList() {
    // print("seleksiii $items");

    return Expanded(
        child: Container(
      child: ListView.builder(
        itemCount: items.length,
        // shrinkWrap: true,
        // physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          // ProdukModel? course = ProdukModel.fromMap(items[index]);
          return GestureDetector(
            onTap: () {
              final stok = items[index]['stok'] ?? 0;

              // if (stok < 5) {
              //   // ❌ Tidak boleh lanjut
              //   ScaffoldMessenger.of(context).showSnackBar(
              //     const SnackBar(
              //         content: Text('Stok kurang dari 5, tidak bisa dipilih')),
              //   );
              //   return;
              // }
              setState(() {
                kumpulanData.clear();
                kumpulanData.add(items[index]);
              });
              Navigator.pop(context);
              showDialogWithCount(items[index]);
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                // color: Colors.white,
              ),
              height: 60,
              width: double.infinity,
              child: Material(
                elevation: 4.0,
                borderRadius: BorderRadius.circular(5.0),
                color: index % 2 == 0
                    ? Colors.white
                    : const Color.fromARGB(255, 226, 232, 230),
                child: Center(
                  child: Row(
                    //    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(top: 9, left: 9),
                            child: Text(
                                "${items[index]['kode']} (${items[index]['stok']})",
                                style: const TextStyle(
                                    fontSize: 15, color: Colors.blue)),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 15, left: 9),
                            child: Text(items[index]['nama_barang'].toString(),
                                style: const TextStyle(fontSize: 13)),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.only(top: 15, right: 10),
                        child: Text("IDR ${items[index]['harga_jual']}",
                            style: const TextStyle(fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ));
  }
}

class Item {
  final String id;
  final String name;
  final String harga;
  final String kode;

  Item(
      {required this.id,
      required this.name,
      required this.harga,
      required this.kode});

  factory Item.fromJson(Map<String, dynamic> json) {
    return new Item(
      id: json['id'],
      name: json['name'],
      harga: json['harga'],
      kode: json['kode'],
    );
  }
}

class DataProvider extends ChangeNotifier {
  List<TransaksiDetailPembelianModel> _cachedData = [];

  List<TransaksiDetailPembelianModel> get cachedData => _cachedData;

  void cacheData(List<TransaksiDetailPembelianModel> data) {
    _cachedData = data;
    notifyListeners();
  }
}

class UtilityProduk {
  static Image imageFromBase64String(String? base64String) {
    try {
      if (base64String == null || base64String.isEmpty) {
        return Image.asset(
          'images/no_image.png',
          fit: BoxFit.cover,
          height: 60,
          width: double.infinity,
        );
      }

      // Buang prefix kalau ada
      final cleaned = base64String.contains(',')
          ? base64String.split(',').last
          : base64String;

      return Image.memory(
        base64Decode(cleaned),
        fit: BoxFit.cover,
        height: 60,
        width: double.infinity,
      );
    } catch (e) {
      debugPrint("⚠️ Invalid base64 image: $e");
      return Image.asset(
        'images/no_image.png',
        fit: BoxFit.cover,
        height: 60,
        width: double.infinity,
      );
    }
  }
}
