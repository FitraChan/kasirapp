import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
//import 'package:kasirapp/screen/login.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:kasirapp/screen/home.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:device_preview/device_preview.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
//import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kasirapp/sync/autoSync.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  HttpOverrides.global = MyHttpOverrides();

  // runApp(
  //   DevicePreview(
  //       enabled: !kReleaseMode,
  //       builder: (context) => const ProviderScope(
  //           child: MyApp())), // ganti dengan nama root app kamu
  // );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'E-Commerce',
      debugShowCheckedModeBanner: false,
      home: const Home(title: ''),
      localizationsDelegates: const [
        MonthYearPickerLocalizations.delegate,
      ],
      builder: (context, child) {
        return CheckAuth(
          child: EasyLoading.init()(context, child),
        );
      },
    );
  }
}

class CheckAuth extends StatefulWidget {
  final Widget child;

  const CheckAuth({super.key, required this.child});
  @override
  _CheckAuthState createState() => _CheckAuthState();
}

class _CheckAuthState extends State<CheckAuth> {
  bool isAuth = false;
  late StreamSubscription<List<ConnectivityResult>> subscription;
  bool isOffline = false;

  @override
  void initState() {
    super.initState();

    checkConnection();
    listenConnection();
  }

  void checkConnection() async {
    var result = await Connectivity().checkConnectivity();

    setState(() {
      isOffline = result == ConnectivityResult.none;
    });
  }

  void listenConnection() {
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      final offline = results.contains(ConnectivityResult.none);

      setState(() {
        isOffline = offline;
      });

      if (!offline) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Internet tersambung"),
          ),
        );
      }
    });
  }

  Widget buildOfflineUI() {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffFF5F6D), Color(0xffFFC371)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(30),
            margin: const EdgeInsets.symmetric(horizontal: 30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.wifi_off, size: 80, color: Colors.red),
                SizedBox(height: 20),
                Text("Tidak Ada Koneksi Internet"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //
    if (isOffline) {
      return buildOfflineUI(); // ✅ sekarang aman
    }

    return widget.child;
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }
}
