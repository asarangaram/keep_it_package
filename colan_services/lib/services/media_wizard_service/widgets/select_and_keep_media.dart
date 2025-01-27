import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';
import 'package:store/store.dart';

import '../../basic_page_service/widgets/dialogs.dart';
import '../../basic_page_service/widgets/page_manager.dart';
import 'create_collection_wizard.dart';
import 'wizard_preview.dart';

class SelectAndKeepMedia extends ConsumerStatefulWidget {
  const SelectAndKeepMedia({
    required this.media,
    required this.type,
    required this.galleryMap,
    super.key,
  });
  final CLSharedMedia media;
  final UniversalMediaSource type;

  final List<GalleryGroupCLEntity<CLMedia>> galleryMap;

  @override
  ConsumerState<SelectAndKeepMedia> createState() => SelectAndKeepMediaState();
}

class SelectAndKeepMediaState extends ConsumerState<SelectAndKeepMedia> {
  CLSharedMedia selectedMedia = const CLSharedMedia(entries: []);
  late Collection? targetCollection;
  late bool keepSelected;
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
  void initState() {
    keepSelected = widget.type == UniversalMediaSource.move;
    targetCollection = widget.media.collection;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final currMedia =
        (isSelectionMode ? selectedMedia.entries : widget.media.entries);
    return GetStoreUpdater(
      errorBuilder: (_, __) {
        throw UnimplementedError('errorBuilder');
      },
      loadingBuilder: () => CLLoader.widget(
        debugMessage: 'GetStoreUpdater',
      ),
      builder: (theStore) {
        return WizardLayout(
          title: widget.type.label,
          onCancel: () => PageManager.of(context).pop(),
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
                      isValidSuggestion: (collection) {
                        // ALLOW NEW COLLECTION OR SERVER COLLECTION
                        // IF ANY OF THE MEDIA IS FROM SERVER
                        if (collection.isDeleted) return false;
                        if (currMedia.any((e) => e.hasServerUID)) {
                          return collection.id == null ||
                              collection.hasServerUID;
                        } else {
                          return true;
                        }
                      },
                      onDone: ({required collection}) => setState(() {
                        targetCollection = collection;
                      }),
                    )

                  /// Needed reload as impact of edit is not reflecting in
                  /// the universalMediaProvider
                  /// We only need to update the collectionId
                  : StreamBuilder<Progress>(
                      stream: theStore.mediaUpdater.moveMultiple(
                        media: currMedia,
                        collection: targetCollection!.copyWith(
                          // mark to upload as atlease one media is from server
                          serverUID: (currMedia.any((e) => e.hasServerUID) &&
                                  !targetCollection!.hasServerUID)
                              ? () => -1
                              : null,
                        ),
                        onDone: ({
                          required List<CLMedia> mediaMultiple,
                        }) async {
                          await ref
                              .read(
                                universalMediaProvider(widget.type).notifier,
                              )
                              .remove(candidate.entries);
                          selectedMedia = const CLSharedMedia(entries: []);
                          keepSelected = false;
                          targetCollection = null;
                          isSelectionMode = false;
                          setState(() {});
                          ref.read(serverProvider.notifier).instantSync();
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
                    icon: clIcons.save,
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
                          icon: clIcons.deleteItem,
                          onTap: hasCandidate
                              ? () async {
                                  final confirmed =
                                      await DialogService.deleteMediaMultiple(
                                            context,
                                            ref,
                                            media: currMedia,
                                          ) ??
                                          false;
                                  if (!confirmed) return confirmed;
                                  if (context.mounted) {
                                    final res =
                                        theStore.mediaUpdater.deleteMultiple(
                                      {...currMedia.map((e) => e.id!)},
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
                                  return null;
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
}
