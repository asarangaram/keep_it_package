import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:keep_it_state/keep_it_state.dart';
import 'package:store/store.dart';

import '../../models/input_decoration.dart';

class ViewNotes extends StatelessWidget {
  const ViewNotes({required this.note, super.key, this.onTap});
  final CLMedia note;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GetStoreUpdater(
      errorBuilder: (_, __) {
        throw UnimplementedError('errorBuilder');
      },
      loadingBuilder: () => CLLoader.widget(
        debugMessage: 'GetStoreUpdater',
      ),
      builder: (theStore) {
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
                child: GetMediaText(
                  id: note.id!,
                  errorBuilder: (_, __) {
                    throw UnimplementedError('errorBuilder');
                  },
                  loadingBuilder: () => CLLoader.widget(
                    debugMessage: 'GetMediaText',
                  ),
                  builder: (text) {
                    return Text(
                      text,
                      textAlign: TextAlign.start,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontSize: CLScaleType.standard.fontSize),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
