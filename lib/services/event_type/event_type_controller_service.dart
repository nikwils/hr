enum EventTypeControllerService {
  allTypes,
  eventType,
  newsType,
}

extension EventTypeControllerServiceExtension on EventTypeControllerService {
  int? type() {
    switch (this) {
      case EventTypeControllerService.eventType:
        return 10;
      case EventTypeControllerService.newsType:
        return 140;
      case EventTypeControllerService.allTypes:
        return null;
    }
  }
}
