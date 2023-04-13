enum ApiControllerService {
  lenta,
  pushToken,
  favoriteLenta,
  event,
}

extension ControllerServiceExtension on ApiControllerService {
  String url() {
    switch (this) {
      case ApiControllerService.lenta:
        return 'AppStructure';
      case ApiControllerService.pushToken:
        return 'pushIdUpdate';
      case ApiControllerService.favoriteLenta:
        return 'FavoriteEvents';
      case ApiControllerService.event:
        return 'AppContent';
    }
  }
}
