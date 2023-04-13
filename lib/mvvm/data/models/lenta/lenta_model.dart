import 'package:hr_events/mvvm/data/models/lenta/lenta_event_model.dart';

//NOTE: список событий на главной
class LentaModel {
  final ResLentaModel res;

  LentaModel({
    required this.res,
  });

  factory LentaModel.fromJson(Map<String, dynamic> json) => LentaModel(
        res: ResLentaModel.fromJson(json['Res']),
      );
}

class ResLentaModel {
  final List<LentaEventModel> lenta;

  ResLentaModel({
    required this.lenta,
  });

  factory ResLentaModel.fromJson(Map<String, dynamic> json) => ResLentaModel(
        lenta: List<LentaEventModel>.from(json['Lenta']
            .map((property) => LentaEventModel.fromJson(property))),
      );
}
