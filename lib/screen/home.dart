import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:intl/intl.dart';

import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:kasirapp/laporan/komisiUser.dart';

import 'package:kasirapp/screen/login.dart';
import 'package:kasirapp/screen/menu1.dart';
import 'package:kasirapp/screen/menu2.dart';
import 'package:kasirapp/master_data/master.dart';

import 'package:kasirapp/laporan/menuLaporan.dart';
import 'package:kasirapp/transaksi/barangMasuk.dart';
import 'package:kasirapp/transaksi/listOrder.dart';
import 'package:kasirapp/transaksi/penerimaan.dart';
import 'package:kasirapp/transaksi/pengeluaran.dart';
import 'package:kasirapp/transaksi/penjualan.dart';
import 'package:kasirapp/sync/autoSync.dart';

import 'package:kasirapp/transaksi/transPenjualan.dart';
import 'package:kasirapp/screen/barcodeScan.dart';
import 'package:kasirapp/screen/csvImport.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //  FirebaseMessaging messaging;
  int _selectedIndex = 0;
  String? name;
  String? level;
  String? email;
  //String? nim;
  String? notificationText;
  String? kewajiban;
  String? bayar;
  String? tunggakan;
  var items = [];
  KasirHelper? helper;
  final oCcy = NumberFormat.decimalPattern();
  String? _dropdownError;
  TextEditingController teSeach = TextEditingController();

  TextEditingController keterangan = TextEditingController();

  TextEditingController harga = TextEditingController();
  TextEditingController subTotal = TextEditingController();
  late TextEditingController diskon = TextEditingController();
  TextEditingController priceAfterDiscount = TextEditingController();

  TextEditingController nilai = TextEditingController();

  TextEditingController keteranganPenerimaan = TextEditingController();
  TextEditingController nilaiPenerimaan = TextEditingController();

  var allProduk = [];
  var allPembayaran = [];

  var newData;
  var pembayaran = [];
  var count;

  var allDetailTrans = [];
  var DetailTrans = [];
  var showJumlahTrx = [];
  // String? _mySelection;

  // final _streamController = StreamController<int>();
  // Stream<int> get _stream => _streamController.stream;
  // Sink<int> get _sink => _streamController.sink;
  int initValue = 1;
  TextEditingController plusMinus = TextEditingController();
  int hasilDiskon = 1;
  var current;
  var currentString;
  var allKategori = [];
  var Katitems = [];
  bool isConnected = false;
  KasirHelper helpers = KasirHelper();

  SyncService syncService = SyncService();
  bool isSyncing = false;

  void autosync() async {
    if (!isSyncing) {
      isSyncing = true;
      print('Mulai auto-sync...');
      await syncService.autoSyncSavePembayaran();
      await syncService.autoSyncProduk();
      await syncService.autoSyncPenerimaan();
      await syncService.autoSyncPengeluaran();
      await syncService.autoSyncBarangMasuk();

      isSyncing = false;
    }
  }

  @override
  void initState() {
    super.initState();
    autosync();

    current = DateTime.parse(DateTime.now().toString());

    currentString = DateFormat('yyyy-MM-dd HH:mm:ss').format(current);

    _loadUserData();
    _checkToken();
    // _sink.add(initValue);
    // _stream.listen((event) => plusMinus.text = event.toString());

    // current = DateTime.parse(DateTime.now().toString());

    // currentString = DateFormat('yyyy-MM-dd HH:mm:ss').format(current);

    helper = KasirHelper();

    // if (helper != null) {
    //   helper!.showJumlahTransaksi(currentString).then((product) {
    //     setState(() {
    //       showJumlahTrx = product;
    //     });
    //   });
    // }

    // if (helper != null) {
    //   helper!.showPembelian().then((courses) {
    //     setState(() {
    //       allDetailTrans = courses;
    //       DetailTrans = allDetailTrans;

    //       //_isLoading = false;
    //     });
    //   });
    // }

    // if (helper != null) {
    //   helper!.allProduk().then((product) {
    //     setState(() {
    //       items = product;
    //       allProduk = product;
    //       items = allProduk;
    //     });
    //   });
    // }

    // if (helper != null) {
    //   helper!.allCourses().then((courses) {
    //     setState(() {
    //       allKategori = courses;
    //       Katitems = allKategori;
    //     });
    //   });
    // }
  }

  _checkToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');

    if (token == null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
        (route) => false,
      );
    }
  }

  _loadUserData() async {
    try {
      SharedPreferences localStorage = await SharedPreferences.getInstance();

      var a = localStorage.getString('user');

      if (a != null && a.isNotEmpty) {
        var user = jsonDecode(a);

        setState(() {
          name = user['name'] ?? '';
          level = user['level'].toString() ?? '';
        });
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Login(),
          ),
        );
      }
    } catch (e) {
      print("Error load user data: $e");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Login(),
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      HomeScreen(
        current: DateTime.parse(DateTime.now().toString()),
        level: level ?? '',
      ),
      Penerimaan(
        title: "",
        tambah: 0,
      ),

      Pengeluaran(
        title: "",
        tambah: 0,
      ),
      //SettingsScreen(),
    ];

    return Scaffold(
      key: _scaffoldKey,
      drawer: (level.toString() == "1" || level.toString() == "5")
          ? const Menu()
          : const Menu2(),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        elevation: 0,
        title: Row(
          children: [
            // CircleAvatar(
            //   backgroundImage: NetworkImage('https://via.placeholder.com/150'),
            // ),
            SizedBox(width: 10),
            Text('Store', style: TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
          // badges.Badge(
          //   showBadge: showJumlahTrx.isNotEmpty ? true : false,
          //   position: badges.BadgePosition.topEnd(top: 5, end: 2),
          //   badgeContent: Text(showJumlahTrx.length.toString()),
          //   child: IconButton(
          //     icon: const Icon(Icons.trolley, color: Colors.white),
          //     onPressed: () {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //             builder: (context) => Penjualan(
          //                   tanggal: currentString,
          //                 )),
          //       );
          //     },
          //   ),
          // ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Penerimaan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Pengeluaran',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.settings),
          //   label: 'Settings',
          // ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final DateTime current;

  final String level;
  // Konstruktor dengan parameter named
  HomeScreen({Key? key, required this.current, required this.level})
      : super(key: key);

  //var currentString = current;

  final List<MenuOption> menuOptions = [
    MenuOption(
        icon: Icons.shopping_cart, title: 'Produk', color: Colors.blue[100]!),
    MenuOption(
        icon: Icons.people, title: 'Penjualan', color: Colors.orange[100]!),
    MenuOption(
        icon: Icons.add_shopping_cart,
        title: 'Laporan',
        color: Colors.green[100]!),
    MenuOption(
        icon: Icons.card_giftcard, title: 'In', color: Colors.teal[100]!),
    MenuOption(icon: Icons.list, title: 'Out', color: Colors.blue[100]!),
    MenuOption(icon: Icons.store, title: 'List Order', color: Colors.red[100]!),
    MenuOption(
        icon: Icons.store, title: 'Barang Masuk', color: Colors.purple[100]!),
    MenuOption(
        icon: Icons.qr_code_scanner,
        title: 'Scan Barcode',
        color: Colors.deepPurple[100]!),
    MenuOption(
        icon: Icons.import_export,
        title: 'Import CSV',
        color: Colors.amber[100]!),
  ];

  final List<MenuOption> menuOptions2 = [
    MenuOption(
        icon: Icons.people, title: 'Penjualan', color: Colors.orange[100]!),
    MenuOption(
        icon: Icons.card_giftcard, title: 'In', color: Colors.teal[100]!),
    MenuOption(icon: Icons.list, title: 'Out', color: Colors.blue[100]!),
    MenuOption(icon: Icons.store, title: 'List Order', color: Colors.red[100]!),
    MenuOption(
        icon: Icons.add_shopping_cart,
        title: 'Komisi',
        color: Colors.green[100]!),
    MenuOption(
        icon: Icons.store, title: 'Barang Masuk', color: Colors.purple[100]!),
    MenuOption(
        icon: Icons.qr_code_scanner,
        title: 'Scan Barcode',
        color: Colors.deepPurple[100]!),
    MenuOption(
        icon: Icons.import_export,
        title: 'Import CSV',
        color: Colors.amber[100]!),
  ];

  final List<String> imagePaths = [
    'images/database.png',
    'images/troly.png',
    'images/document.png',
    'images/bar.png',
    'images/master_data.png',
    'images/outcome.png',
    'images/income2.png',
    'images/income2.png',
    'images/database.png',
  ];

  @override
  Widget build(BuildContext context) {
    String currentString = DateFormat('yyyy-MM-dd HH:mm:ss').format(current);

    List url = [
      Master(
        title: '',
      ),
      TransPenjualan(
        tanggal: currentString,
        delivery: "1",
        idPembayaran: 0,
      ),
      MenuLaporan(),
      Penerimaan(title: "", tambah: 0),
      Pengeluaran(title: "", tambah: 0),
      ListOrder(title: ""),
      BarangMasuk(
        title: "",
        tambah: 0,
      ),
      const BarcodeScanScreen(),
      const CsvImportScreen(),
    ];

    List url2 = [
      TransPenjualan(
        tanggal: currentString,
        delivery: "1",
        idPembayaran: 0,
      ),
      Penerimaan(title: "", tambah: 0),
      Pengeluaran(title: "", tambah: 0),
      ListOrder(title: ""),
      KomisiUser(title: ""),
      BarangMasuk(
        title: "",
        tambah: 0,
      ),
      const BarcodeScanScreen(),
      const CsvImportScreen(),
    ];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
              ),
              itemCount:
                  level == '1' ? menuOptions.length : menuOptions2.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    level == '1'
                        ? Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => url[index]))
                        : Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => url2[index]));
                  },
                  child: Card(
                    color: level == '1'
                        ? menuOptions[index].color
                        : menuOptions2[index].color,
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          alignment: Alignment.topCenter,
                          width: 50,
                          height: 40,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(imagePaths[index]),
                              fit: BoxFit.fill,
                            ),
                            //shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        level == '1'
                            ? Text(
                                menuOptions[index].title,
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : Text(
                                menuOptions2[index].title,
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 16.0),
            Text('What\'s new',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.0),
            Container(
              height: 160,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  BannerItem(
                    imagePath: 'images/orange.png',
                    title: 'Diskon Spesial!',
                  ),
                  const SizedBox(width: 12),
                  BannerItem(
                    imagePath: 'images/orange.png',
                    title: 'Diskon Spesial!',
                  ),
                  const SizedBox(width: 12),
                  BannerItem(
                    imagePath: 'images/orange.png',
                    title: 'Diskon Spesial!',
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MenuOption {
  final IconData icon;
  final String title;
  final Color color;

  MenuOption({required this.icon, required this.title, required this.color});
}

class BannerItem extends StatelessWidget {
  final String imagePath;
  final String title;

  const BannerItem({super.key, required this.imagePath, required this.title});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Image.asset(
            imagePath,
            width: 280,
            height: 160,
            fit: BoxFit.cover,
          ),
          Container(
            width: 280,
            height: 160,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          Positioned(
            left: 12,
            bottom: 12,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black45,
                    offset: Offset(1, 1),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
