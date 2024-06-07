import 'package:flutter/material.dart';

enum MessageTypes { text, audio }

@immutable
class CLMessage {
  const CLMessage({required this.dateTime});

  final DateTime dateTime;
}

@immutable
class CLTextMessage extends CLMessage {
  const CLTextMessage({required super.dateTime, required this.text});
  final String text;
}

@immutable
class CLAudioMessage extends CLMessage {
  const CLAudioMessage({
    required super.dateTime,
    required this.path,
  });
  final String path;
}
