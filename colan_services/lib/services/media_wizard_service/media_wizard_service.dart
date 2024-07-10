import 'package:colan_services/services/shared_media_service/models/on_get_media.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../shared_media_service/models/cl_shared_media.dart';
import 'models/types.dart';
import 'providers/gallery_group_provider.dart';
import 'providers/media_provider.dart';
import 'views/create_collection_wizard.dart';
import 'views/progress_bar.dart';
import 'views/wizard_preview.dart';

class MediaWizardService extends ConsumerWidget {
  const MediaWizardService({required this.type, super.key});
  final MediaSourceType type;
  static Future<void> addMedia(
    BuildContext context,
    WidgetRef ref, {
    required CLSharedMedia media,
  }) async {
    ref
        .read(
          universalMediaProvider(media.type ?? MediaSourceType.unclassified)
              .notifier,
        )
        .mediaGroup = media;
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
  final MediaSourceType type;

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
        'Discard',
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
    return GetDBManager(
      builder: (dbManager) {
        return MediaHandlerWidget(
          builder: ({required action}) {
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
                          stream: action.moveToCollectionStream(
                            currMedia,
                            collection: targetCollection!,
                            onDone: () {
                              ref
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
                            },
                          ),
                          builder: (context, snapShot) => ProgressBar(
                            progress: snapShot.hasData
                                ? snapShot.data?.fractCompleted
                                : null,
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
                                          await action.delete(currMedia);

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
      },
    );
  }
}
