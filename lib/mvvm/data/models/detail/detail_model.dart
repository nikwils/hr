import 'package:hr_events/mvvm/data/models/detail/detail_event_model.dart';

class DetailModel {
  final ResModel res;

  DetailModel({
    required this.res,
  });

  factory DetailModel.fromJson(Map<String, dynamic> json) => DetailModel(
        res: ResModel.fromJson(json['Res']),
      );
}

class ResModel {
  final DetailEventModel eventContent;

  ResModel({
    required this.eventContent,
  });

  factory ResModel.fromJson(Map<String, dynamic> json) => ResModel(
        eventContent: DetailEventModel.fromJson(json['Reference']),
      );
}
