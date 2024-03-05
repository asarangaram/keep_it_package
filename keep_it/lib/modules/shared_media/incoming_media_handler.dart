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
    this.moving = false,
  });
  final CLSharedMedia incomingMedia;
  final void Function() onDiscard;
  final bool moving;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _IncomingMediaHandlerState();
}

class _IncomingMediaHandlerState extends ConsumerState<IncomingMediaHandler> {
  CLSharedMedia? candidates;
  bool isSaving = false;
  @override
  void didChangeDependencies() {
    candidates = null;
    if (widget.moving) {
      // No need to analyze
      candidates = widget.incomingMedia;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    _infoLogger('build IncomingMediaHandler $candidates');
    final Widget widget0;
    if (isSaving) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    try {
      widget0 = FullscreenLayout(
        onClose: onDiscard,
        child: switch (candidates) {
          null => AnalysePage(
              incomingMedia: widget.incomingMedia,
              onDone: onDone,
              onCancel: onDiscard,
            ),
          (final candiates)
              when candidates!.hasTargetMismatchedItems && !widget.moving =>
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
              title: const CLText.large('Moving...'),
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
    candidates = null;
    isSaving = true;
    setState(() {});
    ref.read(notificationMessageProvider.notifier).push('Saved');

    onDiscard();
  }

  void onDone({CLSharedMedia? mg}) {
    if (mg == null || mg.isEmpty) {
      candidates = null;
      isSaving = true;
      setState(() {});
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
    isSaving = false;
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
