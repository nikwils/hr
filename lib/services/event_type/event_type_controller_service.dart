enum EventTypeControllerService {
  eventsAndNews,
  events,
  news,
}

extension EventTypeControllerServiceExtension on EventTypeControllerService {
  int? type() => switch (this) {
        EventTypeControllerService.events => 10,
        EventTypeControllerService.news => 140,
        EventTypeControllerService.eventsAndNews => null,
      };
}
