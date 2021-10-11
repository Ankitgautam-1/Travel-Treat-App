import 'package:app/views/Welcome.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnBoardingPage extends StatefulWidget {
  final FirebaseApp app;
  OnBoardingPage({required this.app});
  @override
  _OnBoardingPageState createState() => _OnBoardingPageState(app: app);
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  FirebaseApp app;
  _OnBoardingPageState({required this.app});

  void _onIntroEnd(context) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setBool("IntroPage", false);
    Get.offAll(Welcome(app: app));
  }

  Widget _buildImage(String assetName, [double width = 350]) {
    return Image.asset(
      'asset/images/$assetName',
      width: width,
    );
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 16.0);
    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.normal),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.zero,
    );

    return SafeArea(
      child: IntroductionScreen(
        globalBackgroundColor: Colors.white,
        pages: [
          PageViewModel(
            title: "Account Creation",
            body:
                "Sign in & Sign up process is easy and supports Email & Google account.",
            image: Image.asset(
              "asset/images/1st_image.png",
              fit: BoxFit.fitWidth,
            ),
            decoration: pageDecoration,
          ),
          PageViewModel(
            title: "Cab Availability",
            body:
                "Travel Treat has huge system of cab's services  which increses availability of cabs.",
            image: _buildImage('2nd_image.png'),
            decoration: pageDecoration,
          ),
          PageViewModel(
            title: "Location Services",
            body:
                "Travel Treat uses user location to increase the user exprience and the details will be given to diver for better navigation of driver ,user can track there ride at any point of time.",
            image: _buildImage('3rd_image.png'),
            decoration: pageDecoration,
          ),
        ],
        onDone: () => _onIntroEnd(context),
        showSkipButton: true,
        skipFlex: 0,
        nextFlex: 0,
        //rtl: true, // Display as right-to-left
        skip: const Text(
          'Skip',
          style: TextStyle(
            color: Color.fromRGBO(25, 32, 82, 1),
          ),
        ),
        next: const Icon(
          Icons.arrow_forward,
          color: Color.fromRGBO(25, 32, 82, 1),
        ),
        done: Container(
          margin: EdgeInsets.only(bottom: 4),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Color.fromRGBO(25, 32, 82, 1),
          ),
          child: const Text(
            'Get Started',
            style: TextStyle(
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
          ),
        ),
        curve: Curves.fastLinearToSlowEaseIn,
        controlsMargin: const EdgeInsets.all(0),
        controlsPadding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
        dotsDecorator: const DotsDecorator(
          size: Size(6.0, 6.0),
          color: Color(0xFFBDBDBD),
          activeSize: Size(34.0, 5.0),
          activeColor: Color.fromRGBO(25, 32, 82, 1),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
        ),
        dotsContainerDecorator: const ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
        ),
      ),
    );
  }
}
