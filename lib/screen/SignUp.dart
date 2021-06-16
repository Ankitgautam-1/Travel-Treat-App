import 'dart:io';
import 'package:app/screen/Const.dart';
import 'package:app/screen/Dashboard.dart';
import 'package:app/screen/Email_verify.dart';
import 'package:app/screen/Phone_verify.dart';
import 'package:app/screen/sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController _username = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _ph = TextEditingController();
  TextEditingController _pass = TextEditingController();
  User? user;
  late List<String> _data;
  final _formkey = GlobalKey<FormState>();
  var _image;
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool image = false;
  bool isobscure = true;
  final picker = ImagePicker();
  void _create() async {
    if (_formkey.currentState!.validate()) {
      _data = [
        _username.text,
        _email.text,
        _ph.text,
        _pass.text,
        _image.toString()
      ];

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Prc(data: _data),
        ),
      );
      print(_data);
    }
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        File _im = File(pickedFile.path);
        _image = _im;
        image = true;
      } else {
        print('No image selected.');
      }
    });
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
                          !image
                              ? CircleAvatar(
                                  backgroundImage:
                                      AssetImage('asset/images/profile.jpg'),
                                )
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
                                onPressed: getImage,
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
                          validator: (val) => val!.length > 6
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
                            prefixIcon: Icon(Icons.send_to_mobile,
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
                                Icon(Icons.password, color: Colors.black87),
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
                        height: 20,
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
                        height: 8,
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
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignIn(),
                                ),
                              );
                            },
                            child: Text(
                              ' Sign In',
                              style: TextStyle(
                                fontSize: 16,
                                color: Const.maincolor,
                              ),
                            ),
                          ),
                        ],
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
