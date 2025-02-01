import 'package:cl_media_viewers_flutter/cl_media_viewers_flutter.dart';
import 'package:colan_widgets/colan_widgets.dart';

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

import '../../../media_view_service/widgets/media_preview_service.dart';

class MediaPreviewWithOverlays extends StatelessWidget {
  const MediaPreviewWithOverlays({
    required this.parentIdentifier,
    required this.media,
    required this.parentCollection,
    super.key,
  });
  final CLMedia media;
  final Collection parentCollection;
  final String parentIdentifier;

  @override
  Widget build(BuildContext context) {
    final haveItOffline = switch (media.type) {
      CLMediaType.image => parentCollection.haveItOffline,
      _ => false
    };
    final isMediaWaitingForDownload = media.hasServerUID &&
        !media.isMediaCached &&
        media.mediaLog == null &&
        haveItOffline;

    return Stack(
      children: [
        Positioned.fill(
          child: MediaPreviewService(
            media: media,
            parentIdentifier: parentIdentifier,
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: FractionallySizedBox(
              heightFactor: 0.2,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  media.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ShadTheme.of(context).textTheme.small.copyWith(
                        backgroundColor: ShadTheme.of(context)
                            .colorScheme
                            .foreground
                            .withValues(alpha: 0.5),
                        color: ShadTheme.of(context).colorScheme.background,
                      ),
                ),
              ),
            ),
          ),
        ),
        if (media.isMediaCached && media.hasServerUID)
          OverlayWidgets(
            alignment: Alignment.topLeft,
            sizeFactor: 0.15,
            child: const CLIcon.standard(
              Icons.check_circle,
              color: Colors.blue,
            ),
          )
        else if (isMediaWaitingForDownload)
          OverlayWidgets(
            alignment: Alignment.topLeft,
            sizeFactor: 0.15,
            child: const CircularProgressIndicator(
              color: Colors.blue,
            ),
          ),
      ],
    );
  }
}
