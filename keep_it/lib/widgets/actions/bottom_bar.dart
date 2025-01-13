import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../navigation/providers/active_collection.dart';

class KeepItBottomBar extends ConsumerWidget {
  const KeepItBottomBar({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(activeCollectionProvider);
    return Align(
      alignment: Alignment.bottomCenter,
      child: GetCollection(
        id: id,
        errorBuilder: (_, __) => const SizedBox.shrink(),
        loadingBuilder: () => const SizedBox.shrink(),
        builder: (collection) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (id == null) const StaleMediaIndicator(),
              const ServerControl(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: CircleAvatar(
                        child: IconButton(
                          onPressed: () {
                            IncomingMediaMonitor.onPickFiles(
                              context,
                              ref,
                              collection: collection,
                            );
                          },
                          icon: Icon(clIcons.insertItem),
                        ),
                      ),
                    ),
                  ),
                  if (ColanPlatformSupport.cameraSupported) ...[
                    const SizedBox(
                      width: 16,
                    ),
                    // Right FAB
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: CircleAvatar(
                          child: IconButton(
                            onPressed: () {
                              PageManager.of(context, ref)
                                  .openCamera(collectionId: collection?.id);
                            },
                            icon: Icon(
                              clIcons.camera,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
