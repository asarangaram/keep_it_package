import 'package:cl_media_viewers_flutter/cl_media_viewers_flutter.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:store/store.dart';

import '../../gallery_view_service/models/entity_actions.dart';

class MediaControls extends ConsumerWidget {
  const MediaControls({
    required this.media,
    super.key,
  });

  final StoreEntity media;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = EntityActions.ofEntity(
      context,
      ref,
      media,
    );
    // Why the context didn't get initialied with CLTheme?
    return GetVideoPlayerControls(
      builder: (
        VideoPlayerControls controller,
      ) {
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final action in actions.actions)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: ShadButton.ghost(
                    child: Icon(
                      action.icon,
                      //  color: Colors.amber,
                    ),
                    // color: Theme.of(context).colorScheme.surface,
                    onPressed: () async {
                      await controller.pause();
                      await action.onTap?.call();
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/*

return ColoredBox(
      color: Theme.of(context).colorScheme.onSurface.withAlpha(128),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /* if (media.data.mediaType == CLMediaType.video)
                VideoDefaultControls(
                  uri: media.mediaUri!,
                  errorBuilder: (_, __) => Container(),
                  loadingBuilder: () => CLLoader.widget(
                    debugMessage: 'VideoDefaultControls',
                  ),
                ), */
              ,
              
            ],
          ),
        ),
      ),
    );
     */
