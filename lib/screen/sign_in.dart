import 'package:app/screen/Homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _formkey = GlobalKey<FormState>();

  String _email = "", _pass = "";
  bool _obscuretext = false;
  // void registerwithemail() async {
  //   if (_formkey.currentState!.validate()) {
  //     _formkey.currentState!.save();
  //     try {
  //       UserCredential userCredential = await FirebaseAuth.instance
  //           .createUserWithEmailAndPassword(email: _email, password: _pass);
  //     } on FirebaseAuthException catch (e) {
  //       if (e.code == 'weak-password') {
  //         print('The password provided is too weak.');
  //       } else if (e.code == 'email-already-in-use') {
  //         print('The account already exists for that email.');
  //       }
  //     } catch (e) {
  //       print(e);
  //     }
  //   } else {
  //     print("Not valid");
  //   }
  // }

  // Future<bool> loginwithemail() async {
  //   if (_formkey.currentState!.validate()) {
  //     _formkey.currentState!.save();
  //     try {
  //       UserCredential userCredential = await FirebaseAuth.instance
  //           .signInWithEmailAndPassword(email: _email, password: _pass);
  //       print("Done");
  //       return true;
  //     } on FirebaseAuthException catch (e) {
  //       if (e.code == 'user-not-found') {
  //         print('No user found for that email.');
  //       } else if (e.code == 'wrong-password') {
  //         print('Wrong password provided for that user.');
  //       }
  //       return false;
  //     } catch (e) {
  //       print(e);
  //       return false;
  //     }
  //   } else {
  //     print("Not valid");
  //     return false;
  //   }
  // }

  void signin() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
    } catch (e) {
      print(e);
    }
  }

  // Future signInWithGoogle() async {
  //   // Trigger the authentication flow
  //   final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  //   // Obtain the auth details from the request
  //   final GoogleSignInAuthentication googleAuth =
  //       await googleUser!.authentication;

  //   // Create a new credential
  //   final credential = GoogleAuthProvider.credential(
  //     accessToken: googleAuth.accessToken,
  //     idToken: googleAuth.idToken,
  //   );
  //   print('Login');
  //   // Once signed in, return the UserCredential
  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => Homepage(),
  //     ),
  //   );
  //   await FirebaseAuth.instance.signInWithCredential(credential);
  //   User? user = FirebaseAuth.instance.currentUser;
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.setString('email', user!.email!);
  //   print('here :  $user');
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(right: 600),
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back_ios),
                ),
              ),
              Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 32,
                ),
              ),
              SizedBox(height: 30),
              Image.asset(
                'asset/images/Welcome.jpg',
                width: 360,
              ),
              SizedBox(
                height: 28,
              ),
              Form(
                key: _formkey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      width: 350,
                      child: TextFormField(
                        onSaved: (val) => _email != val,
                        validator: (val) => val!.contains('@gmail.com')
                            ? null
                            : 'Invalid Gmail Account',
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'E-mail',
                          hintText: 'Enter a email',
                          prefixIcon: Icon(
                            Icons.mail_outline,
                          ),
                          labelStyle:
                              TextStyle(fontFamily: 'Ubuntu', fontSize: 18),
                          hintStyle:
                              TextStyle(fontFamily: 'Ubuntu', fontSize: 15),
                        ),
                      ),
                    ),
                    //input password
                    Container(
                      margin: EdgeInsets.only(top: 20, bottom: 20),
                      width: 350,
                      child: TextFormField(
                        onSaved: (val) => _pass != val,
                        validator: (val) => val!.length < 6
                            ? 'Password must cantains at least 6 charachter'
                            : null,
                        obscureText: _obscuretext,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          hoverColor: Colors.blueGrey,
                          prefixIcon: Icon(
                            Icons.lock,
                          ),
                          labelStyle:
                              TextStyle(fontFamily: 'Ubuntu', fontSize: 18),
                          hintStyle:
                              TextStyle(fontFamily: 'Ubuntu', fontSize: 15),
                          suffixIcon: GestureDetector(
                            child: Icon(_obscuretext
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onTap: () {
                              setState(() {
                                _obscuretext = !_obscuretext;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 80),
                  primary: Colors.black87,
                  onPrimary: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                onPressed: () {
                  try {
                    // loginwithemail();
                    print('Done');
                  } catch (e) {}
                },
                child: Text(
                  ' Sign In ',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              // ElevatedButton(
              //   style: ElevatedButton.styleFrom(
              //     padding: EdgeInsets.symmetric(vertical: 10, horizontal: 80),
              //     primary: Colors.black87,
              //     onPrimary: Colors.white,
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(25.0),
              //     ),
              //   ),
              //   onPressed: () {
              //     try {
              //       // loginwithemail();
              //       signin();
              //       print('Done');
              //     } catch (e) {}
              //   },
              //   child: Text(
              //     'Sign',
              //     style: TextStyle(
              //       fontSize: 16,
              //     ),
              //   ),
              // ),
              // Center(
              //   child: OutlinedButton.icon(
              //     style: OutlinedButton.styleFrom(
              //       primary: Colors.black,
              //       shape: StadiumBorder(),
              //     ),
              //     label: Text(
              //       'Sign In with Google',
              //       style: TextStyle(fontFamily: 'Ubuntu', fontSize: 17),
              //     ),
              //     icon: FaIcon(
              //       FontAwesomeIcons.google,
              //       color: Colors.black,
              //     ),
              //     onPressed: signInWithGoogle,
              //   ),
              // ),
              // SizedBox(
              //   height: 20,
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don\'t have an Account ?',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      ' Sign Up',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
