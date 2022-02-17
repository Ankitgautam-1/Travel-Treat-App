import 'package:flutter/material.dart';

class MyAccounts extends StatelessWidget {
  const MyAccounts({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          child: Text("MyAccount"),
        ),
      ),
    );
  }
}
