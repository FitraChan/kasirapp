import 'package:flutter/material.dart';
import 'package:kasirapp/model/currencyFormatter.dart';

import 'package:kasirapp/helpers/dbkasir.dart';
import 'package:kasirapp/model/pengeluaranModel.dart';
import 'package:kasirapp/network_utils/api.dart';
import 'package:kasirapp/screen/home.dart';
import 'package:kasirapp/sync/syncServicePengeluaran.dart';
import 'package:kasirapp/transaksi/editPengeluaran.dart';
import 'package:kasirapp/transaksi/tambahPengeluaran.dart';
import '../screen/menu1.dart';

//import 'package:firebase_messaging/firebase_messaging.dart';

class Pengeluaran extends StatefulWidget {
  const Pengeluaran({Key? key, required this.title, required this.tambah})
      : super(key: key);
  final String title;
  final int tambah;

  @override
  _PengeluaranState createState() => _PengeluaranState();
}

class _PengeluaranState extends State<Pengeluaran> {
  //  FirebaseMessaging messaging;

  TextEditingController teSeach = TextEditingController();
  final syncServicePengeluaran = SyncServicePengeluaran();

  bool _isLoading = true;
  KasirHelper? helper;
  var items = [];
  var allCourses = [];

  void _refreshPengeluaran() {
    if (helper != null) {
      helper!.allPengeluaran().then((courses) {
        setState(() {
          allCourses = courses;
          _data = allCourses;
          _isLoading = false;
        });
      });
    }
  }

  Future<void> _initData() async {
    final count = await helper!.countPengeluaran();
    if (count == 0) {
      await syncServicePengeluaran.syncAll();
      _refreshPengeluaran();
    }
  }

  @override
  void initState() {
    super.initState();
    helper = KasirHelper();
    _initData();

    if (widget.tambah == 0) {
      syncServicePengeluaran.syncPengeluaran();
      _refreshPengeluaran();
    }

    _loadInitialData();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMoreData();
      }
    });
  }

  Future<void> _loadInitialData() async {
    final totalData = await helper!.allPengeluaran();
    final pageData = await helper!
        .allPengeluaranPage(itemsPerPage, currentPage * itemsPerPage);

    setState(() {
      allCourses = totalData;
      jumlah = totalData.length;
      _data = pageData;
      _isLoading = false;
    });
  }

  final ScrollController _scrollController = ScrollController();

  KasirHelper helpers = KasirHelper();
  var newData;
  final int itemsPerPage = 10;
  int currentPage = 0;
  var _data = [];
  int jumlah = 0;
  bool click = true;

  Future<void> _loadData() async {
    newData = await helpers.allPengeluaranPage(
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
      child: ElevatedButton(
        onPressed: _loadMoreData,
        child: const Text('Load More'),
      ),
    );
  }

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nilaiController = TextEditingController();
  // final TextEditingController _createdAtController = TextEditingController();
  final currencyFormatter = CurrencyFormatter();
  Widget _buildList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _data.length,
      itemBuilder: (context, index) {
        final course = PengeluaranModel.fromMap(_data[index]);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(
                course.keterangan ?? '-',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(course.created_at ?? '-'),
              trailing: Text(
                "IDR ${currencyFormatter.format(course.nilai.toString())}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditPengeluaran(pengeluaranModel: course),
                  ),
                );
              },
              onLongPress: () {
                showAlertDialog(context, _data[index]['id']);
              },
            ),
          ),
        );
      },
    );
  }

  var current;
  var currentString;

  void sendToMysqlDelete(id) async {
    Map data = {
      'id': id.toString(),
    };

    String url;

    url = 'delete_pengeluaran';

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

  // Delete an item
  void _deleteItem(int id) async {
    await helper!.deletePengeluaran(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a pengeluaran!'),
    ));

    _refreshPengeluaran();
    Navigator.of(context).pop(false);
    sendToMysqlDelete(id);
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
              'Pengeluaran',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: Colors.red.shade700,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    currentPage = 0;
                    _data = [];
                  });
                  _refreshPengeluaran();
                  _loadInitialData();
                },
              ),
            ],
          ),
          backgroundColor: Colors.grey[300],
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    cari(),
                    Expanded(
                      child: _buildList(),
                    ),
                  ],
                ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.red.shade700,
            child: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TambahPengeluaran(),
                ),
              );
            },
          ),
        ));
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
        var course = PengeluaranModel.fromMap(item);
        if (course.keterangan!.toLowerCase().contains(query.toLowerCase())) {
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
        _data = allCourses;
      });
    }
  }

  void showAlertDialog(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text("Hapus Pengeluaran"),
        content: const Text("Yakin ingin menghapus data ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => _deleteItem(id),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Membersihkan sumber daya saat widget dihapus
    // myController.dispose();

    teSeach.dispose();
    super.dispose();
  }
}
