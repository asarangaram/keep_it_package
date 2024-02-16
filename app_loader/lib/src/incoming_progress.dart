import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class IncomingMediaHandler extends ConsumerStatefulWidget {
  const IncomingMediaHandler({required this.child, super.key});
  final Widget child;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _IncomingMediaHandlerState();
}

class _IncomingMediaHandlerState extends ConsumerState<IncomingMediaHandler> {
  @override
  Widget build(BuildContext context) {
    return Container();
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

