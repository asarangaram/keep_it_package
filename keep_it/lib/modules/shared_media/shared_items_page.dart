import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'keep_media_wizard/keep_media_wizard.dart';

class SharedItemsPage extends ConsumerWidget {
  const SharedItemsPage({
    required this.media,
    required this.onDiscard,
    required this.onAccept,
    super.key,
  });

  final CLMediaList media;
  final void Function() onDiscard;
  final void Function({
    CLMediaList? mg,
  }) onAccept;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LoadTags(
      buildOnData: (tags) => Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: SizedBox(
              height: 32 + 20,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 8,
                  right: 16,
                  bottom: 8,
                ),
                child: CLButtonIcon.small(
                  Icons.close,
                  onTap: onDiscard,
                ),
              ),
            ),
          ),
          Flexible(
            child: CLMediaCollage.byMatrixSize(
              media.entries,
              hCount: switch (media.entries.length) { _ => 2 },
              itemBuilder: (context, index) => CLMediaPreview(
                media: media.entries[index],
              ),
            ),
          ),
          const Divider(
            thickness: 4,
          ),
          SizedBox(
            height: kMinInteractiveDimension * 4,
            child: KeepMediaWizard(
              media: media,
              onDiscard: onDiscard,
              onAccept: onAccept,
            ),
          ),
        ],
      ),
    );
  }
}
