import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:images_picker/images_picker.dart';
import 'package:get/get.dart';
import 'package:app/Data/image.dart';
import 'package:app/views/Phone_verify.dart';
import 'package:app/views/Signin.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

class SignUp extends StatefulWidget {
  final FirebaseApp app;
  SignUp({required this.app});
  @override
  _SignUpState createState() => _SignUpState(app: app);
}

class _SignUpState extends State<SignUp> {
  FirebaseApp app;
  _SignUpState({required this.app});
  TextEditingController _username = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _ph = TextEditingController();
  TextEditingController _pass = TextEditingController();
  User? user;
  late List<String> _data;
  final _formkey = GlobalKey<FormState>();
  var _image;
  bool image = false;
  bool isobscure = true;

  final Permission _permissionforcamera = Permission.mediaLibrary;

  void _create() async {
    FocusScope.of(context)
        .unfocus(); //to hide the keyboard by unfocusing on textformfield
    if (_formkey.currentState!.validate()) {
      if (image) {
        Provider.of<ImageData>(context, listen: false).updateimage(_image);
        print("Heree---------------------------------------------------");
        print(_image.toString());

        print("DONE================================================");
        _data = [
          _username.text,
          _email.text,
          _ph.text,
          _pass.text,
          _image.toString(),
        ];
        Get.to(
          Prc(data: _data, isgoogle: false, app: app), //phone  verify
        );
        print(
          _data,
        );
      } else {
        Get.snackbar("Account Creation", "Image is not selected ",
            snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  void deleteprofile() {
    setState(() {
      image = false;
      _image = Image.asset('asset/images/profile.jpg');
    });
  }

  Future getImage() async {
    bool _permissionStatus = await Permission.mediaLibrary.isGranted;
    print("Accsess:-> $_permissionStatus");
    if (_permissionStatus) {
      List<Media>? pickedFile = await ImagesPicker.pick(
        count: 1,
        pickType: PickType.image,
      );
      setState(() {
        if (pickedFile != null) {
          File _im = File(pickedFile.elementAt(0).path);
          _image = _im;
          image = true;
          print("image-->$_image");
        } else {
          print('No image selected.');
        }
      });
    } else {
      Get.snackbar("Media Access ", "Media Access nedded to select image");
      PermissionStatus _access = await _permissionforcamera.request();
      if (_access == PermissionStatus.granted ||
          _access == PermissionStatus.limited) {
        setState(() {
          _permissionStatus = true;
        });
      }
    }
  }

  Future getCamera() async {
    final pickedFile = await ImagesPicker.openCamera(
      pickType: PickType.image,
      quality: 1,
    );
    setState(() {
      if (pickedFile != null) {
        File _im = File(pickedFile.elementAt(0).path);
        _image = _im;
        image = true;
        print(" image ${_image.toString().trim()}");
      } else {
        print('No image selected.');
      }
    });
  }

  Widget get() {
    return Container(
      color: Colors.white,
      height: 200,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Choos your profile picture",
            style: TextStyle(fontSize: 18),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                  primary: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                onPressed: getImage,
                child: Icon(
                  Icons.image,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.05,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                  primary: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                onPressed: getCamera,
                child: Icon(
                  Icons.camera,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.05,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                  primary: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                onPressed: deleteprofile,
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.05,
              ),
            ],
          ),
        ],
      ),
    );
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
              Get.back();
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 38),
                ),
                SizedBox(
                  height: 20,
                ),
                Column(
                  children: [
                    SizedBox(
                      height: 115,
                      width: 140,
                      child: Stack(
                        clipBehavior: Clip.antiAlias,
                        fit: StackFit.expand,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey.withOpacity(0.19),
                                    spreadRadius: 0,
                                    blurRadius: 50,
                                    offset: Offset(0, 0))
                              ],
                            ),
                            child: !image
                                ? CircleAvatar(
                                    backgroundImage:
                                        AssetImage('asset/images/profile.jpg'),
                                    backgroundColor: Colors.grey[200])
                                : CircleAvatar(
                                    child: ClipOval(
                                      child: SizedBox(
                                        width: 115,
                                        height: 140,
                                        child: Image.file(
                                          _image,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: SizedBox(
                              height: 46,
                              width: 46,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.all(0),
                                  primary: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                                onPressed: () {
                                  Get.bottomSheet(get());
                                },
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 25,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Form(
                  key: _formkey,
                  child: Column(
                    children: [
                      Container(
                        width: 320,
                        child: TextFormField(
                          controller: _username,
                          validator: (val) => val!.length > 5
                              ? null
                              : "Username should be at least 6 charcter",
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            prefixIcon:
                                Icon(Icons.person, color: Colors.black87),
                            contentPadding: EdgeInsets.all(20),
                            hintText: "Username",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(width: .6),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(width: 1, color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.03,
                      ),
                      Container(
                        width: 320,
                        child: TextFormField(
                          controller: _email,
                          validator: (val) => val!.contains('@gmail.com')
                              ? null
                              : "Enter valide email",
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            prefixIcon:
                                Icon(Icons.email, color: Colors.black87),
                            contentPadding: EdgeInsets.all(20),
                            hintText: "Email",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(width: .6),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(width: 1, color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.03,
                      ),
                      Container(
                        width: 320,
                        child: TextFormField(
                          controller: _ph,
                          validator: (val) => val!.length == 10
                              ? null
                              : "Phone Number should be 10 digits",
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.phone_android_rounded,
                                color: Colors.black87),
                            contentPadding: EdgeInsets.all(20),
                            hintText: "Phone number",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(width: .6),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(width: 1, color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.03,
                      ),
                      Container(
                        width: 320,
                        child: TextFormField(
                          obscureText: isobscure,
                          controller: _pass,
                          validator: (val) => val!.length > 6
                              ? null
                              : "password should be at least 6 charcter",
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.send,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: FaIcon(
                                isobscure
                                    ? FontAwesomeIcons.eye
                                    : FontAwesomeIcons.eyeSlash,
                                color: Colors.black87,
                              ),
                              onPressed: () {
                                setState(() {
                                  isobscure = !isobscure;
                                });
                              },
                            ),
                            prefixIcon:
                                Icon(Icons.vpn_key, color: Colors.black87),
                            contentPadding: EdgeInsets.all(20),
                            hintText: "Password",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(width: .6),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(width: 1, color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 33,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 12,
                          ),
                        ),
                        onPressed: _create,
                        child: Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 35,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an Account ?',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Get.off(SignIn(app: app));
                            },
                            child: Text(
                              ' Sign In',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
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
