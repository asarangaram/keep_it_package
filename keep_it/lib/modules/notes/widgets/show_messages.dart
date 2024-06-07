import 'dart:io';

import 'package:flutter/material.dart';

import '../chat_bubble.dart';
import '../models/message.dart';

class ShowMessages extends StatelessWidget {
  const ShowMessages({
    required this.messages,
    required this.appDirectory,
    super.key,
  });

  final List<CLMessage> messages;
  final Directory appDirectory;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final m = messages[index];
        if (m.runtimeType == CLAudioMessage) {
          return WaveBubble(
            path: (m as CLAudioMessage).path,
            width: MediaQuery.of(context).size.width / 2,
            appDirectory: appDirectory,
          );
        } else {
          return ChatBubble(
            text: (m as CLTextMessage).text,
          );
        }
      },
    );
  }
}
