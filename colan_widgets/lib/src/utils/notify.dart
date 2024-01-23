// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class NotificationMessage {
  final String message;
  const NotificationMessage({
    this.message = '',
  });
}

class NotificationMessageNotifier
    extends StateNotifier<List<NotificationMessage>> {
  NotificationMessageNotifier() : super([]);

  Future<void> push(String message) async {
    state = [...state, NotificationMessage(message: message)];
  }

  void pop() {
    state = state.sublist(1);
  }
}

final notificationMessageProvider = StateNotifierProvider<
    NotificationMessageNotifier, List<NotificationMessage>>((ref) {
  return NotificationMessageNotifier();
});
