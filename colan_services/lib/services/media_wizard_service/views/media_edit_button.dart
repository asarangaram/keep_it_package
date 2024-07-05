import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:store/store.dart';

class WizardMediaControl extends ConsumerWidget {
  const WizardMediaControl({required this.media, super.key});
  final CLMedia media;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showNotes = ref.watch(showControlsProvider).showNotes;
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        MediaEditButton(
          media: media,
        ),
        if (!showNotes)
          CLButtonIcon.small(
            MdiIcons.note,
            onTap: () {
              ref.read(showControlsProvider.notifier).showNotes();
            },
          ),
      ]
          .map(
            (e) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: e,
            ),
          )
          .toList(),
    );
  }
}

class MediaEditButton extends ConsumerWidget {
  const MediaEditButton({
    required this.media,
    super.key,
  });
  final CLMedia media;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetDBManager(
      builder: (dbManager) {
        return CLButtonIcon.small(
          MdiIcons.pencil,
          onTap: () async {
            await MediaHandler(dbManager: dbManager, media: media)
                .edit(context, ref);
          },
        );
      },
    );
  }
}
