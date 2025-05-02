import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:cl_media_tools/cl_media_tools.dart';
import 'package:colan_services/services/media_view_service/media_viewer/views/media_viewer_page_view.dart';
import 'package:colan_widgets/colan_widgets.dart' show SvgIcon, SvgIcons;
import 'package:content_store/content_store.dart';

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

import '../models/cl_icons.dart';
import '../notifier/riverpod/builders/get_video_player_controls.dart';
import '../notifier/riverpod/models/video_player_controls.dart';
import '../notifier/ui_state.dart' show uiStateManager;
import 'media_viewer.dart';
import 'on_toggle_audio_mute.dart';
import 'on_toggle_play.dart';
import 'video_progress.dart';

class MediaViewerCore extends StatelessWidget {
  const MediaViewerCore({required this.parentIdentifier, super.key});
  final String parentIdentifier;

  @override
  Widget build(BuildContext context) {
    final currentItem = uiStateManager.notifier.select(
      (state) => state.currentItem,
    );
    final length = uiStateManager.notifier.select(
      (state) => state.length,
    );

    return GetVideoPlayerControls(
      builder: (controls) {
        return ListenableBuilder(
          listenable: uiStateManager.notifier,
          builder: (_, __) {
            return switch (length.value) {
              0 => Container(),
              1 => ViewMedia(
                  currentItem: currentItem.value,
                  parentIdentifier: parentIdentifier,
                  autoStart: true,
                  playerControls: controls,
                ),
              _ => MediaViewerPageView(
                  parentIdentifier: parentIdentifier,
                  playerControls: controls,
                )
            };
          },
        );
      },
    );
  }
}

class ViewMedia extends StatelessWidget {
  const ViewMedia({
    required this.currentItem,
    required this.parentIdentifier,
    required this.playerControls,
    super.key,
    this.autoStart = false,
  });

  final String parentIdentifier;
  final ViewerEntityMixin currentItem;
  final VideoPlayerControls playerControls;
  final bool autoStart;

  Future<void> setVideo() async {
    // This seems still required
    await playerControls.setVideo(
      currentItem.mediaUri!,
      forced: false,
      autoPlay: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: uiStateManager.notifier,
      builder: (_, __) {
        final stateManager = uiStateManager.notifier.state;
        final uri = currentItem.mediaUri!;
        final isPlayable = autoStart &&
            /* widget.playerControls.uri != widget.currentItem.mediaUri && */
            currentItem.mediaType == CLMediaType.video &&
            currentItem.mediaUri != null;
        final mediaViewer = MediaViewer(
          heroTag: '$parentIdentifier /item/${currentItem.id}',
          uri: currentItem.mediaUri!,
          previewUri: currentItem.previewUri,
          mime: (currentItem as StoreEntity).data.mimeType!,
          onLockPage: ({required bool lock}) {},
          isLocked: false,
          autoStart: autoStart,
          autoPlay: true, // Fixme
          errorBuilder: (_, __) => const BrokenImage(),
          loadingBuilder: () => const GreyShimmer(),
          keepAspectRatio: stateManager.showMenu || isPlayable,
          hasGesture: !stateManager.showMenu,
        );
        if (!isPlayable) {
          return GestureDetector(
            onTap: uiStateManager.notifier.toggleMenu,
            child: isPlayable ? Center(child: mediaViewer) : mediaViewer,
          );
        }

        final player = ShadTheme(
          data: ShadTheme.of(context).copyWith(
            textTheme: ShadTheme.of(context).textTheme.copyWith(
                  small: ShadTheme.of(context).textTheme.small.copyWith(
                        color: playerUIPreferences.foregroundColor,
                        fontSize: 10,
                      ),
                ),
            ghostButtonTheme: ShadButtonTheme(
              backgroundColor: Colors.black.withValues(alpha: 0.5),
              foregroundColor: Colors.white,
              size: ShadButtonSize.sm,
            ),
          ),
          child: Stack(
            children: [
              if (stateManager.showMenu)
                GestureDetector(
                  onTap: isPlayable
                      ? () {
                          uiStateManager.notifier.showPlayerMenu();
                          playerControls.onPlayPause(uri);
                        }
                      : null,
                  child: mediaViewer,
                )
              else
                Center(
                  child: GestureDetector(
                    onTap: isPlayable
                        ? () {
                            uiStateManager.notifier.showPlayerMenu();
                            playerControls.onPlayPause(uri);
                          }
                        : null,
                    child: mediaViewer,
                  ),
                ),
              Positioned(
                top: 0,
                right: 0,
                child: ShadButton.ghost(
                  onPressed: uiStateManager.notifier.toggleMenu,
                  child: SvgIcon(
                    stateManager.showMenu
                        ? SvgIcons.fullScreen
                        : SvgIcons.fullScreenExit,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              if (stateManager.showPlayerMenu) ...[
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: OnTogglePlay(
                    uri: currentItem.mediaUri!,
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: OnToggleAudioMute(uri: currentItem.mediaUri!),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: VideoProgress(uri: currentItem.mediaUri!),
                ),
              ],
            ],
          ),
        );
        if (stateManager.showMenu) {
          return Center(
            child: player,
          );
        } else {
          return player;
        }
      },
    );
  }
}
