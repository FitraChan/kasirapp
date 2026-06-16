import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class Network {
  //if you are using android studio emulator, change localhost to 10.0.2.2
  var token;

  // var apiUrl = 'http://192.168.0.42/kasir_api_new/api/';
  var apiUrl = 'https://kasir.mbcconsulting.id/api/';

  var apiUrlLokal = 'http://192.168.34.6/kasir_api/public/api/';

  // var apiUrl = 'http://adminkasir2.ansdigitalcorp.com/public/api/';

  // _getToken() async {
  //   SharedPreferences localStorage = await SharedPreferences.getInstance();
  //   token = jsonDecode(localStorage.getString('token') ?? '')['token'];

  //   if (token == null || token.isEmpty) {
  //     await localStorage.remove('token');
  //     await localStorage.remove('user');
  //     await localStorage.remove('shift_id');

  //     await localStorage.remove('kategori');
  //     await localStorage.remove('pencarian');
  //     await localStorage.remove('stok');
  //     await localStorage.remove('kategoriDalamContainer');
  //     return;
  //   }
  // }
  _getToken() async {
    try {
      SharedPreferences localStorage = await SharedPreferences.getInstance();

      String? data = localStorage.getString('token');

      // cek null atau kosong
      if (data == null || data.isEmpty) {
        await localStorage.remove('token');
        await localStorage.remove('user');
        await localStorage.remove('shift_id');

        await localStorage.remove('kategori');
        await localStorage.remove('pencarian');
        await localStorage.remove('stok');
        await localStorage.remove('kategoriDalamContainer');
        // await _logout(localStorage);
        return;
      }

      var decoded = jsonDecode(data);

      token = decoded['token']?.toString() ?? '';

      // cek token kosong
      if (token.isEmpty) {
        // await _logout(localStorage);
        return;
      }
    } on FormatException catch (e) {
      // jika json rusak
      print("FormatException: $e");

      SharedPreferences localStorage = await SharedPreferences.getInstance();

      //  await _logout(localStorage);
    } catch (e) {
      print("Error get token: $e");
    }
  }

  authData(data, addr) async {
    var fullUrl = apiUrl + addr;
    return await http.post(Uri.parse(fullUrl),
        body: jsonEncode(data), headers: _setHeaders());
  }

  getData(addr) async {
    var fullUrl = apiUrl + addr;
    await _getToken();
    return await http.post(Uri.parse(fullUrl), headers: _setHeaders());
  }

  getData_post(data, addr) async {
    var fullUrl = apiUrl + addr;
    await _getToken();

    var response = await http.post(Uri.parse(fullUrl),
        body: jsonEncode(data), headers: _setHeaders());
    await _checkUnauthorized(response);

    return response;
  }

  getData_post_loka(data, addr) async {
    var fullUrl = apiUrlLokal + addr;
    await _getToken();

    var response = await http.post(Uri.parse(fullUrl),
        body: jsonEncode(data), headers: _setHeadersLokal());
    //await _checkUnauthorized(response);

    return response;
  }

  Future<Response> getData_postDio(dynamic data, String addr) async {
    var fullUrl = apiUrl + addr;

    await _getToken();

    Dio dio = Dio();

    Options options = Options(
      headers: _setHeaders(),
    );

    Response response;

    // 🔥 CEK apakah ada file
    if (data is FormData) {
      response = await dio.post(
        fullUrl,
        data: data,
        options: options,
      );
    } else {
      response = await dio.post(
        fullUrl,
        data: data,
        options: options,
      );
    }

    await _checkUnauthorizedDio(response);

    return response;
  }

  Future<void> _checkUnauthorizedDio(Response response) async {
    if (response.statusCode == 401) {
      // logout / refresh token
      print("Unauthorized");
    }
  }

  getData_get(addr) async {
    var fullUrl = apiUrl + addr;
    await _getToken();

    var response = await http.get(Uri.parse(fullUrl), headers: _setHeaders());

    await _checkUnauthorized(response);
    return response;
  }

  getData_get_loka(addr) async {
    var fullUrl = apiUrlLokal + addr;
    // await _getToken();

    var response =
        await http.get(Uri.parse(fullUrl), headers: _setHeadersLokal());

    await _checkUnauthorized(response);
    return response;
  }

  _setHeaders() => {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  _setHeadersLokal() => {
        'Content-type': 'application/json',
        'Accept': 'application/json',
      };

  _checkUnauthorized(http.Response response) async {
    if (response.statusCode == 401) {
      //SharedPreferences localStorage = await SharedPreferences.getInstance();
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove('token');
      await prefs.remove('user');
      await prefs.remove('shift_id');

      await prefs.remove('kategori');
      await prefs.remove('pencarian');
      await prefs.remove('stok');
      await prefs.remove('kategoriDalamContainer');
    }
  }
}
