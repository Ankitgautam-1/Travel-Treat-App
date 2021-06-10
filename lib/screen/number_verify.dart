import 'package:app/screen/Const.dart';
import 'package:app/screen/otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

var ph;

// ignore: must_be_immutable
class Numverify extends StatefulWidget {
  User user;
  Numverify({required this.user});
  @override
  _NumverifyState createState() => _NumverifyState(user: user);
}

class _NumverifyState extends State<Numverify> {
  User user;
  _NumverifyState({required this.user});
  bool isloading = false;
  final GlobalKey<ScaffoldState> _scaffodkey = GlobalKey();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formkey = GlobalKey<FormState>();

  void phoneverify() async {
    setState(() {
      isloading = true;
    });
    if (_formkey.currentState!.validate()) {
      _formkey.currentState!.save();
      print(ph);
      await _auth.verifyPhoneNumber(
        phoneNumber: ph,
        verificationCompleted: (phoneAuthCredential) async {
          print(
              'Verofication Complete------------------------------------------------------');
          setState(() {
            isloading = false;
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Otpverify(
                verificationId: AuthCredential,
                num: ph,
                isPhoneAuth: true,
                user: user,
              ),
            ),
          );
        },
        verificationFailed: (phoneVerificationFailed) async {
          setState(() {
            isloading = false;
          });
          // ignore: deprecated_member_use
          _scaffodkey.currentState!.showSnackBar(
            SnackBar(
              content: Text('Something went wrong ,$phoneVerificationFailed'),
            ),
          );
        },
        codeSent: (verificationId, resendingToken) async {
          print(
              'CodeSent--------------------------------========================================-=-========');
          setState(() {
            isloading = false;
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Otpverify(
                verificationId: verificationId,
                num: ph,
                isPhoneAuth: false,
                user: user,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (verificationId) async {},
      );
    } else {
      print('Error while phone verification');
    }
  }

  Future<bool> _back() async {
    await GoogleSignIn().signOut();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _back,
      child: SafeArea(
        child: Scaffold(
          key: _scaffodkey,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Const.maincolor,
              ),
              onPressed: () async {
                Navigator.pop(context);
                await GoogleSignIn().signOut();
              },
            ),
            elevation: 0,
            backgroundColor: Colors.white,
            toolbarHeight: 40,
          ),
          body: SingleChildScrollView(
            child: isloading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Container(
                    color: Colors.white,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Form(
                          key: _formkey,
                          child: Container(
                            margin: EdgeInsets.only(top: 20),
                            width: 350,
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              onSaved: (val) => ph = '+91' + val!,
                              validator: (val) => val!.length == 10
                                  ? null
                                  : 'Pls Enter valid number ',
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Phone Number',
                                hintText: 'Enter Your 10 digit number',
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
                                  onTap: phoneverify,
                                ),
                                labelStyle: TextStyle(
                                    fontFamily: 'Ubuntu', fontSize: 18),
                                hintStyle: TextStyle(
                                    fontFamily: 'Ubuntu', fontSize: 15),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
