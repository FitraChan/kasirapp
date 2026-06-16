import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:kasirapp/model/currencyFormatter.dart';
import 'package:kasirapp/model/penerimaanModel.dart';
import 'package:kasirapp/network_utils/api.dart';
import 'package:kasirapp/screen/home.dart';
import 'package:kasirapp/sync/syncServicePenerimaan.dart';
import 'package:kasirapp/transaksi/editPenerimaan.dart';
import 'package:kasirapp/transaksi/tambahPenerimaan.dart';

import '../screen/menu1.dart';

//import 'package:firebase_messaging/firebase_messaging.dart';

class Penerimaan extends StatefulWidget {
  const Penerimaan({Key? key, required this.title, required this.tambah})
      : super(key: key);
  final String title;
  final int tambah;

  @override
  _PenerimaanState createState() => _PenerimaanState();
}

class _PenerimaanState extends State<Penerimaan> {
  //  FirebaseMessaging messaging;

  TextEditingController teSeach = TextEditingController();
  final syncServicePenerimaan = SyncServicePenerimaan();

  bool _isLoading = true;
  KasirHelper? helper;
  var items = [];
  var allCourses = [];

  var newData;
  final int itemsPerPage = 10;
  int currentPage = 0;
  var _data = [];
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

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    helper = KasirHelper();
    _initData();

    if (widget.tambah == 0) {
      syncServicePenerimaan.syncPenerimaan().then((_) {
        _refreshPenerimaan();
      });
    }

    _loadInitialData();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMoreData();
      }
    });
  }

  Future<void> _initData() async {
    final count = await helper!.countPenerimaan();

    if (count == 0) {
      await syncServicePenerimaan.syncAll();
      _refreshPenerimaan();
      _loadInitialData();
    }
  }

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nilaiController = TextEditingController();

  Future<void> _loadInitialData() async {
    final totalData = await helper!.allPenerimaan();
    final pageData = await helper!
        .allPenerimaanPage(itemsPerPage, currentPage * itemsPerPage);

    setState(() {
      allCourses = totalData;
      jumlah = totalData.length;
      _data = pageData;
      _isLoading = false;
    });
  }

  Future<void> _loadData() async {
    newData = await helpers.allPenerimaanPage(
        itemsPerPage, currentPage * itemsPerPage);
    setState(() {
      _data.addAll(newData);
    });

    if (jumlah == _data.length) {
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _loadMoreData,
            icon: const Icon(Icons.expand_more),
            label: const Text(
              'Muat Lebih Banyak',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ),
    );
  }

  var current;
  var currentString;

  final currencyFormatter = CurrencyFormatter();
  Widget _buildList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _data.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final course = PenerimaanModel.fromMap(_data[index]);

        DateTime parsedDate =
            DateFormat('dd-MM-yyyy').parse(course.created_at!);

        String tanggal = DateFormat('dd MMM yyyy').format(parsedDate);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditPenerimaan(penerimaanModel: course),
                ),
              );
            },
            onLongPress: () {
              showAlertDialog(context, _data[index]['id']);
            },
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Icon modern
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.green,
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Text content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.keterangan ?? '-',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            tanggal,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Nominal
                    Text(
                      "Rp ${currencyFormatter.format(course.nilai.toString())}",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void sendToMysql(id, keterangan, nilai) async {
    Map data = {
      'id': id.toString(),
      'keterangan': keterangan,
      'nilai': nilai,
    };

    String url;

    url = 'createPenerimaan';

    // final response = await htpp.post(Uri.parse(url), body: data);
    final response = await Network().getData_post(data, url);
    // var c = json.decode(response.body);

    if (response.statusCode == 200) {
      print('sukses');
    } else {
      print(response.body);
      throw Exception('Failed to load album');
    }
  }

  void sendToMysqlUpdate(id, keterangan, nilai) async {
    Map data = {
      'id': id.toString(),
      'keterangan': keterangan,
      'nilai': nilai,
    };

    String url;

    if (id != 0 && keterangan != '') {
      url = 'update_penerimaan';
    } else {
      url = 'delete_penerimaan';
    }
    // final response = await htpp.post(Uri.parse(url), body: data);
    final response = await Network().getData_post(data, url);
    // var c = json.decode(response.body);

    if (response.statusCode == 200) {
      print('sukses');
    } else {
      print(response.body);
      throw Exception('Failed to load album');
    }
  }

  // Update an existing journal
  Future<void> _updateItem(int id) async {
    // PenerimaanModel kat = PenerimaanModel({
    //   'id': id,
    //   'keterangan': _namaController.text,
    //   'nilai': int.parse(_nilaiController.text)
    // });
    //contact.phone = phoneController.text;
    await helper!
        .updatePenerimaan(id, _namaController.text, _nilaiController.text);
    _refreshPenerimaan();

    sendToMysqlUpdate(id, _namaController.text, _nilaiController.text);
  }

  // Delete an item
  void _deleteItem(int id) async {
    await helper!.deletePenerimaan(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a penerimaan!'),
    ));

    setState(() {
      currentPage = 0;
      _data = [];
      _isLoading = true;
    });

    _refreshPenerimaan();
    _loadInitialData();
    Navigator.of(context).pop(false);
    sendToMysqlUpdate(id, '', '');
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
          appBar: AppBar(
            title: const Text(
              'Penerimaan',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
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
          ),
          //drawer: const Menu(),
          backgroundColor: Colors.grey[300],
          body: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                // students(),
                cari(),
                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : _buildList(),
                click ? tombolLoad() : const Center()
              ])),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TambahPenerimaan(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text("Tambah"),
          ),
        ));
  }

  Padding cari() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: teSeach,
        onChanged: filterSeach,
        decoration: InputDecoration(
          hintText: 'Cari penerimaan...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
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

  showAlertDialog(BuildContext context, int id) {
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
        // hapus(id);
        _deleteItem(id);
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

  Container dataPenerimaan() {
    return Container(
        child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              PenerimaanModel? course = PenerimaanModel.fromMap(items[index]);
              return Card(
                color: Colors.orange[200],
                margin: const EdgeInsets.all(15),
                child: ListTile(
                    title: Text('${course.keterangan}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('${course.nilai}'),
                        Text('${course.created_at}'),
                      ],
                    ),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              showAlertDialog(context, items[index]['id']);
                            },
                          ),
                        ],
                      ),
                    )),
              );
            }));
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
