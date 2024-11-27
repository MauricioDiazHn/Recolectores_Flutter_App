import 'package:flutter/material.dart';
import 'package:recolectores_app_flutter/src/ui/login/login.dart';
import 'package:recolectores_app_flutter/src/ui/rounded_btn/rounded_btn.dart';
import 'package:recolectores_app_flutter/src/ui/success/success.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  bool showSpinner = false;
  String email = "";
  String password = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        leading: _goBackButton(context),
        backgroundColor: const Color(0xff251F34),
      ),
      backgroundColor: const Color(0xff251F34),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 0.0, bottom: 10.0),
              child: Center(
                  child: SizedBox(
                      width: 200,
                      height: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 143, 222, 224),// Color de fondo
                          borderRadius: BorderRadius.circular(20), // Radio de redondeo
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20), // Asegura que la imagen también tenga bordes redondeados
                          child: Image.asset(
                            'images/logo.png', // Ruta de la imagen
                            // fit: BoxFit.cover, // Controla cómo la imagen se ajusta dentro del contenedor
                          ),
                        ),
                      )
                  ),
                ),
            ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 18),
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
              padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                'Create Account',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 25),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Please fill the input below.',
                style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                    fontSize: 14),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'E-mail',
                    style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 13,
                        color: Colors.white),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    style: (TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w400)),
                    keyboardType: TextInputType.emailAddress,
                    obscureText: false,
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      fillColor: Color(0xfff3B324E),
                      filled: true,
                      prefixIcon: Image.asset('images/icon_email.png'),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xff14DAE2), width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      ),
                    ),
                    onChanged: (value) {
                      email = value;
                    },
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Password',
                    style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 13,
                        color: Colors.white),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    style: (TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w400)),
                    obscureText: true,
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      fillColor: Color(0xfff3B324E),
                      filled: true,
                      prefixIcon: Image.asset('images/icon_lock.png'),
                      focusedBorder: OutlineInputBorder(
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
                  btnText: 'SIGN UP',
                  color: Color(0xff14DAE2),
                  onPressed: () async {
                    setState(() {
                      showSpinner = true;
                    });
                    try {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SuccessScreen()));

                      setState(() {
                        showSpinner = false;
                      });
                    } catch (e) {
                      print(e);
                    }
                    // Add login code
                  },
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account?',
                  style: TextStyle(
                      color: Colors.grey[600], fontWeight: FontWeight.w400),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Login()));
                  },
                  child: Text('Sign in',
                      style: TextStyle(
                        color: Color(0xff14DAE2),
                      )),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

Widget _goBackButton(BuildContext context) {
  return IconButton(
      icon: Icon(Icons.arrow_back, color: Colors.grey[350]),
      onPressed: () {
        Navigator.of(context).pop(true);
      });
}
