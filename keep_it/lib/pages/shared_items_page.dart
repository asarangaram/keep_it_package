import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/from_store/load_tags.dart';
import '../widgets/keep_media_wizard/keep_media_wizard.dart';

class SharedItemsPage extends ConsumerWidget {
  const SharedItemsPage({
    required this.media,
    required this.onDiscard,
    required this.onAccept,
    super.key,
  });

  final CLMediaInfoGroup media;
  final void Function() onDiscard;
  final void Function(
    CLMediaInfoGroup media, {
    required Future<void> Function(
      BuildContext context,
      WidgetRef ref,
      CLMediaInfoGroup media,
    ) onUpdateDB,
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
              media.list,
              hCount: switch (media.list.length) { _ => 2 },
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
