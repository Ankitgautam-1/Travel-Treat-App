import 'package:flutter/material.dart';

class Plans extends StatelessWidget {
  const Plans({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      padding: EdgeInsets.symmetric(
        vertical: 10,
      ),
      height: double.infinity,
      color: Colors.grey.shade100,
      child: Column(
        children: [
          Center(
            child: Text(
              "Plan",
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}
