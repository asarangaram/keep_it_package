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

import '../models/media_handler.dart';
import '../modules/shared_media/step4_save_collection.dart';
import '../modules/shared_media/wizard_page.dart';
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
              if (context.canPop()) {
                context.pop();
              }
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
        final selectedMediaHandler = MediaHandler.multiple(
          media: selectedMedia.entries,
          dbManager: dbManager,
        );
        if (!keepSelected) {
          return Padding(
            padding: const EdgeInsets.all(8),
            child: SharedMediaWizard.buildWizard(
              context,
              ref,
              title: 'Unsaved',
              message: selectedMedia.entries.isEmpty
                  ? 'Select Media to proceed'
                  : 'Do you want to keep the selected media or delete ?',
              onCancel: () {
                if (context.canPop()) {
                  context.pop();
                }
              },
              option1:
                  (keepSelected == false && selectedMedia.entries.isNotEmpty)
                      ? CLMenuItem(
                          title: 'Keep',
                          icon: Icons.save,
                          onTap: () async {
                            keepSelected = true;
                            setState(() {});
                            return true;
                          },
                        )
                      : null,
              option2: (keepSelected == false &&
                      selectedMedia.entries.isNotEmpty)
                  ? CLMenuItem(
                      title: 'Delete',
                      icon: Icons.delete,
                      onTap: () => selectedMediaHandler.delete(context, ref),
                    )
                  : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: DecoratedBox(
                  decoration:
                      const BoxDecoration(border: Border(bottom: BorderSide())),
                  child: CLSimpleItemsSelector<CLMedia>(
                    key: ValueKey(widget.label),
                    galleryMap: widget.galleryMap,
                    itemBuilder: (
                      context,
                      item,
                    ) =>
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
              ),
            ),
          );
        }
        return Column(
          children: [
            Expanded(
              child: CLSimpleItemsSelector<CLMedia>(
                key: ValueKey(widget.label),
                galleryMap: widget.galleryMap,
                itemBuilder: (
                  context,
                  item,
                ) =>
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
                      onPressed: () =>
                          selectedMediaHandler.delete(context, ref),
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
