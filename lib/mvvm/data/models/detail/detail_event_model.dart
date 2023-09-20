//NOTE: полные данные на странице по событию
class DetailEventModel {
  String title;
  bool inFavorite;
  int? id;
  String? content;
  int? type;
  String? picture;
  String? additionalImage;
  String? dateStart;
  String? dateEnd;
  String? location;
  String? timeStart;
  String? timeEnd;
  String? address;
  List<Map<String, dynamic>>? eventContacts;

  DetailEventModel({
    required this.title,
    required this.inFavorite,
    this.content,
    this.id,
    this.type,
    this.picture,
    this.additionalImage,
    this.dateStart,
    this.dateEnd,
    this.location,
    this.timeStart,
    this.timeEnd,
    this.address,
    this.eventContacts,
  });

  factory DetailEventModel.fromJson(Map<String, dynamic> json) =>
      DetailEventModel(
        title: json["Title"],
        content: json["Content"],
        inFavorite: json["InFavorite"],
        id: json["Id"],
        type: json["Type"],
        picture: json["Picture"],
        additionalImage: json["AdditionalImage"],
        dateStart: json["DateStart"],
        dateEnd: json["DateEnd"],
        location: json["Location"],
        timeStart: json["TimeStart"],
        timeEnd: json["TimeEnd"],
        address: json["Address"],
        eventContacts: json["EventContacts"] != null
            ? List<Map<String, dynamic>>.from(
                json["EventContacts"].map((x) => x))
            : null,
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
    List<Map<String, dynamic>>? eventContacts,
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
      eventContacts: eventContacts ?? this.eventContacts,
    );
  }
}
