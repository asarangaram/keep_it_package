import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/notification.dart';

class NotificationMessageNotifier
    extends StateNotifier<List<NotificationMessage>> {
  NotificationMessageNotifier() : super([]);

  Future<void> push(String message) async {
    state = [...state, NotificationMessage(message: message)];
  }

  void pop() {
    switch (state.length) {
      case 0:
        return;
      case 1:
        state = [];
        return;
      default:
        state = state.sublist(1);
    }
  }
}

final notificationMessageProvider = StateNotifierProvider<
    NotificationMessageNotifier, List<NotificationMessage>>((ref) {
  return NotificationMessageNotifier();
});
