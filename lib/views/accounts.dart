import 'dart:io';

import 'package:app/Data/accountProvider.dart';
import 'package:app/Data/image.dart';
import 'package:app/views/settings/myaccount.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

class Accounts extends StatefulWidget {
  Accounts({Key? key}) : super(key: key);

  @override
  State<Accounts> createState() => _AccountsState();
}

class _AccountsState extends State<Accounts>
    with SingleTickerProviderStateMixin {
  final TextEditingController username =
      TextEditingController.fromValue(TextEditingValue(text: "Ankit"));
  late final AnimationController _controller = AnimationController(
    duration: Duration(milliseconds: 1400),
    vsync: this,
  )..forward(from: 0);
  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: Offset(-2, 0),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.fastOutSlowIn,
  ));
  late final Animation<Offset> _offsetAnimation2 = Tween<Offset>(
    begin: Offset(-3, 0),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.fastOutSlowIn,
  ));
  late final Animation<Offset> _offsetAnimation3 = Tween<Offset>(
    begin: Offset(-4, 0),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.fastOutSlowIn,
  ));
  late final Animation<Offset> _offsetAnimation4 = Tween<Offset>(
    begin: Offset(-5, 0),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.fastOutSlowIn,
  ));
  late final Animation<Offset> _offsetAnimation5 = Tween<Offset>(
    begin: Offset(-6, 0),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.fastOutSlowIn,
  ));
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: size.width,
        height: double.infinity,
        color: Colors.grey.shade100,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: Colors.grey.shade900,
              ),
            ),
            Positioned(
              top: size.height * 0.22,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding:
                    EdgeInsets.only(top: 80, bottom: 30, left: 30, right: 30),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SlideTransition(
                      position: _offsetAnimation,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.82,
                        // padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(15)),
                        height: 50,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            primary: Colors.black,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          onPressed: () {
                            Get.to(MyAccounts());
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Iconsax.user_octagon),
                              SizedBox(
                                width: 20,
                              ),
                              Text('My Account'),
                              Spacer(),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    SlideTransition(
                      position: _offsetAnimation2,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.82,
                        // padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(15)),
                        height: 50,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            primary: Colors.black,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          onPressed: () {},
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              LineIcon(LineIcons.car),
                              SizedBox(
                                width: 20,
                              ),
                              Text('My Trips'),
                              Spacer(),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    SlideTransition(
                      position: _offsetAnimation3,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.82,
                        // padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(15)),
                        height: 50,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            primary: Colors.black,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          onPressed: () {},
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Iconsax.setting_2),
                              SizedBox(
                                width: 20,
                              ),
                              Text('Settings'),
                              Spacer(),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    SlideTransition(
                      position: _offsetAnimation4,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.82,
                        // padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(15)),
                        height: 50,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            primary: Colors.black,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          onPressed: () {},
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Iconsax.message_question),
                              SizedBox(
                                width: 20,
                              ),
                              Text('Help Center'),
                              Spacer(),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 85,
                    ),
                    SlideTransition(
                      position: _offsetAnimation5,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.82,
                        // padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(15)),
                        height: 50,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            primary: Colors.black,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          onPressed: () {},
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Icons.logout_rounded),
                              SizedBox(
                                width: 20,
                              ),
                              Text('Logout'),
                              Spacer(),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: size.height * 0.13,
              left: size.width * 0.31,
              right: size.width * 0.31,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: Colors.grey.shade300),
                child: Hero(
                  tag: "profile",
                  child: Center(
                      child: CircularProfileAvatar(
                    '''https://ugxqtrototfqtawjhnol.supabase.in/storage/v1/object/public/travel-treat-storage/Users/${Provider.of<AccountProvider>(context, listen: false).userAccount.Uid}/${Provider.of<AccountProvider>(context, listen: false).userAccount.Uid}''',
                    imageFit: BoxFit.cover,
                    radius: 65,
                    cacheImage: true,
                    initialsText: Text(
                        Provider.of<AccountProvider>(context, listen: false)
                            .userAccount
                            .Username
                            .substring(0, 1)),
                    onTap: () {
                      Get.to(Accounts());
                    },
                  )),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
