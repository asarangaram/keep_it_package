import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:store/store.dart';

import '../../../store_service/widgets/the_store.dart';
import '../../models/input_decoration.dart';

class ViewNotes extends StatelessWidget {
  const ViewNotes({required this.note, super.key, this.onTap});
  final CLMedia note;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: NotesTextFieldDecoration.inputDecoration(
        context,
        hintText: 'Add Notes',
        actionBuilder: null,
      ),
      child: SizedBox(
        height: double.infinity,
        child: GestureDetector(
          onTap: onTap,
          child: SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Text(
              TheStore.of(context).getText(note),
              textAlign: TextAlign.start,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontSize: CLScaleType.standard.fontSize),
            ),
          ),
        ),
      ),
    );
  }
}
