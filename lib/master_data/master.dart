import 'package:flutter/material.dart';
import 'package:kasirapp/master_data/kategori.dart';
import 'package:kasirapp/master_data/pelanggan.dart';
import 'package:kasirapp/master_data/produk.dart';
import 'package:kasirapp/master_data/selisihSaldo.dart';
import 'package:kasirapp/master_data/supplier.dart';
import 'package:kasirapp/screen/home.dart';
import 'package:kasirapp/screen/menu1.dart';
//import 'package:kasirapp/transaksi/history.dart';

//import 'package:firebase_messaging/firebase_messaging.dart';

class Master extends StatefulWidget {
  const Master({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MasterState createState() => _MasterState();
}

class _MasterState extends State<Master> {
  //  FirebaseMessaging messaging;

  String? email;
  //String? nim;
  String? notificationText;
  String? kewajiban;
  String? bayar;
  String? tunggakan;

  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
              //Menambahkan TitleBar
              title: const Text('Master Data'),
              //Mengubah Warna Background
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 1,
              //Menambahkan Leading menu
              leading: IconButton(
                icon: const Icon(Icons.home, color: Colors.black),
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
              //Menambahkan Beberapa Action Button
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.call, color: Colors.white),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
            drawer: const Menu(),
            backgroundColor: Colors.grey[300],
            body: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  columnCenter(),
                  // menuUtama(),
                  const SizedBox(height: 15),
                ]))));
  }

  Column columnCenter() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // menuItem(
        //   title: "Saldo",
        //   subtitle: "Uang Fisik",
        //   color: Colors.blue[800]!,
        //   onTap: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //           builder: (context) => const SelisihSaldo(title: '')),
        //     );
        //   },
        // ),
        const SizedBox(height: 10),
        menuItem(
          title: "Client",
          subtitle: "Data Pelanggan",
          color: Colors.blue[800]!,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const Pelanggan(title: '')),
            );
          },
        ),
        menuItem(
          title: "Supplier",
          subtitle: "Data Supplier",
          color: const Color.fromARGB(255, 6, 167, 152),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const Supplier(title: '')),
            );
          },
        ),
        const SizedBox(height: 10),
        menuItem(
          title: "Kategori",
          subtitle: "Data Kategori Barang",
          color: Colors.blue[800]!,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const Kategori(
                        title: '',
                        tambah: 0,
                      )),
            );
          },
        ),
        const SizedBox(height: 10),
        menuItem(
          title: "Barang",
          subtitle: "Data Barang",
          color: const Color.fromARGB(255, 6, 167, 152),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const Produk(
                        title: '',
                        tambah: 0,
                      )),
            );
          },
        ),
      ],
    );
  }

  Widget menuItem({
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        elevation: 4,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            height: 85,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.folder_open,
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyBullet extends StatelessWidget {
  const MyBullet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 5.0,
      width: 5.0,
      decoration: const BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
    );
  }
}
