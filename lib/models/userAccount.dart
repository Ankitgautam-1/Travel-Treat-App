class UserAccount {
  String Username;
  String Email;
  String Ph;
  dynamic Image;
  String emph;
  String Uid;
  String? ImageUrl;
  UserAccount(
      {required this.Email,
      required this.Image,
      required this.Ph,
      required this.Uid,
      required this.emph,
      required this.Username,
      this.ImageUrl});
}
