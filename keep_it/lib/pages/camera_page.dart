import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

class CameraPage extends ConsumerWidget {
  const CameraPage({super.key, this.collectionId});
  final int? collectionId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetStoreUpdater(
      errorBuilder: (_, __) {
        throw UnimplementedError('errorBuilder');
        // ignore: dead_code
      },
      loadingBuilder: () => CLLoader.widget(
        debugMessage: 'GetStoreUpdater',
      ),
      builder: (theStore) {
        return GetCollection(
          id: collectionId,
          errorBuilder: (_, __) {
            throw UnimplementedError('errorBuilder');
            // ignore: dead_code
          },
          loadingBuilder: () => CLLoader.widget(
            debugMessage: 'GetCollection',
          ),
          builder: (collection) {
            return CLCameraService(
              parentIdentifier: 'CLCameraService',
              onCancel: () => PageManager.of(context, ref).pop(),
              onNewMedia: (path, {required isVideo}) async {
                return theStore.mediaUpdater.create(
                  path,
                  type: isVideo ? CLMediaType.video : CLMediaType.image,
                  collectionId: () => collection?.id,
                );
              },
              onDone: (mediaList) async {
                await MediaWizardService.openWizard(
                  context,
                  ref,
                  CLSharedMedia(
                    entries: mediaList,
                    type: UniversalMediaSource.captured,
                    collection: collection,
                  ),
                );

                if (context.mounted) {
                  PageManager.of(context, ref).pop();
                }
              },
            );
          },
        );
      },
    );
  }
}
