import 'dart:async';
import 'dart:math';

import 'package:app_loader/app_loader.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  Collection? targetCollection;
  bool keepSelected = false;
  bool isSelectionMode = false;

  CLSharedMedia get candidate => isSelectionMode ? selectedMedia : widget.media;
  bool get hasCandidate => candidate.isNotEmpty;
  bool get hasCollection => targetCollection != null;

  @override
  Widget build(BuildContext context) {
    return GetDBManager(
      builder: (dbManager) {
        final selectedMediaHandler = MediaHandler.multiple(
          media: isSelectionMode ? selectedMedia.entries : widget.media.entries,
          dbManager: dbManager,
        );

        return WizardLayout(
          title: 'Unsaved',
          onCancel: () => CLPopScreen.onPop(context),
          actions: [
            if (!keepSelected)
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
              ? !hasCollection
                  ? SizedBox(
                      height: kMinInteractiveDimension * 4,
                      child: CreateCollectionWizard(
                        onDone: ({required collection}) => setState(() {
                          targetCollection = collection;
                        }),
                      ),
                    )
                  : SizedBox(
                      height: kMinInteractiveDimension * 2,
                      child: StreamBuilder<Progress>(
                        stream: SaveCollection.acceptMedia(
                          dbManager,
                          collection: targetCollection!,
                          media: List.from(candidate.entries),
                          onDone: () {
                            ref
                                .read(
                                  universalMediaProvider(widget.type).notifier,
                                )
                                .remove(candidate.entries);
                            selectedMedia = const CLSharedMedia(entries: []);
                            keepSelected = false;
                            targetCollection = null;
                            isSelectionMode = false;
                            setState(() {});
                          },
                        ),
                        builder: progressBarBuilder,
                      ),
                    )
              : SizedBox(
                  height: kMinInteractiveDimension * 2,
                  child: WizardDialog(
                    option1: CLMenuItem(
                      title: isSelectionMode ? 'Keep Selected' : 'Keep All',
                      icon: Icons.save,
                      onTap: hasCandidate
                          ? () async {
                              keepSelected = true;
                              targetCollection = widget.media.collection;
                              setState(() {});
                              return true;
                            }
                          : null,
                    ),
                    option2: CLMenuItem(
                      title: isSelectionMode ? 'Delete Selected' : 'Delete All',
                      icon: Icons.delete,
                      onTap: hasCandidate
                          ? () async {
                              final res = await selectedMediaHandler.delete(
                                context,
                                ref,
                              );

                              await ref
                                  .read(
                                    universalMediaProvider(widget.type)
                                        .notifier,
                                  )
                                  .remove(candidate.entries);
                              selectedMedia = const CLSharedMedia(entries: []);
                              keepSelected = false;
                              targetCollection = null;
                              isSelectionMode = false;
                              setState(() {});

                              return res;
                            }
                          : null,
                    ),
                  ),
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
      },
    );
  }

  Widget progressBarBuilder(
    BuildContext context,
    AsyncSnapshot<Progress> snapshot,
  ) {
    final percentage =
        (snapshot.hasData ? min(1, snapshot.data!.fractCompleted) : 0.0)
                .toDouble() *
            100;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.all(15),
          child: LinearPercentIndicator(
            width: constraints.maxWidth - 40,
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
    );
  }
}
