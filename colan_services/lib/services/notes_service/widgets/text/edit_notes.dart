import 'package:flutter/material.dart';
import 'package:keep_it_state/keep_it_state.dart';
import 'package:store/store.dart';

import '../../models/input_decoration.dart';

class EditNotes extends StatelessWidget {
  const EditNotes({
    required this.controller,
    required this.note,
    required this.onTap,
    this.focusNode,
    super.key,
  });
  final TextEditingController controller;
  final FocusNode? focusNode;
  final CLMedia? note;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: NotesTextFieldDecoration.inputDecoration(
        context,
        label: 'Add Notes',
        hintText: 'Add Notes',
        actionBuilder: null,
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: TextField(
          showCursor: true,
          controller: controller,
          focusNode: focusNode,
          maxLines: 3,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(fontSize: CLScaleType.standard.fontSize),
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(top: 4, bottom: 4),
          ),
          onChanged: (s) => onTap?.call(),
        ),
      ),
    );
  }
}
