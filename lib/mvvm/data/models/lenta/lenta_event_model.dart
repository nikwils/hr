//NOTE: событие или новость в ленте событий
class LentaEventModel {
  final int id;
  final int type;
  final String name;

  String? announce;
  String? picture;
  String? dateEnd;
  String? dateStart;

  LentaEventModel({
    required this.id,
    required this.type,
    required this.name,
    this.announce,
    this.picture,
    this.dateEnd,
    this.dateStart,
  });

  factory LentaEventModel.fromJson(Map<String, dynamic> json) =>
      LentaEventModel(
        id: json['Id'],
        type: json['Type'],
        name: json['Name'],
        announce: json['Announce'],
        picture: json['Picture'],
        dateEnd: json['DateEnd'],
        dateStart: json['DateStart'],
      );

  LentaEventModel copyWith({
    int? id,
    int? type,
    String? name,
    String? announce,
    String? picture,
    String? dateEnd,
    String? dateStart,
  }) {
    return LentaEventModel(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      announce: announce ?? this.announce,
      picture: picture ?? this.picture,
      dateEnd: dateEnd ?? this.dateEnd,
      dateStart: dateStart ?? this.dateStart,
    );
  }
}
