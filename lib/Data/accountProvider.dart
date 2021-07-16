import 'package:flutter/cupertino.dart';
import 'package:app/models/userAccount.dart';

class AccountProvider extends ChangeNotifier {
  UserAccount userAccount =
      UserAccount(Email: "", Image: "", Ph: "", Uid: "", Username: "");

  void updateuseraccount(UserAccount userAccData) {
    userAccount = userAccData;
    notifyListeners();
  }
}
