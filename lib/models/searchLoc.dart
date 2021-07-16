class SearchLoc {
  late dynamic address;
  late String lat;
  late String lng;

  SearchLoc({required this.address, required this.lat, required this.lng});
  SearchLoc.fromJson(Map<String, dynamic> json) {
    address = json['results'];
  }
}
