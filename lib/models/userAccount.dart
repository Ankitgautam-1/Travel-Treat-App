class UserAccount {
  String Username;
  String Email;
  String Ph;
  dynamic Image;
  String emph;
  String Uid;
  String? ImageUrl;
  String rating;
  UserAccount({
    required this.Email,
    required this.Image,
    required this.Ph,
    required this.Uid,
    required this.emph,
    required this.Username,
    this.ImageUrl,
    required this.rating,
  });
}
