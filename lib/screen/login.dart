import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:kasirapp/screen/home.dart';
import 'package:kasirapp/screen/registrasi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kasirapp/network_utils/api.dart';
import '../theme.dart';
import '../widgets/custom_checkbox.dart';
import 'package:kasirapp/helpers/dbkasir.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isLoading = false;
  KasirHelper? helper;
  KasirHelper helpers = KasirHelper();

  final _formKey = GlobalKey<FormState>();
  // ignore: prefer_typing_uninitialized_variables
  var email;
  var password;
  bool passwordVisible = false;
  void togglePassword() {
    setState(() {
      passwordVisible = !passwordVisible;
    });
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 40.0, 24.0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'KASIR',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      // margin: const EdgeInsets.only(top: 25),
                      width: 130,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 48,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: textWhiteGrey,
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Email',
                            hintStyle: heading6.copyWith(color: textGrey),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (emailValue) {
                            if (emailValue!.isEmpty) {
                              return 'Please enter some text';
                            }
                            email = emailValue;
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 32,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: textWhiteGrey,
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        child: TextFormField(
                          obscureText: !passwordVisible,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: heading6.copyWith(color: textGrey),
                            suffixIcon: IconButton(
                              color: textGrey,
                              splashRadius: 1,
                              icon: Icon(passwordVisible
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined),
                              onPressed: togglePassword,
                            ),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (passwordValue) {
                            if (passwordValue!.isEmpty) {
                              return 'Please enter some text';
                            }
                            password = passwordValue;
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const CustomCheckbox(),
                    const SizedBox(
                      width: 12,
                    ),
                    Text('Remember me', style: regular16pt),
                  ],
                ),
                const SizedBox(
                  height: 32,
                ),
                Container(
                    child: ConstrainedBox(
                  constraints: const BoxConstraints.tightFor(
                      width: double.infinity, height: 50),
                  child: FloatingActionButton.extended(
                    label: Text(
                      _isLoading ? 'Proccessing...' : 'Login',
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    //minWidth: 80,
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    heroTag: "btnLogin",
                    icon: const Icon(Icons.login_rounded),

                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _login();
                      }
                    },
                  ),
                )),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Belum punya akun? "),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Registrasi(title: ''),
                          ),
                        );
                      },
                      child: const Text(
                        "Daftar",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('AlertDialog Title'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Password Or Email are wrong'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _login() async {
    setState(() {
      _isLoading = true;
    });

    helper = KasirHelper();

    try {
      var data = {'email': email, 'password': password};
      //   print(password);

      //   const String _url = 'https://absensi.mbcconsulting.id/api/login_sanctum';

      const String url = 'login_sanctum';

      var res = await Network().authData(data, url);
      var body = json.decode(res.body);

      print(body);

      //prbody['message']);

      if (body['message'] == '404') {
        setState(() {
          _isLoading = false;
        });

        _showMyDialog();

        return;
      }

      if (body['success'] == true) {
        SharedPreferences localStorage = await SharedPreferences.getInstance();
        localStorage.setString('token', json.encode(body['token']));
        localStorage.setString('user', json.encode(body['user']));
        localStorage.setString('kode_toko', body['kode_toko']);
        localStorage.setString('kategori', body['kategori']);
        localStorage.setString('pencarian', body['pencarian']);
        localStorage.setString('stok', body['stok']);
        localStorage.setString(
            'kategoriDalamContainer', body['kategoriDalamContainer']);

        localStorage.setString('ip', json.encode(body['ip_address']));

        if (helper != null) {
          var user = jsonDecode(localStorage.getString('user') ?? '');

          var idUser = user['id'];
          await helper!.insertShift(idUser);

          helper!.getLastShiftId().then((product) {
            localStorage.setString('shift_id', product.toString());
          });
        }

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const Home(
                    title: '',
                  )),
        );
      } else {
        return EasyLoading.show(status: body['message']);
      }
    } on Exception catch (exception) {
      // only executed if error is of type Exception

      print('exception ${exception.toString()}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(exception.toString())),
      );
    } catch (error) {
      print('exception ${error.toString()}');
      // EasyLoading.show(status: error.toString());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
      // executed for errors of all types other than Exception
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
