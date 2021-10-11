// import 'dart:io';

// import 'package:app/Data/accountProvider.dart';
// import 'package:app/Data/image.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class Profile extends StatefulWidget {
//   const Profile({Key? key}) : super(key: key);

//   @override
//   _ProfileState createState() => _ProfileState();
// }

// class _ProfileState extends State<Profile> {
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: EdgeInsets.symmetric(vertical: 20),
//       child: Column(
//         children: [
//           Center(
//             child: Provider.of<ImageData>(context, listen: false).image == null
//                 ? CircleAvatar(
//                     backgroundColor: Colors.black26,
//                     radius: 55,
//                     backgroundImage: FileImage(File(
//                         Provider.of<AccountProvider>(context, listen: false)
//                             .userAccount
//                             .Image!)),
//                   )
//                 : CircleAvatar(
//                     backgroundColor: Colors.black26,
//                     radius: 55,
//                     backgroundImage: FileImage(
//                         Provider.of<ImageData>(context, listen: false).image!),
//                   ),
//           ),
//           SizedBox(height: 20),
          
//         ],
//       ),
//     );
//   }
// }

