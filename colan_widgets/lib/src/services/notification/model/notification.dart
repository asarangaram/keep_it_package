import 'package:flutter/material.dart';

@immutable
class NotificationMessage {
  const NotificationMessage({
    this.message = '',
  });
  final String message;
}
