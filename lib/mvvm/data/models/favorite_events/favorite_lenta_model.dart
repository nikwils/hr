import 'package:hr_events/mvvm/data/models/favorite_events/favorite_event_model.dart';

//NOTE: список событий на странице с подписками
class FavoriteLentaModel {
  final ResLentaFavoriteModel res;

  FavoriteLentaModel({
    required this.res,
  });

  factory FavoriteLentaModel.fromJson(Map<String, dynamic> json) => FavoriteLentaModel(
        res: ResLentaFavoriteModel.fromJson(json['Res']),
      );
}

class ResLentaFavoriteModel {
  final List<FavoriteEventModel> favoriteList;

  ResLentaFavoriteModel({
    required this.favoriteList,
  });

  factory ResLentaFavoriteModel.fromJson(Map<String, dynamic> json) => ResLentaFavoriteModel(
        favoriteList: List<FavoriteEventModel>.from(json['FavoriteList'].map((property) => FavoriteEventModel.fromJson(property))),
      );
}
