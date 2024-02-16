import 'dart:math';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mime/mime.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'app_descriptor.dart';

class IncomingProgress extends ConsumerStatefulWidget {
  const IncomingProgress({
    required this.incomingMedia,
    required this.incomingMediaViewBuilder,
    required this.onDiscard,
    super.key,
  });
  final CLMediaInfoGroup incomingMedia;
  final void Function() onDiscard;
  final void Function(int collectionID) onAccept;
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

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: SizedBox.expand(
          child: Stack(
            children: [
              Center(
                child: StreamBuilder<double>(
                  stream: analyseMedia(widget.incomingMedia),
                  builder:
                      (BuildContext context, AsyncSnapshot<double> snapshot) {
                    final double? percent;
                    if (snapshot.hasData) {
                      percent = min(1, snapshot.data!);
                      return CircularPercentIndicator(
                        radius: 100,
                        lineWidth: 13,
                        animation: true,
                        percent: percent,
                        center: CLText.veryLarge(
                          '${(percent * 100).toInt()} %',
                        ),
                        footer: const CLText.large(
                          'Please wait while analysing media files',
                        ),
                        circularStrokeCap: CircularStrokeCap.round,
                        progressColor: Colors.purple,
                      );
                    } else {
                      return CircularPercentIndicator(
                        radius: 100,
                        lineWidth: 13,
                        footer: const CLText.large(
                          'Please wait while analysing media files',
                        ),
                        circularStrokeCap: CircularStrokeCap.round,
                        progressColor: Colors.purple,
                      );
                    }
                  },
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(8),
                    /* boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ], */
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: CLButtonText.large(
                      'Discard',
                      onTap: widget.onDiscard,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Stream<double> analyseMedia(CLMediaInfoGroup media) async* {
    final updated = <CLMedia>[];

    // ignore: unused_local_variable
    for (final (i, item) in media.list.indexed) {
      switch (item.type) {
        case CLMediaType.file:
          {
            final clMedia = switch (lookupMimeType(item.path)) {
              (final String mime) when mime.startsWith('image') => CLMedia(
                  path: item.path,
                  type: CLMediaType.image,
                ),
              (final String mime) when mime.startsWith('video') =>
                await ExtCLMediaFile.clMediaWithPreview(
                  path: item.path,
                  type: CLMediaType.video,
                ),
              _ => CLMedia(path: item.path, type: CLMediaType.file),
            };

            updated.add(clMedia);
          }
        case CLMediaType.image:
        case CLMediaType.video:
        case CLMediaType.url:
          updated.add(item);
        case CLMediaType.audio:
        case CLMediaType.text:
          break;
      }
      await Future.delayed(const Duration(milliseconds: 200), () {});

      yield (i + 1) / media.list.length;
    }
    setState(() {
      clMediaInfoGroup = CLMediaInfoGroup(updated, targetID: media.targetID);
    });
  }
}
