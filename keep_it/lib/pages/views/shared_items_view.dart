import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/db_store.dart';

import 'collection_list_view.dart';
import 'receive_shared/media_preview.dart';
import 'receive_shared/save_or_cancel.dart';

class SharedItemsView extends ConsumerWidget {
  const SharedItemsView({
    super.key,
    required this.media,
    required this.onDiscard,
  });

  final Map<String, SupportedMediaType> media;
  final Function() onDiscard;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(collectionsProvider(null));

    return CLFullscreenBox(
        useSafeArea: true,
        // backgroundColor: theme.colorTheme.backgroundColor,
        hasBorder: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: MediaPreview(media: media)),
            const SizedBox(
              height: 8,
            ),
            SaveOrCancel(
              saveLabel: "Keep it",
              cancelLabel: "Discard",
              onDiscard: onDiscard,
              onSave: collectionsAsync.when(
                loading: () => null,
                error: (err, _) => null,
                data: (collections) => () => showDialog<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return CollectionListViewDialog.fromDBSelectable(
                          clusterID: null,
                          onSelectionDone: (collection) {
                            // TODO :Implement
                            Navigator.of(context).pop();
                          },
                          onSelectionCancel: () {
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
              ),
            )
          ],
        ));
  }
}

/*

*/