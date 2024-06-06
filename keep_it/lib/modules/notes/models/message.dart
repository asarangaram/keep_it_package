import 'package:flutter/material.dart';

enum MessageTypes { text, audio }

@immutable
class Message {
  const Message({required this.dateTime});

  final DateTime dateTime;
}

@immutable
class TextMessage extends Message {
  const TextMessage({required super.dateTime, required this.text});
  final String text;
}

@immutable
class AudioMessage extends Message {
  const AudioMessage({
    required super.dateTime,
    required this.path,
    required this.duration,
  });
  final String path;
  final Duration duration;
}
