import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:badges/badges.dart' as badges;
import 'package:kasirapp/model/rupiahCurrency.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:kasirapp/model/currencyFormatter.dart';
import 'package:kasirapp/model/penerimaanModel.dart';
import 'package:kasirapp/network_utils/api.dart';
import 'package:kasirapp/screen/home.dart';
import 'package:kasirapp/screen/login.dart';
import 'package:intl/date_symbol_data_local.dart'; // WAJIB

import '../screen/menu1.dart';

//import 'package:firebase_messaging/firebase_messaging.dart';

class ListOrder extends StatefulWidget {
  const ListOrder({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _ListOrderState createState() => _ListOrderState();
}

class _ListOrderState extends State<ListOrder> {
  //  FirebaseMessaging messaging;

  TextEditingController teSeach = TextEditingController();

  bool _isLoading = true;
  var current;
  var currentString;
  KasirHelper? helper;
  var items = [];
  var allCourses = [];
  var showJumlahTrx = [];

  var newData;
  final int itemsPerPage = 15;
  int currentPage = 0;
  int jumlah = 0;
  KasirHelper helpers = KasirHelper();
  bool click = true;

  void _refreshPenerimaan() {
    if (helper != null) {
      helper!.allPenerimaan().then((courses) {
        setState(() {
          allCourses = courses;
          items = allCourses;
          _isLoading = false;
        });
      });
    }
  }

  var allTrans = [];
  //var allDetailTrans = [];
  var Trans = [];
  int? idTrx = 0;
  var selectDetailPembelian = [];
  List detailTrans = [];
  List allDetailTransaksi = [];
  List<List> AllData = [];

  List<List> all = [];

  List allPembayaran = [];
  var count;

  @override
  void initState() {
    super.initState();
    // restoreToMysql();
    _refreshPenerimaan();
    _loadData();
    current = DateTime.parse(DateTime.now().toString());

    currentString = DateFormat('yyyy-MM-dd').format(current);

    helper = KasirHelper();

    if (helper != null) {
      helper!.hitungPembelianNotSync(currentString).then((course) {
        setState(() {
          allPembayaran = course;
          count = allPembayaran.first['harga'];
        });
      });
    }

    if (helper != null) {
      helper!.showJumlahTransaksiNotSync(currentString).then((product) {
        setState(() {
          showJumlahTrx = product;
        });
      });
    }
  }

  String? name;
  int? idUser;
  String? level;
  _loadUserData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    //print(localStorage.getString('user'));

    var a = localStorage.getString('user');

    //print(user);

    if (a != null) {
      var user = jsonDecode(localStorage.getString('user') ?? '');

      setState(() {
        name = user['name'];

        idUser = user['id'];
        level = user['level'];
      });
    } else {
      // Login();

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    }
  }

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nilaiController = TextEditingController();

  Future<void> _refreshLoadData(status) async {
    current = DateTime.parse(DateTime.now().toString());

    currentString = DateFormat('yyyy-MM-dd').format(current);

    newData = await helpers.daftarPesanan(
        currentString, itemsPerPage, currentPage * itemsPerPage, status);

    setState(() {
      Trans.clear();
      Trans.addAll(newData);
    });

    for (var x = 0; x < Trans.length; x++) {
      idTrx = 0;
      idTrx = Trans[x]['id'];

      AllData = [];
      helper!.orderBelumSync(idTrx, 1).then((cou) {
        selectDetailPembelian = cou;

        // for (var a = 0; a < 1; a++) {
        allDetailTransaksi = cou;
        detailTrans = allDetailTransaksi;

        // AllData.clear();
        AllData.add(detailTrans);
        //  }
        setState(() {
          all = AllData;
        });

        //print(AllData);
      });
    }

    if (jumlah == Trans.length) {
      setState(() {
        click = false;
      });
    }
  }

  Future<void> _loadData() async {
    current = DateTime.parse(DateTime.now().toString());

    currentString = DateFormat('yyyy-MM-dd').format(current);

    newData = await helpers.daftarPesanan(
        currentString, itemsPerPage, currentPage * itemsPerPage, 1);

    setState(() {
      Trans.addAll(newData);
    });

    for (var x = 0; x < Trans.length; x++) {
      idTrx = 0;
      idTrx = Trans[x]['id'];

      AllData = [];
      helper!.orderBelumSync(idTrx, 1).then((cou) {
        selectDetailPembelian = cou;

        // for (var a = 0; a < 1; a++) {
        allDetailTransaksi = cou;
        detailTrans = allDetailTransaksi;
        AllData.add(detailTrans);
        //  }
        setState(() {
          all = AllData;
        });

        //print(AllData);
      });
    }

    if (jumlah == Trans.length) {
      setState(() {
        click = false;
      });
    }
  }

  void _loadMoreData() {
    setState(() {
      currentPage++;
      _loadData();
    });
  }

  Center tombolLoad() {
    return Center(
      child: ElevatedButton(
        onPressed: _loadMoreData,
        child: const Text('Load More'),
      ),
    );
  }

  final currencyFormatter = CurrencyFormatter();
  var delivery;
  final oCcy = NumberFormat.decimalPattern();

  List detailPemesanan = [];
  List<Map<String, dynamic>> daftarDetailPemesanan = [];
  List allDataDaftarPemesanan = [];

  List<Map<String, dynamic>> semuaPemesanan = [];
  List<Map<String, dynamic>> allSemuaPemesanan = [];

  List<Map<String, dynamic>> semuaHutang = [];

  List<Map<String, dynamic>> allHutang = [];

  var idTransaction;
  var tanggal;
  var namaPelanggan;
  var idtransk;
  var tglDb;

  var sisaHutang;
  var totalAll;
  var kode;
  var qty;
  var idBarang;

  void detail(id) async {
    if (helper != null) {
      totalAll = await helper!.tapTotalPembelian(id);

      initializeDateFormatting('id_ID', null);

      helper!.detailPemesanan(id).then((course) {
        detailPemesanan = course;
        tglDb = DateTime.parse(detailPemesanan.first['created_at'].toString());

        setState(() {
          totalAll;
          tanggal = DateFormat("dd MMM yyyy", "id_ID").format(tglDb);
          namaPelanggan =
              detailPemesanan.first['nama'] ?? 'Tidak ada nama pelanggan';
          idtransk = detailPemesanan.first['id'];
          sisaHutang = detailPemesanan.first['sisa_hutang'] ?? 0;
        });
        for (var i = 0; i < detailPemesanan.length; i++) {
          idTransaction = 0;
          idTransaction = detailPemesanan[i]['id'];

          helper!.daftarDetailPemesanan(idTransaction).then((cou) {
            daftarDetailPemesanan = cou;
            // allSemuaPemesanan.add(daftarDetailPemesanan);

            setState(() {
              semuaPemesanan = daftarDetailPemesanan;
              kode = semuaPemesanan.first['kode'];
              qty = semuaPemesanan.first['qty'];
              idBarang = semuaPemesanan.first['id_barang'];
            });

            // print(daftarDetailPemesanan);
          });

          helper!.daftarHutang(idTransaction).then((cou) {
            setState(() {
              semuaHutang = cou;
              allHutang = semuaHutang;
            });
          });
        }
        // print(daftarDetailPemesanan);
      });
    }
  }

  bool tap = false;

  Widget content() {
    final screenHeight = MediaQuery.of(context).size.height - 161;
    final screenwidth = MediaQuery.of(context).size.width - 330;

    return SizedBox(
      width: screenwidth,
      height: screenHeight,
      child: ListView.builder(
        itemCount: Trans.length,
        itemBuilder: (context, index) {
          initializeDateFormatting('id_ID', null);

          var tglRaw = Trans[index]['created_at'].toString();
          var date = DateTime.parse(tglRaw);
          var formattedDate = DateFormat("dd-MMM-yyyy", "id_ID").format(date);
          return GestureDetector(
            onTap: () async {
              setState(() {
                tap = true;
              });

              detail(Trans[index]['id'].toString());
            },
            onLongPress: () async {
              if (Trans[index]['total_hutang'] != null) {
                _showBayar(context, Trans[index]['id']);
              }
            },
            child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🖼️ Logo di sebelah kiri
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Image.asset(
                          'images/troly2.png', // ganti sesuai path logomu
                          width: 36,
                          height: 36,
                        ),
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ID Transaksi

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "#000000${Trans[index]['id']}",
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Text(
                                  formattedDate,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),

                            //  const SizedBox(height: 6),

                            // Daftar Barang
                            //  if (all.isNotEmpty && all[index].isNotEmpty)
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount:
                                  (all.length > index && all[index].isNotEmpty)
                                      ? all[index].length
                                      : 0,
                              itemBuilder: (context, index2) {
                                final transaksi = all[index][index2];
                                final isRetur = transaksi['status'] == 4;
                                final isHutang = transaksi['status'] == 5;

                                final qty = transaksi['qty'];
                                final namaBarang = transaksi['nama_barang'];

                                return GestureDetector(
                                  // onLongPress: () {
                                  //   _showFullRefundDialog(
                                  //     context,
                                  //     transaksi['id_transaksi'].toString(),
                                  //     transaksi['kode'].toString(),
                                  //     transaksi['qty'].toString(),
                                  //     transaksi['id_barang'].toString(),
                                  //   );
                                  // },
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                          child: Row(
                                        children: [
                                          Text(
                                            "$qty x $namaBarang",
                                            style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          SizedBox(
                                            width: 8,
                                          ),
                                          if (isRetur == true)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: const Color.fromARGB(
                                                    255, 212, 104, 15),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: const Text(
                                                'Refund',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            )
                                        ],
                                      )),
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 10),

                            // Total dan Label Hutang
                            Row(
                              children: [
                                Text(
                                  'Rp ${oCcy.format(int.parse(Trans[index]['total'].toString()))}',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                if (Trans[index]['total_hutang'] != null &&
                                    Trans[index]['sisa_hutang'] > 0)
                                  Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Hutang',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ])),
          );
        },
      ),
    );
  }

  Widget rightSide() {
    var screenHeight = MediaQuery.of(context).size.height - 100;

    return Expanded(
        flex: 2,
        child: Container(
          width: 320,
          // height: screenHeight,
          color: Colors.grey.shade100,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "000000${idtransk}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 18),
                  SizedBox(width: 8),
                  Text("${tanggal}"),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.person, size: 18),
                  SizedBox(width: 8),
                  Text(namaPelanggan ?? "Tidak ada nama pelanggan"),
                ],
              ),
              const SizedBox(height: 12),

              if (sisaHutang != 0) // dari sini
                Text(
                  "${oCcy.format(sisaHutang ?? 0)},Sisa hutang on ${tanggal}",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

              ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: allHutang.length,
                  itemBuilder: (context, index) {
                    initializeDateFormatting('id_ID', null);

                    var tglHutang = DateTime.parse(
                        allHutang[index]['created_at'].toString());

                    var tanggalFormat =
                        DateFormat("dd MMM yyyy", "id_ID").format(tglHutang);

                    return Text(
                      "(Rp ${oCcy.format(allHutang[index]['total_bayar'] ?? 0)}, by CASH on ${tanggalFormat} (CONFIRMED))",
                      style: TextStyle(fontSize: 12),
                    );
                  }),

              //sampai sini
              const Divider(height: 24),

              const Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Text("Item",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text("Qty",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text("Jumlah",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),

              // dari sini
              const SizedBox(height: 8),

              ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: semuaPemesanan.length,
                  itemBuilder: (context, index) {
                    var trx = semuaPemesanan[index];
                    return Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                  flex: 5,
                                  child: Text(trx['nama_barang'].toString())),
                              Expanded(
                                  flex: 3,
                                  child: Text(
                                      "${trx['qty']} x ${oCcy.format((trx['harga_jual']) ?? 0)}")),
                              Expanded(
                                  flex: 2,
                                  child: Text(
                                      "${oCcy.format((trx['harga']) ?? 0)}")),
                            ],
                          ),
                          // SizedBox(height: 8),
                          // const Text("Catatan: Kebutuhan urgent"),
                        ],
                      ),
                    );
                  }),
              // sampai sini
              const Divider(),
              Row(
                children: [
                  Text(
                    "Total Harga: ${totalAll != null ? oCcy.format((totalAll)) : 0}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      // Aksi saat ikon ditekan, misalnya tampilkan menu atau dialog
                      _showFullRefundDialog(
                        context,
                        idtransk.toString(),
                        kode.toString(),
                        qty.toString(),
                        idBarang.toString(),
                      );
                    },
                  )
                ],
              )

              //  const Spacer(),

              // IconButton(icon: const Icon(Icons.more_vert), onPressed: () {})
            ],
          ),
        ));
  }

  TextEditingController keterangan = TextEditingController();

  String? _mySelection;

  void _showFullRefundDialog(
    BuildContext context,
    String idTransaksi,
    String kodeBarang,
    String qty,
    String idBarang,
  ) {
    String? tempSelection = _mySelection; // nilai sementara untuk dropdown

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: StatefulBuilder(
            builder: (context, setStateDialog) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.refresh, color: Colors.white),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Pengembalian Penuh',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: const Icon(Icons.close, color: Colors.white),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Alasan Pengembalian
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Alasan Pengembalian',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: keterangan,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Contoh: Barang rusak atau salah kirim',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Pilih Barang
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Pilih Barang',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: tempSelection,
                      isExpanded: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: 'Silakan pilih barang',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                      ),
                      items:
                          semuaPemesanan.map<DropdownMenuItem<String>>((item) {
                        final String id = item['kode'].toString();
                        final String nama = item['nama_barang'] ?? 'Tanpa Nama';
                        return DropdownMenuItem<String>(
                          value: id,
                          child: Text(nama),
                        );
                      }).toList(),
                      onChanged: (String? newVal) {
                        setStateDialog(() {
                          tempSelection = newVal;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Pastikan alasan dan barang yang dipilih sesuai dengan pengembalian.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),

                    const SizedBox(height: 24),

                    // Tombol Simpan
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _mySelection = tempSelection;
                          });
                          simpan(
                              idTransaksi, _mySelection, keterangan.text, qty);
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pengembalian berhasil diproses'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.check),
                        label: const Text(
                          'Lakukan Pengembalian',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  final List<Map<String, dynamic>> metodePembayaran = [
    {"id": 1, "label": "Cash"},
    {"id": 2, "label": "Non Tunai"},
  ];

  TextEditingController typeBayar = TextEditingController();
  TextEditingController jumlahBayar = TextEditingController();
  TextEditingController ref = TextEditingController();
  int? selectedId;

  void _showBayar(BuildContext context, id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Header
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8.0),
                        topRight: Radius.circular(8.0),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      children: <Widget>[
                        const Icon(Icons.shopping_cart_outlined,
                            color: Colors
                                .white), // Assuming a cart icon with a slash, but using a common cart icon
                        const SizedBox(width: 8.0),
                        const Expanded(
                          child: Text(
                            'Pembayaran Hutang',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Body
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Metode Pembayaran',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14.0,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        DropdownButtonFormField<int>(
                          decoration: const InputDecoration(
                            labelText: 'Metode Pembayaran',
                            border: OutlineInputBorder(),
                          ),
                          value: selectedId,
                          items: metodePembayaran.map((item) {
                            return DropdownMenuItem<int>(
                              value: item['id'],
                              child: Text(item['label']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedId = value;
                            });
                          },
                        ),
                        const SizedBox(height: 8.0),
                        TextField(
                          controller: jumlahBayar,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            CurrencyInputFormatter(),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Pembayaran Dimuka',
                            border: OutlineInputBorder(),
                          ),
                          style: const TextStyle(fontSize: 16.0),
                        ),
                        const SizedBox(height: 8.0),
                      ],
                    ),
                  ),
                  // Footer Button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        simpanPembayaranHutang(id, jumlahBayar.text);
                        // Handle "Lakuan" (Do it) button press
                        Navigator.of(context).pop(); // Close the dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Lakuan button pressed!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Button color
                        foregroundColor: Colors.white, // Text color
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              4.0), // Slight border radius for the button
                        ),
                      ),
                      child: const Text(
                        'Lakukan',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ));
      },
    );
  }

  String removeCurrencyFormat(String formattedValue) {
    // Hapus semua karakter yang bukan angka
    String cleanValue = formattedValue.replaceAll(RegExp(r'[^\d]'), '');

    return cleanValue;
  }

  void simpanPembayaranHutang(id, bayar) async {
    String pembayaran = removeCurrencyFormat(bayar);

    final hasil = await helper!.sisaHutang(id, pembayaran);

    helper!.insertHutang(
        id, hasil['total_hutang'], pembayaran, hasil['sisa_hutang']);

    Map data = {
      'id_transaksi_mobile': id,
      'total_bayar': pembayaran,
      'sisa_hutang': hasil['sisa_hutang'],
      'total_hutang': hasil['total_hutang'],
    };

    String url;

    url = 'save_hutang';

    // final response = await htpp.post(Uri.parse(url), body: data);
    final response = await Network().getData_post(data, url);
    // var c = json.decode(response.body);

    if (response.statusCode == 200) {
      await helper!.sync(id, 'id_transaksi', 'tb_hutang');

      Fluttertoast.showToast(
        msg: 'Sukses melakukan pembayaran hutang',
        toastLength: Toast
            .LENGTH_SHORT, // Duration for which the toast should be visible
        gravity: ToastGravity.BOTTOM, // Position of the toast on the screen
        // Font size of the message
      );
    } else {
      print(response.body);
      Fluttertoast.showToast(
        msg: response.body,
        toastLength: Toast
            .LENGTH_SHORT, // Duration for which the toast should be visible
        gravity: ToastGravity.BOTTOM, // Position of the toast on the screen
        // Font size of the message
      );
    }
  }

  void simpan(transId, kodeBarang, keterangan, qty) async {
    Map data = {
      'id_transaksi': transId,
      'id_barang': kodeBarang,
      'keterangan': keterangan,
      'id_pelanggan': '',
      'qty': qty,
    };

    String url;

    url = 'pengembalian';

    // final response = await htpp.post(Uri.parse(url), body: data);
    final response = await Network().getData_post(data, url);
    // var c = json.decode(response.body);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var kode = data['data']['kode'];

      await helper!.pengembalian(transId, kodeBarang, keterangan, '', kode);
    } else {
      print(response.body);
      throw Exception('Failed to load album');
    }
  }
  // Update an existing journal

  // Delete an item

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
            appBar: AppBar(
              //Menambahkan TitleBar
              title: const Text(
                'List Order',
                style: TextStyle(color: Colors.white),
              ),
              //Mengubah Warna Background
              backgroundColor: Colors.blue[900],
              //Menambahkan Leading menu
              leading: IconButton(
                icon: const Icon(Icons.home, color: Colors.white),
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
                badges.Badge(
                  showBadge: showJumlahTrx.isNotEmpty ? true : false,
                  position: badges.BadgePosition.topEnd(top: 5, end: 2),
                  badgeContent: Text(showJumlahTrx.length.toString()),
                  child: IconButton(
                    icon: const Icon(Icons.restore, color: Colors.white),
                    onPressed: () {
                      singkronisasi();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ListOrder(
                                  title: '',
                                )),
                      );
                    },
                  ),
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
                  // students(),
                  Container(
                    width: double.infinity,
                    child: Row(
                      children: [
                        Expanded(child: cari()),
                        SizedBox(width: 8),
                        Expanded(child: dropDown()),
                      ],
                    ),
                  ),

                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    content(),
                    tap ? rightSide() : const Center(),
                  ]),
                  // click ? tombolLoad() : const Center()
                ])
                //)
                )));
  }

  var sync = [];
  int idTrans = 0;
  int idTransaksi = 0;
  List AllDataSync = [];
  List selectDetailPembelianSync = [];
  List allDetailTransaksiSync = [];
  List detailTransSync = [];
  List pembelian = [];

  void singkronisasi() async {
    current = DateTime.parse(DateTime.now().toString());

    currentString = DateFormat('yyyy-MM-dd').format(current);

    var currentString2 = DateFormat('yyyy-MM-dd HH:mm:ss').format(current);

    helper!.showJumlahTransaksiNotSync(currentString).then((product) {
      sync = product;
      for (var i = 0; i < sync.length; i++) {
        idTrans = 0;
        idTrans = sync[i]['id_sub_transaksi'];

        sendToMysqlSync(sync[i]['kode'], sync[i]['qty'], sync[i]['harga'],
            sync[i]['status'], "", sync[i]['catatan'], currentString2, idTrans);

        // detailToping(idTrx);

        helper!.subTransaksiNotSync(idTrans).then((cou) {
          selectDetailPembelianSync = cou;

          for (var a = 0; a < selectDetailPembelianSync.length; a++) {
            allDetailTransaksiSync = cou;
            sendToMysqlSub(
                idTrans,
                allDetailTransaksiSync[a]['kode'],
                allDetailTransaksiSync[a]['qty'],
                allDetailTransaksiSync[a]['harga']);
          }

          //print(AllData);
        });
      }
    });

    helper!.idPembelian().then((courses) {
      pembelian = courses;
      idTransaksi = pembelian.first['id'];
      var allTotal = int.parse(count.toString());

      mysqlCreatePembayaran(allTotal, idTransaksi, 0, 0, idUser, currentString);
    });
  }

  void mysqlCreatePembayaran(
      total, idTrx, dibayar, kembali, idUser, createdAt) async {
    Map data = {
      'total': total,
      'id_transaksi': idTrx,
      'dibayar': dibayar,
      'kembalian': kembali,
      'id_pembeli': idUser,
      'status_bayar': 1,
      'created_at': createdAt,
    };

    String url;

    url = 'save_pembayaran';

    // final response = await htpp.post(Uri.parse(url), body: data);
    final response = await Network().getData_post(data, url);
    // var c = json.decode(response.body);

    if (response.statusCode == 200) {
      print('sukses');

      await helper!.sync(idTrx, 'id', 'tb_transaksi_pembelian');
      await helper!
          .sync(idTrx, 'id_transaksi', 'tb_detail_transaksi_pembelian');
    } else {
      print(response.body);
      throw Exception('Failed to load album');
    }
  }

  void sendToMysqlSync(id, jml, harga, sts, disc, catatan, waktu, idSub) async {
    Map data = {
      'id_barang': id,
      'qty': jml,
      'harga': harga,
      'status': 1,
      'diskon': disc,
      'catatan': catatan,
      'created_at': waktu,
      'id_sub_transaksi': idSub,
    };

    String url;

    url = 'save_detail_trans_pembelian';

    // final response = await htpp.post(Uri.parse(url), body: data);
    final response = await Network().getData_post(data, url);
    // var c = json.decode(response.body);

    if (response.statusCode == 200) {
      print('sukses');

      // await helper!.sync(idTrx, 'id', 'tb_detail_transaksi_pembelian');
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

  List<DropdownItem> dropdownOptions = [
    DropdownItem(value: 1, label: 'Daftar Order'),
    DropdownItem(value: 2, label: 'Daftar Retur Barang'),
    DropdownItem(value: 3, label: 'Daftar Hutang'),
  ];

  DropdownItem? selectedOption; // inisialisasi nanti di initState
  Padding dropDown() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        width: 200,
        child: DropdownButton<DropdownItem>(
          value: selectedOption,
          isExpanded: true,
          items: dropdownOptions.map((DropdownItem item) {
            return DropdownMenuItem<DropdownItem>(
              value: item,
              child: Text(item.label),
            );
          }).toList(),
          onChanged: (DropdownItem? newValue) {
            setState(() {
              selectedOption = newValue!;
              //   _loadData(selectedOption!.value);

              _refreshLoadData(selectedOption!.value);
              //print(selectedOption!.value);
            });
          },
        ),
      ),
    );
  }

  Padding cari() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: TextField(
        onChanged: (value) {
          setState(() {
            filterSeach(value);
          });
        },
        controller: teSeach,
        decoration: const InputDecoration(
            hintText: 'Search...',
            labelText: 'Search',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(25)),
            )),
      ),
    );
  }

  void filterSeach(String query) async {
    var dummySearchList = allCourses;
    if (query.isNotEmpty) {
      var dummyListData = [];
      for (var item in dummySearchList) {
        var course = PenerimaanModel.fromMap(item);
        if (course.keterangan!.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      }
      setState(() {
        items = [];
        items.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        items = [];
        items = allCourses;
      });
    }
  }

  @override
  void dispose() {
    // Membersihkan sumber daya saat widget dihapus
    // myController.dispose();

    _namaController.dispose();
    _nilaiController.dispose();
    teSeach.dispose();
    super.dispose();
  }
}

class DropdownItem {
  final int value;
  final String label;

  DropdownItem({required this.value, required this.label});
}
