import 'dart:math';

import 'package:app_loader/app_loader.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:keep_it/widgets/empty_state.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'package:store/store.dart';

import '../modules/shared_media/step4_save_collection.dart';
import '../providers/gallery_group_provider.dart';
import '../widgets/editors/collection_editor_wizard/create_collection_wizard.dart';

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
            child: SelectAndKeepMedia(
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

class SelectAndKeepMedia extends ConsumerStatefulWidget {
  const SelectAndKeepMedia({
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
  ConsumerState<SelectAndKeepMedia> createState() => SelectAndKeepMediaState();
}

class SelectAndKeepMediaState extends ConsumerState<SelectAndKeepMedia> {
  CLSharedMedia selectedMedia = const CLSharedMedia(entries: []);
  Collection? targetCollection;
  bool keepSelected = false;
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
                  selectedMedia = selectedMedia.copyWith(entries: items);
                  setState(() {});
                },
                keepSelected: keepSelected,
              ),
            ),
            if (keepSelected &&
                selectedMedia.entries.isNotEmpty &&
                selectedMedia.collection == null)
              SizedBox(
                height: kMinInteractiveDimension * 4,
                child: CreateCollectionWizard(
                  onDone: ({required collection}) {
                    selectedMedia = selectedMedia.copyWith(
                      collection: collection,
                      entries: selectedMedia.entries
                          .map((e) => e.copyWith(collectionId: collection.id))
                          .toList(),
                    );
                    setState(() {});
                  },
                ),
              )
            else if (keepSelected && selectedMedia.entries.isNotEmpty)
              StreamBuilder<Progress>(
                stream: SaveCollection.acceptMedia(
                  dbManager,
                  collection: selectedMedia.collection!,
                  media: List.from(selectedMedia.entries),
                  onDone: () {
                    selectedMedia = const CLSharedMedia(entries: []);
                    keepSelected = false;
                  },
                ),
                builder: (
                  BuildContext context,
                  AsyncSnapshot<Progress> snapshot,
                ) {
                  final percentage = (snapshot.hasData
                              ? min(1, snapshot.data!.fractCompleted)
                              : 0.0)
                          .toDouble() *
                      100;
                  return Padding(
                    padding: const EdgeInsets.all(15),
                    child: LinearPercentIndicator(
                      width: MediaQuery.of(context).size.width - 50,
                      animation: true,
                      lineHeight: 20,
                      animationDuration: 2000,
                      percent: percentage / 100,
                      animateFromLastPercent: true,
                      center: Text('$percentage'),
                      isRTL: true,
                      barRadius: const Radius.elliptical(5, 15),
                      progressColor: Theme.of(context).colorScheme.primary,
                      maskFilter: const MaskFilter.blur(BlurStyle.solid, 3),
                    ),
                  );
                },
              ),
            if (keepSelected == false && selectedMedia.entries.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        keepSelected = true;
                        setState(() {});
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
                                      '${selectedMedia.entries.length} items?',
                                  child: null,
                                  onConfirm: ({required confirmed}) =>
                                      Navigator.of(context).pop(confirmed),
                                );
                              },
                            ) ??
                            false;
                        if (confirmed) {
                          await dbManager.deleteMediaMultiple(
                            selectedMedia.entries,
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
