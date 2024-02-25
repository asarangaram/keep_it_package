import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'step1_analyse.dart';
import 'step2_duplicates.dart';
import 'step3_which_collection.dart';
import 'step4_save_collection.dart';

class IncomingMediaHandler extends ConsumerStatefulWidget {
  const IncomingMediaHandler({
    required this.incomingMedia,
    required this.onDiscard,
    super.key,
  });
  final CLMediaList incomingMedia;
  final void Function() onDiscard;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _IncomingMediaHandlerState();
}

class _IncomingMediaHandlerState extends ConsumerState<IncomingMediaHandler> {
  CLMediaList? candidates;

  @override
  void didChangeDependencies() {
    candidates = null;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    try {
      return FullscreenLayout(
        onClose: onDiscard,
        child: switch (candidates) {
          null => AnalysePage(
              incomingMedia: widget.incomingMedia,
              onDone: onDone,
              onCancel: onDiscard,
            ),
          (final candiates) when candidates!.hasTargetMismatchedItems =>
            DuplicatePage(
              incomingMedia: candiates,
              onDone: onDone,
              onCancel: onDiscard,
            ),
          (final candiates) when candidates!.collectionId == null =>
            WhichCollection(
              incomingMedia: candiates,
              onDone: onDone,
              onCancel: onDiscard,
            ),
          _ => SaveCollection(
              incomingMedia: candidates!,
              onDone: onDone,
              onCancel: onDiscard,
            )
        },
      );
    } catch (e) {
      return FullscreenLayout(
        child: CLErrorView(errorMessage: e.toString()),
      );
    }
  }

  void onDone({CLMediaList? mg}) {
    if (mg == null || mg.isEmpty) {
      ref.read(notificationMessageProvider.notifier).push('Nothing to save.');
      onDiscard();
      return;
    }
    setState(() {
      candidates = mg;
    });
  }

  void onDiscard() {
    candidates = null;
    widget.onDiscard();
    if (mounted) {
      setState(() {});
    }
  }
}
