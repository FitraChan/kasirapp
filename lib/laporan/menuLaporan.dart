import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:kasirapp/laporan/allLaporanPerBulan.dart';
import 'package:kasirapp/laporan/allLaporanPerBulanSqlite.dart';
import 'package:kasirapp/laporan/allLaporanPerHari.dart';
import 'package:kasirapp/laporan/allLaporanPerHariSqlite.dart';
import 'package:kasirapp/laporan/allLaporanPerTahun.dart';
import 'package:kasirapp/laporan/daftarKomisiPerBulan.dart';
import 'package:kasirapp/laporan/daftarKomisiPerHari.dart';
import 'package:kasirapp/laporan/laporanKas.dart';
import 'package:kasirapp/laporan/mutasiStok.dart';

import 'package:kasirapp/network_utils/api.dart';
import 'package:intl/intl.dart';

import 'package:kasirapp/screen/home.dart';

//import 'package:charts_flutter/flutter.dart' as charts;

import '../screen/menu1.dart';

//import 'package:firebase_messaging/firebase_messaging.dart';

class MenuLaporan extends StatefulWidget {
  const MenuLaporan({Key? key}) : super(key: key);

  @override
  _MenuLaporanState createState() => _MenuLaporanState();
}

class _MenuLaporanState extends State<MenuLaporan> {
  final List MenuLap = [
    // "Penjualan Terbanyak",
    // "Keuntungan Per Hari",
    // "Pembayaran Per Hari",
    "Rangkuman Laporan Harian",
    "Rangkuman Laporan Bulanan",
    "Rangkuman Laporan Tahunan",
    "Rangkuman Komisi Penjualan Harian",
    "Rangkuman Komisi Penjualan Bulanan",
    "Rangkuman Mutasi Stok",
    "Laporan Kas",
    "Rangkuman Laporan Harian Lokal",
    "Rangkuman Laporan Bulanan Lokal",
    // "Akutansi Laporan Bulanan"
  ];

  final List MenuLapBawah = [
    // "Laporan penjualan terbanyak per bulan",
    // "Laporan keuntungan perhari",
    // "Laporan pembayaran dirangkum perhari",
    "Lihat laporan harian",
    "Lihat laporan bulanan",
    "Lihat laporan tahunan",
    "Lihat laporan komisi penjualan harian",
    "Lihat laporan komisi penjualan bulanan",

    "Lihat laporan Mutasi Stok",
    "Lihat laporan Kas",

    "Lihat laporan harian Lokal",
    "Lihat laporan bulanan Lokal",
  ];

  static List url = [
    const AllLaporanPerHari(title: ""),
    const AllLaporanPerBulan(title: ""),
    const AllLaporanPerTahun(title: ""),
    const DaftarTransaksi(title: ""),
    const DaftarTransaksiBulanan(title: ""),
    const MutasiStok(),
    const LaporanKas(title: ""),
    const AllLaporanPerHariSqlite(title: ""),
    const AllLaporanPerBulanSqlite(title: ""),
  ];

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
                      title: "",
                    )),
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
                'Menu Laporan',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              leading: IconButton(
                icon: const Icon(
                  Icons.home,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Home(title: ""),
                    ),
                    (route) => false,
                  );
                },
              )),
          //drawer: const Menu(),
          body: _buildContent(),
        ));
  }

  Widget _buildContent() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: MenuLap.length,
      itemBuilder: (context, index) {
        return _buildMenuCard(index);
      },
    );
  }

  Widget _buildMenuCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        elevation: 4,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => url[index]),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                /// ICON
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.bar_chart_rounded,
                    color: Colors.red,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 18),

                /// TEXT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        MenuLap[index],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        MenuLapBawah[index],
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                /// ARROW
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: Colors.grey,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
