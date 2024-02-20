import 'package:app_loader/src/fullscreen_layout.dart';
import 'package:app_loader/src/shared_media/analyse.dart';
import 'package:app_loader/src/shared_media/duplicates.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'providers/incoming_media.dart';
import 'shared_media/shared_items_page.dart';

class IncomingMediaHandler extends ConsumerStatefulWidget {
  const IncomingMediaHandler({
    required this.child,
    super.key,
  });
  final Widget child;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _IncomingMediaHandlerState();
}

class _IncomingMediaHandlerState extends ConsumerState<IncomingMediaHandler> {
  CLMediaInfoGroup? candidates;

  @override
  void didChangeDependencies() {
    candidates = null;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final incomingMedia = ref.watch(incomingMediaStreamProvider);
    if (incomingMedia.isEmpty) {
      return widget.child;
    }

    try {
      return FullscreenLayout(
        onClose: onDiscard,
        child: switch (candidates) {
          null => AnalysePage(
              incomingMedia: incomingMedia[0],
              onDone: onDone,
              onCancel: onDiscard,
            ),
          (final candiates) when candidates!.hasTargetMismatchedItems =>
            DuplicatePage(
              incomingMedia: candiates,
              onDone: onDone,
              onCancel: onDiscard,
            ),
          (final candiates) when candidates!.targetID == null =>
            SharedItemsPage(
              media: candiates,
              onAccept: onDone,
              onDiscard: onDiscard,
            ),
          _ => StreamProgressView(
              stream: () => CLMediaProcess.acceptMedia(
                media: candidates!,
                onDone: (CLMediaInfoGroup mg) async {
                  ref.read(itemsProvider(mg.targetID!));
                  await ref
                      .read(itemsProvider(mg.targetID!).notifier)
                      .upsertItems(mg.list);
                  await ref
                      .read(notificationMessageProvider.notifier)
                      .push('Saved.');
                  onDone();
                },
              ),
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

  void onDone({CLMediaInfoGroup? mg}) {
    if (mg == null) {
      onDiscard();
      return;
    }
    setState(() {
      candidates = mg;
    });
  }

  void onDiscard() {
    candidates = null;
    ref.read(incomingMediaStreamProvider.notifier).pop();
    if (mounted) {
      setState(() {});
    }
  }
}

/* 
import 'dart:math';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:mime/mime.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'app_descriptor.dart';
import 'models/cl_media_process.dart';
import 'stream_progress.dart';
class IncomingProgress extends ConsumerStatefulWidget {
  const IncomingProgress({
    required this.incomingMedia,
    required this.incomingMediaViewBuilder,
    required this.onDiscard,
    required this.onAccept,
    super.key,
  });
  final CLMediaInfoGroup incomingMedia;
  final void Function() onDiscard;
  final Future<void> Function(
    int collectionID, {
    required Future<void> Function(List<CLMedia> items) updateDB,
  }) onAccept;
  final IncomingMediaViewBuilder incomingMediaViewBuilder;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _IncomingProgressState();
}

class _IncomingProgressState extends ConsumerState<IncomingProgress> {
  CLMediaInfoGroup? clMediaInfoGroup;

  @override
  Widget build(BuildContext context) {
    if (clMediaInfoGroup != null) {
      return widget.incomingMediaViewBuilder(
        context,
        ref,
        media: clMediaInfoGroup!,
        onDiscard: widget.onDiscard,
        onAccept: widget.onAccept,
      );
    }
    return StreamProgress(
      stream: () => CLMediaProcess.analyseMedia(widget.incomingMedia,
          (CLMediaInfoGroup mg) {
        setState(() {
          clMediaInfoGroup = mg;
        });
      }),
      onCancel: widget.onDiscard,
    );
  }
}
 */
