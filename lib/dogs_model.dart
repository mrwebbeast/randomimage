class DogsModel {
  final String imgUrl;

  DogsModel({required this.imgUrl});
  factory DogsModel.fromJson(Map<String, dynamic> json) {
    return DogsModel(imgUrl: json["message"]);
  }
}
