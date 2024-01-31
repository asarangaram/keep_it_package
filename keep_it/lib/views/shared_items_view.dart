import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import '../widgets/from_store/from_store.dart';
import '../widgets/keep_media_wizard/keep_media_wizard.dart';

class SharedItemsView extends StatelessWidget {
  const SharedItemsView({
    required this.media,
    required this.onDiscard,
    super.key,
  });

  final CLMediaInfoGroup? media;
  final void Function(CLMediaInfoGroup media) onDiscard;

  @override
  Widget build(BuildContext context) {
    if (media == null) {
      const CLFullscreenBox(
        child: CLBackground(
          child: Center(
            child: Text('No Media Found'),
          ),
        ),
      );
    }
    return CLFullscreenBox(
      child: CLBackground(
        child: LoadTags(
          buildOnData: (tags) => SafeArea(
            child: Column(
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
                        onTap: () {
                          onDiscard(media!);
                        },
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: CLMediaGridView.byMatrixSize(
                    media!.list,
                    hCount: switch (media!.list.length) { _ => 2 },
                  ),
                ),
                const Divider(
                  thickness: 4,
                ),
                SizedBox(
                  height: kMinInteractiveDimension * 4,
                  child: KeepMediaWizard(
                    media: media!,
                    onDone: onDiscard,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
