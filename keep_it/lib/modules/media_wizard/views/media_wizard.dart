import 'dart:math';

import 'package:app_loader/app_loader.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:store/store.dart';

import '../../../models/media_handler.dart';
import '../../../providers/gallery_group_provider.dart';
import '../../../widgets/editors/collection_editor_wizard/create_collection_wizard.dart';
import '../../../widgets/empty_state.dart';
import '../../shared_media/step4_save_collection.dart';
import '../models/types.dart';
import '../providers/media_provider.dart';

class UniversalMediaWizard extends ConsumerWidget {
  const UniversalMediaWizard({required this.type, super.key});
  final UniversalMediaTypes type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final media = ref.watch(universalMediaProvider(type));
    if (media.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CLPopScreen.onPop(context);
      });
      return const EmptyState();
    }
    final galleryMap = ref.watch(singleGroupItemProvider(media.entries));
    return FullscreenLayout(
      child: CLPopScreen.onSwipe(
        child: SelectAndKeepMedia(
          media: media,
          type: type,
          galleryMap: galleryMap,
        ),
      ),
    );
  }
}

class SelectAndKeepMedia extends ConsumerStatefulWidget {
  const SelectAndKeepMedia({
    required this.media,
    required this.type,
    required this.galleryMap,
    super.key,
  });
  final CLSharedMedia media;
  final UniversalMediaTypes type;

  final List<GalleryGroup<CLMedia>> galleryMap;

  @override
  ConsumerState<SelectAndKeepMedia> createState() => SelectAndKeepMediaState();
}

class SelectAndKeepMediaState extends ConsumerState<SelectAndKeepMedia> {
  CLSharedMedia selectedMedia = const CLSharedMedia(entries: []);

  bool keepSelected = false;
  bool isSelectionMode = false;

  CLSharedMedia get candidate => isSelectionMode ? selectedMedia : widget.media;
  bool get hasCandidate => candidate.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return GetDBManager(
      builder: (dbManager) {
        final selectedMediaHandler = MediaHandler.multiple(
          media: isSelectionMode ? selectedMedia.entries : widget.media.entries,
          dbManager: dbManager,
        );
        if (!keepSelected) {
          return WizardLayout(
            title: 'Unsaved',
            onCancel: () => CLPopScreen.onPop(context),
            actions: [
              CLButtonText.small(
                isSelectionMode ? 'Done' : 'Select',
                onTap: () {
                  setState(() {
                    isSelectionMode = !isSelectionMode;
                  });
                },
              ),
            ],
            wizard: keepSelected
                ? Container()
                : WizardDialog(
                    option1: CLMenuItem(
                      title: isSelectionMode ? 'Keep Selected' : 'Keep All',
                      icon: Icons.save,
                      onTap: hasCandidate
                          ? () async {
                              keepSelected = true;
                              setState(() {});
                              return true;
                            }
                          : null,
                    ),
                    option2: CLMenuItem(
                      title: isSelectionMode ? 'Delete Selected' : 'Delete All',
                      icon: Icons.delete,
                      onTap: hasCandidate
                          ? () => selectedMediaHandler.delete(context, ref)
                          : null,
                    ),
                    content: /* isSelectionMode
                        ? Center(
                            child: Text(
                              hasCandidate
                                  ? 'Select Media to proceed'
                                  : 'Do you want to keep the selected media or delete ?',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    fontSize: CLScaleType.standard.fontSize,
                                  ),
                            ),
                          )
                        :  */
                        null,
                  ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: CLGalleryCore<CLMedia>(
                key: ValueKey(widget.type.identifier),
                items: widget.galleryMap,
                itemBuilder: (
                  context,
                  item,
                ) =>
                    Hero(
                  tag: '${widget.type.identifier} /item/${item.id}',
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: PreviewService(
                      media: item,
                      keepAspectRatio: false,
                    ),
                  ),
                ),
                columns: 4,
                onSelectionChanged: isSelectionMode
                    ? (List<CLMedia> items) {
                        selectedMedia = selectedMedia.copyWith(entries: items);
                        setState(() {});
                      }
                    : null,
                keepSelected: keepSelected,
              ),
            ),
          );
        }
        return Column(
          children: [
            Expanded(
              child: CLSimpleItemsSelector<CLMedia>(
                key: ValueKey(widget.type.identifier),
                galleryMap: widget.galleryMap,
                itemBuilder: (
                  context,
                  item,
                ) =>
                    Hero(
                  tag: '${widget.type.identifier} /item/${item.id}',
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: PreviewService(
                      media: item,
                      keepAspectRatio: false,
                    ),
                  ),
                ),
                emptyState: const SizedBox.shrink(),
                identifier: widget.type.identifier,
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
                          .map(
                            (e) => e.copyWith(collectionId: collection.id),
                          )
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
