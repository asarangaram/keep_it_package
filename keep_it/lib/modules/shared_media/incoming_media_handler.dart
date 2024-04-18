import 'package:app_loader/app_loader.dart';
import 'package:colan_services/colan_services.dart';
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
  final void Function({required bool result}) onDiscard;
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
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context)
                        .colorScheme
                        .onBackground
                        .withAlpha(192), // Color for the circular container
                  ),
                  child: CLButtonIcon.small(
                    Icons.close,
                    color:
                        Theme.of(context).colorScheme.background.withAlpha(192),
                    onTap: () => onDiscard(result: false),
                  ),
                ),
              ),
            ),
            switch (candidates) {
              null => AnalysePage(
                  incomingMedia: widget.incomingMedia,
                  onDone: onDone,
                  onCancel: () => onDiscard(result: false),
                ),
              (final candiates)
                  when candidates!.hasTargetMismatchedItems && !widget.moving =>
                DuplicatePage(
                  incomingMedia: candiates,
                  onDone: onDone,
                  onCancel: () => onDiscard(result: false),
                ),
              (final candiates) when candidates!.collection == null =>
                WhichCollection(
                  incomingMedia: candiates,
                  onDone: onDone,
                  onCancel: () => onDiscard(result: false),
                ),
              _ => SaveCollection(
                  incomingMedia: candidates!,
                  onDone: onSave,
                  onCancel: () => onDiscard(result: false),
                )
            },
          ],
        ),
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
    if (mounted) {
      setState(() {});
    }
    if (mounted) {
      ref.read(notificationMessageProvider.notifier).push('Done.');
    }
    onDiscard(result: true);
  }

  void onDone({CLSharedMedia? mg}) {
    if (mg == null || mg.isEmpty) {
      candidates = null;
      isSaving = true;
      setState(() {});
      ref.read(notificationMessageProvider.notifier).push('Nothing to do.');
      onDiscard(result: false);
      return;
    }
    setState(() {
      candidates = mg;
    });
  }

  void onDiscard({required bool result}) {
    candidates = null;

    widget.onDiscard(result: result);
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
