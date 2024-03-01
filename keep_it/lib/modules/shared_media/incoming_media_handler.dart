import 'package:app_loader/app_loader.dart';
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
  final CLSharedMedia incomingMedia;
  final void Function() onDiscard;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _IncomingMediaHandlerState();
}

class _IncomingMediaHandlerState extends ConsumerState<IncomingMediaHandler> {
  CLSharedMedia? candidates;

  @override
  void didChangeDependencies() {
    candidates = null;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    _infoLogger('build IncomingMediaHandler $candidates');
    final Widget widget0;
    try {
      widget0 = FullscreenLayout(
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
          (final candiates) when candidates!.collection == null =>
            WhichCollection(
              incomingMedia: candiates,
              onDone: onDone,
              onCancel: onDiscard,
            ),
          _ => SaveCollection(
              incomingMedia: candidates!,
              onDone: onSave,
              onCancel: onDiscard,
            )
        },
      );
    } catch (e) {
      return FullscreenLayout(
        child: CLErrorView(errorMessage: e.toString()),
      );
    }
    _infoLogger('build IncomingMediaHandler - Done');
    return widget0;
  }

  void onSave({required CLSharedMedia? mg}) {
    ref.read(notificationMessageProvider.notifier).push('Saved');

    onDiscard();
  }

  void onDone({CLSharedMedia? mg}) {
    if (mg == null || mg.isEmpty) {
      ref.read(notificationMessageProvider.notifier).push('Nothing to save.');
      onDiscard();
      setState(() {
        candidates = null;
      });
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

bool _disableInfoLogger = true;
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i(msg);
  }
}
