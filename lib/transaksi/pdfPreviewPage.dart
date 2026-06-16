// import 'package:flutter/material.dart';
// //import 'package:makepdfs/models/invoice.dart';
// import 'package:printing/printing.dart';
// import 'package:sync_mysql/transaksi/transPenjualan.dart';

// import 'package:sync_mysql/transaksi/makePdf.dart';

// //import 'pdf/pdfexport.dart';

// class PdfPreviewPage extends StatelessWidget {
//   // final Invoice invoice;
//   const PdfPreviewPage(
//       {Key? key, required this.detailTransaksi, required this.tot})
//       : super(key: key);

//   final detailTransaksi;
//   final tot;

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//         onWillPop: () async {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (context) => const TransPenjualan(
//                       tanggal: "",
//                     )),
//           );
//           return Future.value(true);
//         },
//         child: Scaffold(
//           appBar: AppBar(
//             title: const Text('PDF Preview'),
//           ),
//           body: PdfPreview(
//             build: (context) => makePdf(detailTransaksi, tot),
//           ),
//         ));
//   }
// }
