import 'package:flutter/material.dart';
import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:kasirapp/sync/syncServiceBayarHutangSupplier.dart';
import 'package:kasirapp/transaksi/bayarHutangSupplier.dart';
import 'package:kasirapp/model/currencyFormatter.dart';
import 'package:intl/intl.dart';

class DetailHutangPage extends StatefulWidget {
  final Map<String, dynamic> data;

  const DetailHutangPage({super.key, required this.data});

  @override
  State<DetailHutangPage> createState() => _DetailHutangPageState();
}

class _DetailHutangPageState extends State<DetailHutangPage> {
  List<Map<String, dynamic>> pembayaran = [];
  bool isLoading = true;
  final currencyFormatter = CurrencyFormatter();
  KasirHelper? helper;
  final syncBayarHutangSupplier = SyncServiceBayarHutangSupplier();

  @override
  void initState() {
    super.initState();
    _initData();

    loadHutangDetail();
  }

  Future<void> _initData() async {
    final dbHelper = KasirHelper();

    int jumlahHutang = await dbHelper.countBayarHutangSupplier();

    if (jumlahHutang == 0) {
      // 🔥 Jika belum ada data, langsung sync
      await syncBayarHutangSupplier.syncAll();
    }

    loadPembayaran();
  }

  Future<void> loadPembayaran() async {
    final dbHelper = KasirHelper();
    final result =
        await dbHelper.getPembayaranByHutang(widget.data['kode_hutang']);

    setState(() {
      pembayaran = result;
      isLoading = false;
    });
  }

  Color getStatusColor(String status, String jatuhTempo) {
    if (status == 'lunas') return Colors.green;

    if (jatuhTempo.isNotEmpty &&
        DateTime.parse(jatuhTempo).isBefore(DateTime.now())) {
      return Colors.red;
    }

    return Colors.orange;
  }

  Map<String, dynamic>? hutangDetail;
  Future<void> loadHutangDetail() async {
    final dbHelper = KasirHelper();
    final result = await dbHelper.getHutangById(widget.data['id']);

    setState(() {
      hutangDetail = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Hutang"),
      ),
      body: Column(
        children: [
          _buildHeader(
            widget.data['nama_supplier'] ?? '-',
            hutangDetail?['total'] ?? 0,
            hutangDetail?['sisa'] ?? 0,
            hutangDetail?['status'] ?? '',
            hutangDetail?['jatuh_tempo'] ?? '',
            getStatusColor(
              hutangDetail?['status'] ?? '',
              hutangDetail?['jatuh_tempo'] ?? '',
            ),
            hutangDetail?['kode_hutang'] ?? '',
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              "Histori Pembayaran",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : pembayaran.isEmpty
                    ? const Center(child: Text("Belum ada pembayaran"))
                    : ListView.builder(
                        itemCount: pembayaran.length,
                        itemBuilder: (context, index) {
                          final item = pembayaran[index];

                          return ListTile(
                            leading: const Icon(Icons.payment),
                            title: Text(
                                "Rp ${currencyFormatter.format(item['jumlah_bayar'].toString())}"),
                            subtitle: Text(
                              DateFormat('dd-MM-yyyy')
                                  .format(DateTime.parse(item['tanggal'])),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),

      // 🔥 tombol bayar
      floatingActionButton: hutangDetail != null &&
              hutangDetail!['sisa'] != null &&
              hutangDetail!['sisa'] > 0
          ? FloatingActionButton.extended(
              backgroundColor: Colors.blue,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => BayarDialog(
                    kodeHutang: hutangDetail?['kode_hutang'] ?? '',
                    sisa: hutangDetail?['sisa'] ?? 0,
                    onSuccess: () async {
                      await loadPembayaran();
                      await loadHutangDetail();
                      // setState(() {
                      //   final newData = Map<String, dynamic>.from(data);
                      //   newData['sisa'] = 0;
                      //   newData['status'] = 'lunas';
                      // });
                    },
                  ),
                );
              },
              label: const Text("Bayar"),
              icon: const Icon(Icons.payment),
            )
          : null,
    );
  }

  // ================= HEADER =================
  Widget _buildHeader(String supplier, total, sisa, status, String jatuhTempo,
      Color warna, String kodeHutang) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: warna.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Supplier: $supplier"),
          const SizedBox(height: 5),
          Text("Total: Rp ${currencyFormatter.format(total.toString())}"),
          Text("Sisa: Rp ${currencyFormatter.format(sisa.toString())}"),
          Text("Jatuh Tempo: $jatuhTempo"),
          Text("Kode Hutang: $kodeHutang"),
          const SizedBox(height: 10),
          Chip(
            label: Text(status),
            backgroundColor: warna,
          ),
        ],
      ),
    );
  }
}
