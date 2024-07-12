import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/cl_shared_media.dart';

import 'providers/gallery_group_provider.dart';
import 'providers/universal_media.dart';
import 'recycle_bin_service.dart';
import 'views/create_collection_wizard.dart';
import 'views/progress_bar.dart';
import 'views/wizard_preview.dart';

class MediaWizardService extends ConsumerWidget {
  const MediaWizardService({
    required this.type,
    required this.getPreview,
    required this.storeAction,
    super.key,
  });
  final UniversalMediaSource type;
  final Widget Function(CLMedia media) getPreview;
  final StoreActions storeAction;
  static Future<void> addMedia(
    BuildContext context,
    WidgetRef ref, {
    required CLSharedMedia media,
  }) async {
    ref
        .read(
          universalMediaProvider(
            media.type ?? UniversalMediaSource.unclassified,
          ).notifier,
        )
        .mediaGroup = media;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (type == UniversalMediaSource.deleted) {
      return RecycleBinService(
        type: type,
        getPreview: getPreview,
        storeAction: storeAction,
      );
    }
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
        storeAction: storeAction,
        type: type,
        galleryMap: galleryMap,
        getPreview: getPreview,
      ),
    );
  }
}

class SelectAndKeepMedia extends ConsumerStatefulWidget {
  const SelectAndKeepMedia({
    required this.media,
    required this.type,
    required this.galleryMap,
    required this.getPreview,
    required this.storeAction,
    super.key,
  });
  final CLSharedMedia media;
  final UniversalMediaSource type;
  final Widget Function(CLMedia media) getPreview;
  final StoreActions storeAction;
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
        widget.type.keepActionLabel,
        if (isSelectionMode)
          'Selected'
        else
          widget.media.entries.length > 1 ? 'All' : '',
      ].join(' ');
  String get deleteActionLabel => [
        widget.type.deleteActionLabel,
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
    final currMedia =
        (isSelectionMode ? selectedMedia.entries : widget.media.entries);
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

              /// Needed reload as impact of edit is not reflecting in
              /// the universalMediaProvider
              /// We only need to update the collectionId
              : StreamBuilder<Progress>(
                  stream: widget.storeAction.moveToCollectionStream(
                    currMedia,
                    collection: targetCollection!,
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
                  builder: (context, snapShot) => ProgressBar(
                    progress:
                        snapShot.hasData ? snapShot.data?.fractCompleted : null,
                  ),
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
                              final res =
                                  await ConfirmAction.deleteMediaMultiple(
                                context,
                                media: currMedia,
                                getPreview: widget.getPreview,
                                onConfirm: () => widget.storeAction
                                    .delete(currMedia, confirmed: true),
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
                    )
                  : null,
            ),
      child: WizardPreview(
        getPreview: widget.getPreview,
        type: widget.type,
        storeAction: widget.storeAction,
        onSelectionChanged: isSelectionMode
            ? (List<CLMedia> items) {
                selectedMedia = selectedMedia.copyWith(entries: items);
                setState(() {});
              }
            : null,
        freezeView: keepSelected,
      ),
    );
  }
}
