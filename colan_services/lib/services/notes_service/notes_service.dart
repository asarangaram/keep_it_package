import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:device_resources/device_resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'widgets/notes_view.dart';

class NotesService extends ConsumerWidget {
  const NotesService({
    required this.media,
    super.key,
  });
  final CLMedia media;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _GetNotes(
      media: media,
      builder: ({
        required List<CLNote> notes,
        required AppSettings appSettings,
        required DBManager dbManager,
      }) {
        return NotesView(
          appSettings: appSettings,
          dbManager: dbManager,
          notes: notes,
          media: media,
          onClose: () {
            ref.read(showControlsProvider.notifier).hideNotes();
          },
        );
      },
    );
  }
}

class _GetNotes extends StatelessWidget {
  const _GetNotes({required this.media, required this.builder});
  final CLMedia media;
  final Widget Function({
    required List<CLNote> notes,
    required AppSettings appSettings,
    required DBManager dbManager,
  }) builder;

  @override
  Widget build(BuildContext context) {
    return GetAppSettings(
      builder: (appSettings) {
        return GetDBManager(
          builder: (dbManager) {
            return GetNotesByMediaId(
              mediaId: media.id!,
              buildOnData: (notes) {
                return builder(
                  notes: notes,
                  appSettings: appSettings,
                  dbManager: dbManager,
                );
              },
            );
          },
        );
      },
    );
  }
}
