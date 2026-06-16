import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:kasirapp/model/currencyFormatter.dart';
import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:kasirapp/network_utils/api.dart';
import 'package:kasirapp/screen/home.dart';
import 'package:kasirapp/sync/syncServiceHutangSupplier.dart';
import 'package:kasirapp/transaksi/detailHutangKeSupplier.dart';

class HutangSupplierPage extends StatefulWidget {
  const HutangSupplierPage({super.key});

  @override
  State<HutangSupplierPage> createState() => _HutangSupplierPageState();
}

class _HutangSupplierPageState extends State<HutangSupplierPage> {
  List<Hutang> hutangList = [];
  bool isLoading = true;
  String filterStatus = 'all';
  KasirHelper? helper;

  // double get totalSisa => hutangList.fold(0, (sum, item) => sum + item.sisa);

  final syncHutangSupplier = SyncServiceHutangSupplier();
  final currencyFormatter = CurrencyFormatter();
  double? totalSisa;

  @override
  void initState() {
    super.initState();
    helper = KasirHelper();

    _initData();

    loadData();
  }

  Future<void> _initData() async {
    int jumlahHutang = await helper!.countHutangSupplier();

    totalSisa = await helper!.getTotalSisaHutang();
    setState(() {
      totalSisa = totalSisa;
    });

    if (jumlahHutang == 0) {
      // 🔥 Jika belum ada data, langsung sync
      await syncHutangSupplier.syncAll();

      loadData();
    }
  }

  Future<void> loadData() async {
    final result = await helper!.getHutangSupplier();

    setState(() {
      data = result;
      isLoading = false;
    });
  }

  List<Hutang> get filteredList {
    if (filterStatus == 'all') return hutangList;
    return hutangList.where((e) => e.status == filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hutang Supplier"),
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildFilter(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: loadData,
                    child: buildHutangList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Total Sisa Hutang",
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 5),
          Text(
            "Rp ${totalSisa?.toStringAsFixed(0) ?? '0'}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilter() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _filterButton("All", "all"),
          _filterButton("Belum Lunas", "belum_lunas"),
          _filterButton("Cicil", "cicil"),
          _filterButton("Lunas", "lunas"),
        ],
      ),
    );
  }

  Widget _filterButton(String text, String value) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: filterStatus == value ? Colors.blue : Colors.grey,
      ),
      onPressed: () {
        setState(() {
          filterStatus = value;
        });
      },
      child: Text(text),
    );
  }

  List<Map<String, dynamic>> data = [];

  Widget buildHutangList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (data.isEmpty) {
      return const Center(child: Text("Tidak ada hutang"));
    }

    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        final hutang = data[index];

        final status = hutang['status'] ?? '';
        final jatuhTempo = hutang['jatuh_tempo'] ?? '';
        final sisa =
            "Rp ${currencyFormatter.format(hutang['sisa'].toString())}";
        final total =
            "Rp ${currencyFormatter.format(hutang['total'].toString())}";
        final supplier = hutang['nama_supplier'] ?? '-';

        // 🔥 warna status
        Color warna;
        if (status == 'lunas') {
          warna = Colors.green;
        } else if (jatuhTempo != '' &&
            DateTime.parse(jatuhTempo).isBefore(DateTime.now())) {
          warna = Colors.red;
        } else {
          warna = Colors.orange;
        }

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            contentPadding: const EdgeInsets.all(10),

            // 🏷️ nama supplier
            title: Text(
              supplier,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            // 📄 detail hutang
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Total: Rp $total"),
                Text("Sisa: Rp $sisa"),
                Text("Jatuh Tempo: $jatuhTempo"),
                Text("Kode Hutang: ${hutang['kode_hutang'] ?? '-'}"),
              ],
            ),

            // 🎨 status
            trailing: Chip(
              label: Text("Detail"),
              backgroundColor: warna,
            ),

            // 👉 klik detail
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailHutangPage(data: hutang),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class Hutang {
  final int id;
  final String supplier;
  final double total;
  final double sisa;
  final String status;
  final String jatuhTempo;

  Hutang({
    required this.id,
    required this.supplier,
    required this.total,
    required this.sisa,
    required this.status,
    required this.jatuhTempo,
  });
}
