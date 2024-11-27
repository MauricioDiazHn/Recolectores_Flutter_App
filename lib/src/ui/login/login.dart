
import 'package:flutter/material.dart';
import 'package:recolectores_app_flutter/src/sample_feature/sample_item_list_view.dart';
import 'package:recolectores_app_flutter/src/ui/create__account/create_account.dart';
import 'package:recolectores_app_flutter/src/ui/rounded_btn/rounded_btn.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool showSpinner = false;
  // final _auth = FirebaseAuth.instance;
  String email = "";
  String password = "";

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Color(0xff251F34),
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
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 8),
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
                  margin: EdgeInsets.symmetric(vertical: 10),
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
                        cursorColor: Colors.white,
                        obscureText: false,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          fillColor: Color(0xfff3B324E),
                          filled: true,
                          prefixIcon: Image.asset('images/icon_email.png'),
                          focusedBorder: OutlineInputBorder(
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
                    btnText: 'LOGIN',
                    color: Color(0xff14DAE2),
                    onPressed: () async {
                      // Add login code
                      setState(() {
                        showSpinner = true;
                      });
                      try {
                        await Future.delayed(Duration(seconds: 2));  // Simulando un login exitoso por 2 segundos
          
                        // Si el login es exitoso, navega a la pantalla de SampleItemListView
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const SampleItemListView()),
                        );
                        
                        setState(() {
                          showSpinner = false;
                        });
                      } catch (e) {
                        print(e);
                      }
                    },
                  ),
                ),
              ),
              Center(
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(color: Color(0xff14DAE2)),
                ),
              ),
              SizedBox(
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
                    child: Text('Sign up',
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
