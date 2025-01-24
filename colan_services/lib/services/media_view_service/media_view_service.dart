import 'package:colan_services/colan_services.dart';
import 'package:colan_services/services/basic_page_service/cl_pop_screen.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../internal/fullscreen_layout.dart';
import 'media_view_service1.dart';

class MediaViewService extends ConsumerWidget {
  const MediaViewService({
    required this.id,
    required this.collectionId,
    required this.parentIdentifier,
    super.key,
  });
  final int? collectionId;
  final int id;
  final String parentIdentifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget errorBuilder(Object e, StackTrace st) => CLErrorPage(
          errorMessage: e.toString(),
        );

    if (collectionId == null) {
      return FullscreenLayout(
        useSafeArea: false,
        child: CLPopScreen.onSwipe(
          child: GetMedia(
            id: id,
            errorBuilder: (_, __) {
              throw UnimplementedError('errorBuilder');
              // ignore: dead_code
            },
            loadingBuilder: () => CLLoader.widget(
              debugMessage: 'GetMedia',
            ),
            builder: (media) {
              if (media == null) {
                return BasicPageService.nothingToShow(
                  message: 'no media found',
                );
              }
              return MediaViewService1(
                media: media,
                parentIdentifier: parentIdentifier,
                errorBuilder: errorBuilder,
                loadingBuilder: () => CLLoader.widget(
                  debugMessage: 'MediaViewService',
                ),
              );
            },
          ),
        ),
      );
    } else {
      return FullscreenLayout(
        useSafeArea: false,
        child: GetMediaByCollectionId(
          collectionId: collectionId,
          errorBuilder: (_, __) {
            throw UnimplementedError('errorBuilder');
            // ignore: dead_code
          },
          loadingBuilder: () => CLLoader.widget(
            debugMessage: 'GetMediaByCollectionId',
          ),
          builder: (items) {
            if (items.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                PageManager.of(context).pop();
              });
              return BasicPageService.nothingToShow(message: 'No Media');
            }
            final initialMedia =
                items.entries.where((e) => e.id == id).firstOrNull;
            final initialMediaIndex =
                initialMedia == null ? 0 : items.entries.indexOf(initialMedia);

            return MediaViewService1.pageView(
              media: items.entries,
              parentIdentifier: parentIdentifier,
              initialMediaIndex: initialMediaIndex,
              errorBuilder: errorBuilder,
              loadingBuilder: () => CLLoader.widget(
                debugMessage: 'MediaViewService.pageView',
              ),
            );
          },
        ),
      );
    }
  }
}
