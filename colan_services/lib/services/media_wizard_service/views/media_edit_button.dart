import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:store/store.dart';

class WizardMediaMenu extends ConsumerWidget {
  const WizardMediaMenu({required this.media, super.key});
  final CLMedia media;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showNotes = ref.watch(showControlsProvider).showNotes;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GetDBManager(
            builder: (dbManager) {
              return CLButtonText.small(
                'Edit Media',
                onTap: () async {
                  await MediaHandler(dbManager: dbManager, media: media)
                      .edit(context, ref);
                },
              );
            },
          ),
          CLButtonText.small(
            showNotes ? 'Hide Notes' : 'Show Notes',
            onTap: () {
              ref.read(showControlsProvider.notifier).showNotes();
            },
          ),
        ],
      ),
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
