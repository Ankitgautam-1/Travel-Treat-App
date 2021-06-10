import 'package:app/screen/Const.dart';
import 'package:app/screen/Dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

var otp;

// ignore: must_be_immutable
class Otpverify extends StatefulWidget {
  String num = "";
  var verificationId;
  late bool isPhoneAuth;
  User user;
  Otpverify(
      {required this.verificationId,
      required this.num,
      required this.isPhoneAuth,
      required this.user});

  @override
  _OtpverifyState createState() => _OtpverifyState(
      verificationId: verificationId,
      num: num,
      isPhoneAuth: isPhoneAuth,
      user: user);
}

class _OtpverifyState extends State<Otpverify> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  final _otpkey = GlobalKey<FormState>();
  var num;
  var verificationId;
  var isPhoneAuth;
  User user;
  bool isloading = false;
  _OtpverifyState(
      {this.verificationId,
      required this.num,
      required this.isPhoneAuth,
      required this.user});

  void verify() async {
    setState(() {
      isloading = true;
    });

    if (_otpkey.currentState!.validate()) {
      _otpkey.currentState!.save();
      print(otp);
      print('VerificationId is : $verificationId'); //*it's Authcredential
      print('Number is : $num');
      print('This is user details  :  $user');
      if (isPhoneAuth) {
        try {
          final authcredential =
              await _auth.signInWithCredential(verificationId);
          setState(() {
            isloading = false;
          });
          if (authcredential.user != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Dashboard(),
              ),
            );
          }
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('email', user.email!);
        } catch (e) {
          print("Error while Sign in with PhoneCredential :  $e");
        }
      } else {
        try {
          print(' ver :$verificationId');
          PhoneAuthProvider.credential(
              verificationId: verificationId, smsCode: otp);
          print(user.uid);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('email', user.email!);
          isloading = false;
          Navigator.pushReplacement(
            context,
            new MaterialPageRoute(
              builder: (context) => Dashboard(),
            ),
          );
        } catch (e) {
          isloading = false;
          print("Error while Signin with phone ");
        }
      }
    }
  }

  void signInwithphone() async {}

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Const.maincolor,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          toolbarHeight: 40,
        ),
        body: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Form(
                  key: _otpkey,
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        width: 350,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          onSaved: (val) => otp = val,
                          validator: (val) => val!.length == 6
                              ? null
                              : 'Pls Enter valid number',
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'OTP',
                            hintText: 'Enter Your OTP',
                            icon: FaIcon(
                              FontAwesomeIcons.mobile,
                              color: Const.maincolor,
                            ),
                            suffixIcon: GestureDetector(
                              child: Container(
                                decoration: new BoxDecoration(
                                  color: Const.maincolor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                ),
                              ),
                              onTap: verify,
                            ),
                            labelStyle:
                                TextStyle(fontFamily: 'Ubuntu', fontSize: 18),
                            hintStyle:
                                TextStyle(fontFamily: 'Ubuntu', fontSize: 15),
                          ),
                        ),
                      ),
                      isloading
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : Center(
                              child: Text(''),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
