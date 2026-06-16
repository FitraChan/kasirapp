import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kasirapp/helpers/dbkasir.dart';

class CobaDetail extends StatefulWidget {
  final int id;

  CobaDetail({Key? key, required this.id}) : super(key: key);

  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<CobaDetail> {
  var selectedSize = 'XL';
  var namaProduk = '';
  var gambar = '';
  var keterangan = '';
  bool isLoading = true;

  List<Map<String, dynamic>> sizes = [
    {'size': 'XL', 'stok': 5},
    {'size': 'L', 'stok': 0},
    {'size': 'M', 'stok': 3},
    {'size': 'S', 'stok': 2},
  ];
  KasirHelper? helper;
  var allProduk = [];
  var items = [];

  @override
  void initState() {
    super.initState();

    helper = KasirHelper();
    try {
      helper!.cariProdukById(widget.id).then((product) {
        setState(() {
          //print("Produk ditemukan: $product");
          allProduk = product;
          items = allProduk;
          namaProduk = allProduk[0]['nama_barang'];
          gambar = allProduk[0]['gambar'];
          keterangan = allProduk[0]['keterangan'] ?? '';
          isLoading = false; // Tambahkan ini
        });
      });
    } catch (e) {
      print("Error saat setState: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _iconBox(Icons.arrow_back_ios),
                        const Text("Detail",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        _iconBox(Icons.favorite_border),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Title & Rating
                    const Text("Men Shoe's",
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 5),
                    Text(namaProduk,
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Row(
                      children: const [
                        Icon(Icons.star, color: Colors.orange, size: 16),
                        SizedBox(width: 4),
                        Text("4.9",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(width: 4),
                        Text("(130 Reviews)",
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Product Image and thumbnails
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            margin:
                                const EdgeInsets.only(top: 15.0, right: 10.0),
                            width: 50,
                            height: 120,
                            child: gambar != ""
                                ? UtilityProduk.imageFromBase64String(gambar)
                                : Image.asset('images/no_image.png'),
                            // margin:
                            //     const EdgeInsets.only(top: 15.0, right: 10.0),
                            // decoration: const BoxDecoration(
                            //   image: DecorationImage(
                            //     image: AssetImage('images/no_image.png'),
                            //     fit: BoxFit.fill,
                            //   ),
                            //   //shape: BoxShape.circle,
                            // )
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Color Picker

                    const SizedBox(height: 20),

                    // Description
                    const Text("Description",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(
                      keterangan,
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),

                    // Size Picker

                    const Spacer(),

                    // Add to cart Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child:
                            const Text("Back", style: TextStyle(fontSize: 16)),
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }

  Widget _iconBox(IconData icon) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 20),
    );
  }

  Widget _thumbnailBox(IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Icon(icon, size: 20),
    );
  }
}

class UtilityProduk {
  static Image imageFromBase64String(String base64String) {
    return Image.memory(
      base64Decode(base64String),
      fit: BoxFit.fill, // pastikan ditambahkan
    );
  }
}
