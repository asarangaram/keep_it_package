import 'dart:math';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:store/store.dart';

import '../preview_service/view/preview.dart';
import '../shared_media_service/models/cl_shared_media.dart';
import '../shared_media_service/models/media_handler.dart';
import 'models/types.dart';
import 'providers/gallery_group_provider.dart';
import 'providers/media_provider.dart';
import 'views/create_collection_wizard.dart';

class MediaWizardService extends ConsumerWidget {
  const MediaWizardService({required this.type, super.key});
  final UniversalMediaTypes type;
  static Future<void> addMedia(
    BuildContext context,
    WidgetRef ref, {
    required UniversalMediaTypes type,
    required CLSharedMedia media,
  }) async {
    ref.read(universalMediaProvider(type).notifier).mediaGroup = media;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final media = ref.watch(universalMediaProvider(type));
    if (media.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CLPopScreen.onPop(context);
      });
      return const SizedBox.expand();
    }
    final galleryMap = ref.watch(singleGroupItemProvider(media.entries));
    return CLPopScreen.onSwipe(
      child: SelectAndKeepMedia(
        media: media,
        type: type,
        galleryMap: galleryMap,
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
  String get keepActionLabel => [
        widget.type.actionLabel,
        if (isSelectionMode)
          'Selected'
        else
          widget.media.entries.length > 1 ? 'All' : '',
      ].join(' ');
  String get deleteActionLabel => [
        'Delete',
        if (isSelectionMode)
          'Selected'
        else
          widget.media.entries.length > 1 ? 'All' : '',
      ].join(' ');
  String get toggleSelectModeActionLabel => isSelectionMode ? 'Done' : 'Select';

  bool get canSelect => !keepSelected && widget.media.entries.length > 1;
  void onToggleSelectMode() {
    setState(() {
      isSelectionMode = !isSelectionMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetDBManager(
      builder: (dbManager) {
        final selectedMediaHandler = MediaHandler.multiple(
          media: isSelectionMode ? selectedMedia.entries : widget.media.entries,
          dbManager: dbManager,
        );

        return WizardLayout(
          title: widget.type.label,
          onCancel: () => CLPopScreen.onPop(context),
          actions: [
            if (canSelect)
              CLButtonText.small(
                toggleSelectModeActionLabel,
                onTap: onToggleSelectMode,
              ),
          ],
          wizard: keepSelected
              ? !hasCollection
                  ? CreateCollectionWizard(
                      onDone: ({required collection}) => setState(() {
                        targetCollection = collection;
                      }),
                    )
                  : StreamBuilder<Progress>(
                      stream: MediaHandler.acceptMedia(
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
                    )
              : WizardDialog(
                  option1: CLMenuItem(
                    title: keepActionLabel,
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
                  option2: (widget.type.canDelete)
                      ? CLMenuItem(
                          title: deleteActionLabel,
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
                                  selectedMedia =
                                      const CLSharedMedia(entries: []);
                                  keepSelected = false;
                                  targetCollection = null;
                                  isSelectionMode = false;
                                  setState(() {});

                                  return res;
                                }
                              : null,
                        )
                      : null,
                ),
          child: WizardPreview(
            type: widget.type,
            onSelectionChanged: isSelectionMode
                ? (List<CLMedia> items) {
                    selectedMedia = selectedMedia.copyWith(entries: items);
                    setState(() {});
                  }
                : null,
            freezeView: keepSelected,
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
    return SizedBox(
      height: kMinInteractiveDimension * 2,
      child: LayoutBuilder(
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
      ),
    );
  }
}

class WizardPreview extends ConsumerWidget {
  const WizardPreview({
    required this.type,
    required this.onSelectionChanged,
    required this.freezeView,
    super.key,
  });
  final UniversalMediaTypes type;
  final void Function(List<CLMedia>)? onSelectionChanged;
  final bool freezeView;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final media = ref.watch(universalMediaProvider(type));
    if (media.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CLPopScreen.onPop(context);
      });
      return const SizedBox.expand();
    }
    final galleryMap = ref.watch(singleGroupItemProvider(media.entries));
    return CLGalleryCore<CLMedia>(
      key: ValueKey(type.identifier),
      items: galleryMap,
      itemBuilder: (
        context,
        item,
      ) =>
          Hero(
        tag: '${type.identifier} /item/${item.id}',
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: PreviewService(
            media: item,
            keepAspectRatio: false,
          ),
        ),
      ),
      columns: 4,
      onSelectionChanged: onSelectionChanged,
      keepSelected: freezeView,
    );
  }
}
