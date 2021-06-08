import 'package:app/screen/Homepage.dart';
import 'package:app/screen/sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Welcome extends StatefulWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  final fb = FirebaseDatabase.instance;

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
  //   await FirebaseAuth.instance.signInWithCredential(credential);
  //   User? user = FirebaseAuth.instance.currentUser;
  //   // final ref=fb.reference();
  //   // ref
  //   // ..child('User')
  //   //   ..push()
  //   //   ..child('Useranme')
  //   //   ..set('$user');
  //   print("Photo url  :");
  //   print(user!.photoURL);
  //   print('here :  $user');

  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => Homepage(),
  //     ),
  //   );
  // }
  Future signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    print('Login');
    // Once signed in, return the UserCredential
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Homepage(),
      ),
    );
    await FirebaseAuth.instance.signInWithCredential(credential);
    User? user = FirebaseAuth.instance.currentUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', user!.email!);
    print('here :  $user');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.only(left: 5, right: 150),
              child: Text(
                'Welcome to',
                style: TextStyle(
                  fontSize: 32,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5, right: 150),
              child: Text(
                'Travel Treat',
                style: TextStyle(
                  fontSize: 32,
                ),
              ),
            ),
            SizedBox(height: 30),
            Image.asset(
              'asset/images/cab.jpg',
              width: 360,
            ),
            SizedBox(height: 28),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignIn(),
                  ),
                );
              },
              child: Text(
                ' Sign In ',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(
              height: 25,
            ),
            Center(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  primary: Colors.black,
                  shape: StadiumBorder(),
                ),
                label: Text(
                  'Sign In with Google',
                  style: TextStyle(fontFamily: 'Ubuntu', fontSize: 17),
                ),
                icon: FaIcon(
                  FontAwesomeIcons.google,
                  color: Colors.black,
                ),
                onPressed: () async {
                  signInWithGoogle();
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
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
    );
  }
}
