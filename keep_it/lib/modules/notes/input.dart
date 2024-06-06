
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
    /* return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Add Notes',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(
              color: Colors.blue,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(
              color: Colors.blue,
              width: 2,
            ),
          ),
          prefixIcon: Icon(MdiIcons.microphoneMessage),
          suffixIcon: Transform.rotate(
            angle: -math.pi / 3,
            child: Icon(MdiIcons.send),
          ),
        ),
      ),
    ); */
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
