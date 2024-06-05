import 'dart:async';

import 'package:app_loader/app_loader.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:keep_it/widgets/empty_state.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:store/store.dart';

import '../providers/gallery_group_provider.dart';

class StaleMediaPage extends ConsumerWidget {
  const StaleMediaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const label = 'Unclassified Media';
    const parentIdentifier = 'Unclassified Media';
    return FullscreenLayout(
      child: GetStaleMedia(
        buildOnData: (media) {
          if (media.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.pop();
            });
          }
          final galleryMap = ref.watch(singleGroupItemProvider(media));
          return GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity == null) return;
              // pop on Swipe
              if (details.primaryVelocity! > 0) {
                if (context.canPop()) {
                  context.pop();
                }
              }
            },
            child: StaleMediaHandler(
              label: label,
              parentIdentifier: parentIdentifier,
              galleryMap: galleryMap,
              emptyState: const EmptyState(),
            ),
          );
        },
      ),
    );
  }
}

class StaleMediaHandler extends ConsumerStatefulWidget {
  const StaleMediaHandler({
    required this.label,
    required this.parentIdentifier,
    required this.galleryMap,
    required this.emptyState,
    super.key,
  });

  final String label;
  final String parentIdentifier;
  final List<GalleryGroup<CLMedia>> galleryMap;
  final Widget emptyState;

  @override
  ConsumerState<StaleMediaHandler> createState() => _StaleMediaHandlerState();
}

class _StaleMediaHandlerState extends ConsumerState<StaleMediaHandler> {
  List<CLMedia> selectedItems = [];
  @override
  Widget build(BuildContext context) {
    return GetDBManager(
      builder: (dbManager) {
        return Column(
          children: [
            Expanded(
              child: CLSimpleItemsSelector<CLMedia>(
                key: ValueKey(widget.label),
                title: 'Unsaved  Media',
                galleryMap: widget.galleryMap,
                itemBuilder: (context, item, {required quickMenuScopeKey}) =>
                    Hero(
                  tag: '${widget.parentIdentifier} /item/${item.id}',
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: PreviewService(
                      media: item,
                      keepAspectRatio: false,
                    ),
                  ),
                ),
                emptyState: widget.emptyState,
                identifier: widget.parentIdentifier,
                columns: 2,
                onSelectionChanged: (List<CLMedia> items) {
                  selectedItems = items;
                  setState(() {});
                },
              ),
            ),
            if (selectedItems.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        context.push<bool>(
                          '/move?ids=${selectedItems.map((e) => e.id).join(',')}&unhide=true',
                        );
                      },
                      label: const CLText.small('Keep Selected'),
                      icon: Icon(MdiIcons.imageMove),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (BuildContext context) {
                                return CLConfirmAction(
                                  title: 'Confirm delete',
                                  message: 'Are you sure you want to delete '
                                      '${selectedItems.length} items?',
                                  child: null,
                                  onConfirm: ({required confirmed}) =>
                                      Navigator.of(context).pop(confirmed),
                                );
                              },
                            ) ??
                            false;
                        if (confirmed) {
                          await dbManager.deleteMediaMultiple(
                            selectedItems,
                            onDeleteFile: (f) async => f.deleteIfExists(),
                            onRemovePinMultiple: (ids) async {
                              /// This should not happen as
                              /// stale media can't be pinned
                              final res =
                                  await AlbumManager(albumName: 'KeepIt')
                                      .removeMultipleMedia(ids);
                              if (!res) {
                                await ref
                                    .read(
                                      notificationMessageProvider.notifier,
                                    )
                                    .push(
                                      "'Give Permission to "
                                      "remove from Gallery'",
                                    );
                              }
                              return res;
                            },
                          );
                        }
                        return;
                      },
                      label: const CLText.small('Discard Selected'),
                      icon: Icon(MdiIcons.delete),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
