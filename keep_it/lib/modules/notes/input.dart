import 'package:flutter/material.dart';

import 'audio_record.dart';

class NotesInput extends StatefulWidget {
  const NotesInput({super.key});

  @override
  NotesInputState createState() => NotesInputState();
}

class NotesInputState extends State<NotesInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return const AudioRecorder();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
