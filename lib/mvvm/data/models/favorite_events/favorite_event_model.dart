//NOTE: событие на странице подписок
class FavoriteEventModel {
  final int eventId;
  final int type;
  final int position;
  final String name;
  String? dateEnd;
  String? dateStart;

  FavoriteEventModel({
    required this.eventId,
    required this.type,
    required this.position,
    required this.name,
    this.dateEnd,
    this.dateStart,
  });

  factory FavoriteEventModel.fromJson(Map<String, dynamic> json) => FavoriteEventModel(
        eventId: json['EventId'],
        type: json['Type'],
        position: json['Position'],
        name: json['Name'],
        dateEnd: json['DateEnd'],
        dateStart: json['DateStart'],
      );
}
