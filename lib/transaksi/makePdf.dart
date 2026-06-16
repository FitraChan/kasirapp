import 'package:kasirapp/helpers/dbkasir.dart';

import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:kasirapp/model/transaksiDetailPembelianModel.dart';
import 'package:pdf/pdf.dart';

import 'package:pdf/widgets.dart';

Future<Uint8List> makePdf(detaiTransaksi, tot) async {
  final pdf = Document();
  pdf.addPage(Page(
      pageFormat: const PdfPageFormat(
          58 * PdfPageFormat.mm, 40 * PdfPageFormat.mm,
          marginAll: 0.5 * PdfPageFormat.mm),
      build: (context) {
        Container fillDisc;
        KasirHelper? helper;

        //var DetailTrans = [];
        final oCcy = NumberFormat.decimalPattern();
        helper = KasirHelper();

        TransaksiDetailPembelianModel? courses;
        return Column(children: [
          Container(
              child: ListView.builder(
                  itemCount: detaiTransaksi.length,
                  itemBuilder: (context, index) {
                    // courses = TransaksiDetailPembelianModel.fromMap(
                    // detaiTransaksi[index]);
                    Container nilaiDiskon;

                    if (detaiTransaksi[index]['diskon'] != 0) {
                      fillDisc = Container(
                        padding: const EdgeInsets.only(top: 8, left: 9),
                        child: Text("Diskon",
                            style: const TextStyle(fontSize: 13)),
                      );

                      nilaiDiskon = Container(
                        padding: const EdgeInsets.only(top: 8, left: 9),
                        child: Text("- ${detaiTransaksi[index]['diskon']}",
                            style: const TextStyle(fontSize: 13)),
                      );
                    } else {
                      fillDisc = Container(
                        padding: const EdgeInsets.only(top: 8, left: 9),
                        child: Text(""),
                      );

                      nilaiDiskon = Container(
                        padding: const EdgeInsets.only(top: 8, left: 9),
                        child: Text(""),
                      );
                    }

                    return Container(
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
                                  padding:
                                      const EdgeInsets.only(top: 8, left: 9),
                                  child: Text(
                                      detaiTransaksi[index]['nama_barang']
                                          .toString(),
                                      style: const TextStyle(fontSize: 13)),
                                ),
                                fillDisc,
                              ],
                            ),
                            Spacer(),
                            Container(
                                padding:
                                    const EdgeInsets.only(top: 8, right: 10),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          child: Text(
                                              "${detaiTransaksi[index]['qty']} x ${oCcy.format(int.parse(detaiTransaksi[index]['harga_jual'].toString()))}",
                                              style: const TextStyle(
                                                  fontSize: 13)),
                                        )
                                      ],
                                    ),
                                    nilaiDiskon,
                                  ],
                                )),
                          ],
                        ),
                      ),
                    );
                  })),
          Divider(indent: 10, endIndent: 10),
          Container(
              padding: const EdgeInsets.only(left: 9, right: 10),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total ", style: const TextStyle(fontSize: 13)),
                    Spacer(),
                    Text(tot.toString(), style: const TextStyle(fontSize: 13)),
                  ])

              // Text("Total = " + tot.toString(), style: TextStyle(fontSize: 13)),
              )
        ]);
      }));

  // final printer = BlueThermalPrinter.instance;
  //       final isConnected = await printer.isConnected;
  //       if (!isConnected!) {
  //         await printer.connect();
  //       }
  return pdf.save();
}
