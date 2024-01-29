import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/from_store/from_store.dart';
import '../widgets/keep_media_wizard/keep_media_wizard.dart';

class SharedItemsView extends ConsumerStatefulWidget {
  const SharedItemsView({
    required this.mediaAsync,
    required this.onDiscard,
    super.key,
  });

  final AsyncValue<CLMediaInfoGroup> mediaAsync;
  final void Function(CLMediaInfoGroup media) onDiscard;

  @override
  ConsumerState<SharedItemsView> createState() => _SharedItemsViewState();
}

class _SharedItemsViewState extends ConsumerState<SharedItemsView> {
  @override
  Widget build(BuildContext context) {
    return CLFullscreenBox(
      child: CLBackground(
        child: Stack(
          children: [
            LoadTags(
              buildOnData: (tags) => widget.mediaAsync.when(
                data: (media) {
                  return SafeArea(
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
                                  widget.onDiscard(media);
                                },
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: CLMediaGridView.byMatrixSize(
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
                            onDone: widget.onDiscard,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                error: (err, _) => CLErrorView(errorMessage: err.toString()),
                loading: () => const Center(
                  child: CLLoadingView(message: 'Looking for Shared Content'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
