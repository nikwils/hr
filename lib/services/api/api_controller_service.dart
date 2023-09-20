enum ApiControllerService {
  events,
  pushToken,
  favoriteEvents,
  event,
}

extension ControllerServiceExtension on ApiControllerService {
  String url() => switch (this) {
        ApiControllerService.events => '',
        ApiControllerService.pushToken => '',
        ApiControllerService.favoriteEvents => '',
        ApiControllerService.event => '',
      };
}
