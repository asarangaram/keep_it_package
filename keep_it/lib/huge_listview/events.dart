import 'package:event_bus/event_bus.dart';

class Bus {
  static final EventBus instance = EventBus();
}

class GalleryIndexUpdatedEvent {
  GalleryIndexUpdatedEvent(this.tag, this.index);
  final String tag;
  final int index;
}
