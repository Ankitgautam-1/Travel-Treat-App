import 'package:app/screen/Dashboard.dart';
import 'package:app/screen/Email_verify.dart';
import 'package:app/screen/otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class Prc extends StatefulWidget {
  List<String> data;
  Prc({required this.data});
  @override
  _PrcState createState() => _PrcState(data: data);
}

class _PrcState extends State<Prc> {
  List<String> data;
  _PrcState({required this.data});
  TextEditingController _1st = TextEditingController();
  TextEditingController _2nd = TextEditingController();
  TextEditingController _3rd = TextEditingController();
  TextEditingController _4th = TextEditingController();
  TextEditingController _5th = TextEditingController();
  TextEditingController _6th = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  String _otp = "";
  String verificationId = "";
  User? user;
  @override
  void initState() {
    sendotp();
    super.initState();
  }

  Future sendotp() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: "+91" + data[2],
      verificationCompleted: (PhoneAuthCredential credential) async {
        auth.signInWithEmailAndPassword(email: data[1], password: data[3]);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Dashboard(), //! Handle it
          ),
        );
      },
      timeout: const Duration(seconds: 100),
      verificationFailed: (FirebaseAuthException e) async {
        if (e.code == 'invalid-phone-number') {
          print('The provided phone number is not valid.');
        }
        print(e);
      },
      codeSent: (verificationId, resendingToken) async {
        print("Otp is send ");
        this.verificationId = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
    print(data[2]);
  }

  // ignore: non_constant_identifier_names
  Future<void> verify(String otp_code) async {
    try {
      print(' ver :$verificationId');
      PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: otp_code);
      print('Signed In');
      auth.createUserWithEmailAndPassword(email: data[1], password: data[3]);
      user = auth.currentUser;
      user!.sendEmailVerification();
      print('send Emaill up');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EmailVerify(data: data),
        ),
      );
    } catch (e) {
      print("Error while Signin with phone ");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: 40,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
              size: 25,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 35,
              ),
              Text(
                'OTP Verification',
                style: TextStyle(
                  fontSize: 35,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'Please don\'t share your OTP',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              Image.asset(
                'asset/images/email_verification_bg.png',
                height: 300,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 85,
                    width: 50,
                    child: TextFormField(
                      controller: _1st,
                      autofocus: true,
                      onChanged: (value) {
                        if (value.length == 1) {
                          FocusScope.of(context).nextFocus();
                        }
                      },
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                      decoration: InputDecoration(
                        counterText: "",
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 2.0, color: Colors.black),
                        ),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(width: 1.4),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 85,
                    width: 50,
                    child: TextFormField(
                      controller: _2nd,
                      autofocus: true,
                      onChanged: (value) {
                        if (value.length == 1) {
                          FocusScope.of(context).nextFocus();
                        }
                        if (value.length != 1) {
                          FocusScope.of(context).previousFocus();
                        }
                      },
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                      decoration: InputDecoration(
                        counterText: "",
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 2.0, color: Colors.black),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(width: 2),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 85,
                    width: 50,
                    child: TextFormField(
                      controller: _3rd,
                      autofocus: true,
                      onChanged: (value) {
                        if (value.length == 1) {
                          FocusScope.of(context).nextFocus();
                        }
                        if (value.length != 1) {
                          FocusScope.of(context).previousFocus();
                        }
                      },
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                      decoration: InputDecoration(
                        counterText: "",
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 2.0, color: Colors.black),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(width: 2),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 85,
                    width: 50,
                    child: TextFormField(
                      controller: _4th,
                      autofocus: true,
                      onChanged: (value) {
                        if (value.length == 1) {
                          FocusScope.of(context).nextFocus();
                        }
                        if (value.length != 1) {
                          FocusScope.of(context).previousFocus();
                        }
                      },
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                      decoration: InputDecoration(
                        counterText: "",
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 2.0, color: Colors.black),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(width: 2),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 85,
                    width: 50,
                    child: TextFormField(
                      controller: _5th,
                      autofocus: true,
                      onChanged: (value) {
                        if (value.length == 1) {
                          FocusScope.of(context).nextFocus();
                        }
                        if (value.length != 1) {
                          FocusScope.of(context).previousFocus();
                        }
                      },
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                      decoration: InputDecoration(
                        counterText: "",
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 2.0, color: Colors.black),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(width: 2),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 85,
                    width: 50,
                    child: TextFormField(
                      controller: _6th,
                      autofocus: true,
                      onChanged: (value) {
                        if (value.length == 1) {
                          FocusScope.of(context).nextFocus();
                        }
                        if (value.length != 1) {
                          FocusScope.of(context).previousFocus();
                        }
                      },
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                      decoration: InputDecoration(
                        counterText: "",
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 2.0, color: Colors.black),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(width: 2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    )),
                onPressed: () async {
                  otp = _1st.text +
                      _2nd.text +
                      _3rd.text +
                      _4th.text +
                      _5th.text +
                      _6th.text;
                  print("Your otp is  $otp");
                  await verify(otp);
                },
                child: Text('Verify OTP'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
