import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';

import '../../internal/fullscreen_layout.dart';
import '../gallery_view_service/builders/available_media.dart';
import '../gallery_view_service/widgets/when_empty.dart';
import '../gallery_view_service/widgets/when_error.dart';

import 'widgets/keep_it_media_carousel_view.dart';

class MediaViewService extends StatelessWidget {
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
  Widget build(BuildContext context) {
    Widget errorBuilder(Object e, StackTrace st) => WhenError(
          errorMessage: e.toString(),
        );

    return AppTheme(
      child: FullscreenLayout(
        child: GetStoreUpdater(
          errorBuilder: errorBuilder,
          loadingBuilder: () => CLLoader.widget(
            debugMessage: 'GetStore',
          ),
          builder: (theStore) {
            return GetAvailableMediaByActiveCollectionId(
              loadingBuilder: () => CLLoader.widget(
                debugMessage: 'GetAvailableMediaByCollectionId',
              ),
              errorBuilder: errorBuilder,
              builder: (clmedias) => AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                transitionBuilder: (
                  Widget child,
                  Animation<double> animation,
                ) =>
                    FadeTransition(opacity: animation, child: child),
                child: clmedias.isEmpty
                    ? const WhenEmpty()
                    : KeepItMediaCorouselView(
                        parentIdentifier: parentIdentifier,
                        clmedias: clmedias,
                        initialMediaIndex: id,
                        theStore: theStore,
                        loadingBuilder: () => CLLoader.widget(
                          debugMessage: 'KeepItMainGrid',
                        ),
                        errorBuilder: errorBuilder,
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}
