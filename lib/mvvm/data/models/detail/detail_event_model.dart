//NOTE: полные данные на странице по событию
class DetailEventModel {
  String title;
  String content;
  bool inFavorite;
  int? type;
  int? id;
  String? picture;
  String? additionalImage;
  String? dateStart;
  String? dateEnd;
  String? location;
  String? timeStart;
  String? timeEnd;
  String? address;
  List<Map<String, dynamic>>? email;
  List<Map<String, dynamic>>? phone;
  List<Map<String, dynamic>>? url;

  DetailEventModel({
    required this.title,
    required this.content,
    required this.inFavorite,
    this.type,
    this.id,
    this.picture,
    this.additionalImage,
    this.dateStart,
    this.dateEnd,
    this.location,
    this.timeStart,
    this.timeEnd,
    this.address,
    this.email,
    this.url,
    this.phone,
  });

  factory DetailEventModel.fromJson(Map<String, dynamic> json) =>
      DetailEventModel(
        title: json["Title"],
        picture: json["Picture"],
        additionalImage: json["AdditionalImage"],
        content: json["Content"],
        dateStart: json["DateStart"],
        dateEnd: json["DateEnd"],
        location: json["Location"],
        timeStart: json["TimeStart"],
        timeEnd: json["TimeEnd"],
        address: json["Address"],
        email: json["Email"] != null
            ? List<Map<String, dynamic>>.from(json["Email"].map((x) => x))
            : null,
        url: json["Url"] != null
            ? List<Map<String, dynamic>>.from(json["Url"].map((x) => x))
            : null,
        phone: json["Phone"] != null
            ? List<Map<String, dynamic>>.from(json["Phone"].map((x) => x))
            : null,
        type: json["Type"],
        inFavorite: json["InFavorite"],
      );

  DetailEventModel copyWith({
    String? title,
    String? content,
    bool? inFavorite,
    int? type,
    int? id,
    String? picture,
    String? additionalImage,
    String? dateStart,
    String? dateEnd,
    String? location,
    String? timeStart,
    String? timeEnd,
    String? address,
    List<Map<String, dynamic>>? email,
    List<Map<String, dynamic>>? phone,
    List<Map<String, dynamic>>? url,
  }) {
    return DetailEventModel(
      title: title ?? this.title,
      content: content ?? this.content,
      inFavorite: inFavorite ?? this.inFavorite,
      type: type ?? this.type,
      id: id ?? this.id,
      picture: picture ?? this.picture,
      additionalImage: additionalImage ?? this.additionalImage,
      dateStart: dateStart ?? this.dateStart,
      dateEnd: dateEnd ?? this.dateEnd,
      location: location ?? this.location,
      timeStart: timeStart ?? this.timeStart,
      timeEnd: timeEnd ?? this.timeEnd,
      address: address ?? this.address,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      url: url ?? this.url,
    );
  }
}
