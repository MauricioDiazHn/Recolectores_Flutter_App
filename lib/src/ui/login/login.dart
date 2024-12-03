import 'package:flutter/material.dart';
import 'package:recolectores_app_flutter/src/sample_feature/sample_item_list_view.dart';
import 'package:recolectores_app_flutter/src/ui/create__account/create_account.dart';
import 'package:recolectores_app_flutter/src/ui/rounded_btn/rounded_btn.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class UserSession {
  static String? token;
  static int? userId;

  static void saveSession(String newToken, int newUserId) {
    token = newToken;
    userId = newUserId;
  }

  static void clearSession() {
    token = null;
    userId = null;
  }
}

class _LoginState extends State<Login> {
  bool showSpinner = false;
  // final _auth = FirebaseAuth.instance;
  String email = "";
  String password = "";

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> login() async {
    setState(() {
      showSpinner = true;
    });

    final url = Uri.parse(
        'https://d065-200-107-126-225.ngrok-free.app/motorista/login');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({
      'Username': email,
      'Password': password,
    });

    try {
      HttpOverrides.global = MyHttpOverrides();
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String token = data['token'];
        UserSession.saveSession(token, 2);
        // final prefs = await SharedPreferences.getInstance();
        // await prefs.setString('token', token);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SampleItemListView()),
        );
      } else {
        showError('Error al autenticar: Credenciales Invalidas');
      }
    } catch (e) {
      showError('Error: $e');
    }

    setState(() {
      showSpinner = false;
    });
  }

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('http://localhost:5109/motorista/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color(0xff251F34),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 60.0, bottom: 10.0),
                child: Center(
                  child: SizedBox(
                      width: 200,
                      height: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(
                              255, 143, 222, 224), // Color de fondo
                          borderRadius:
                              BorderRadius.circular(20), // Radio de redondeo
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                              20), // Asegura que la imagen también tenga bordes redondeados
                          child: Image.asset(
                            'images/logo.png', // Ruta de la imagen
                            // fit: BoxFit.cover, // Controla cómo la imagen se ajusta dentro del contenedor
                          ),
                        ),
                      )),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 15, 20, 18),
                child: Text(
                  '       App Recolectores',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'times_new_roman_bold_italic',
                      fontSize: 30),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 15, 20, 8),
                child: Text(
                  'Login',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Please sign in to continue.',
                  style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                      fontSize: 13),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'E-mail',
                        style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 13,
                            color: Colors.white),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextField(
                        style: (const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w400)),
                        keyboardType: TextInputType.emailAddress,
                        cursorColor: Colors.white,
                        obscureText: false,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          fillColor: const Color.fromARGB(255, 67, 57, 88),
                          filled: true,
                          prefixIcon: Image.asset('images/icon_email.png'),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xff14DAE2), width: 2.0),
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0)),
                          ),
                        ),
                        onChanged: (value) {
                          email = value;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Password',
                      style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 13,
                          color: Colors.white),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      style: (const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w400)),
                      obscureText: true,
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        fillColor: const Color.fromARGB(253, 59, 50, 78),
                        filled: true,
                        prefixIcon: Image.asset('images/icon_lock.png'),
                        focusedBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xff14DAE2), width: 2.0),
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        ),
                      ),
                      onChanged: (value) {
                        password = value;
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: RoundedButton(
                    btnText: 'LOGIN',
                    color: const Color.fromARGB(255, 20, 219, 226),
                    onPressed: () async {
                      await login();
                      // setState(() {
                      //   showSpinner = true;
                      // });
                      // try {
                      //   // Llamada al backend
                      //   final response = await loginUser(email, password);

                      //   // Si el login es exitoso, guarda el token
                      //   if (response['token'] != null) {
                      //     String token = response['token'];

                      //     // Navega a la siguiente pantalla
                      //     Navigator.pushReplacement(
                      //       context,
                      //       MaterialPageRoute(builder: (context) => const SampleItemListView()),
                      //     );
                      //   } else {
                      //     showError('Login failed');
                      //   }
                      // } catch (e) {
                      //   showError('An error occurred');
                      // } finally {
                      //   setState(() {
                      //     showSpinner = false;
                      //   });
                      // }
                    },
                  ),
                ),
              ),
              const Center(
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(color: Color(0xff14DAE2)),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Dont have an account?',
                    style: TextStyle(
                        color: Colors.grey[600], fontWeight: FontWeight.w400),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CreateAccount()));
                    },
                    child: const Text('Sign up',
                        style: TextStyle(
                          color: Color(0xff14DAE2),
                        )),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
