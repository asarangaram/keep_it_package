import 'package:colan_services/colan_services.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

class CollectionAsFolder extends ConsumerWidget {
  const CollectionAsFolder({
    required this.collection,
    required this.quickMenuScopeKey,
    super.key,
  });
  final Collection collection;
  final GlobalKey<State<StatefulWidget>> quickMenuScopeKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetStoreUpdater(
      builder: (theStore) {
        return Column(
          children: [
            Flexible(
              child: CollectionMenu(
                collection: collection,
                isSyncing: false,
                child: CollectionView.preview(collection),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      collection.label,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  /* if (collection.serverUID != null)
                    Image.asset(
                      'assets/icon/cloud_on_lan_128px_color.png',
                    ), */
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
