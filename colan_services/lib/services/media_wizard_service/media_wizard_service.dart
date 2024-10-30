import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store/store.dart';

import '../basic_page_service/dialogs.dart';
import '../incoming_media_service/models/cl_shared_media.dart';
import '../media_view_service/providers/group_view.dart';
import '../notification_services/provider/notify.dart';

import 'providers/universal_media.dart';
import 'recycle_bin_service.dart';
import 'views/create_collection_wizard.dart';

import 'views/wizard_preview.dart';

class MediaWizardService extends ConsumerWidget {
  const MediaWizardService({
    required this.type,
    super.key,
  });
  final UniversalMediaSource type;

  static Future<bool?> openWizard(
    BuildContext context,
    WidgetRef ref,
    CLSharedMedia sharedMedia,
  ) async {
    if (sharedMedia.type == null) {
      return false;
    }
    if (sharedMedia.entries.isEmpty) {
      await ref
          .read(notificationMessageProvider.notifier)
          .push('Nothing to do.');
      return true;
    }

    await addMedia(
      context,
      ref,
      media: sharedMedia,
    );
    if (context.mounted) {
      await context.push(
        '/media_wizard?type='
        '${sharedMedia.type!.name}',
      );
    }

    return true;
  }

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
      );
    }
    final media = ref.watch(universalMediaProvider(type));
    if (media.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CLPopScreen.onPop(context);
      });
      return const SizedBox.expand();
    }
    final galleryMap = ref.watch(groupedItemsProvider(media.entries));

    return CLPopScreen.onSwipe(
      child: GetStoreUpdater(
        builder: (theStore) {
          return SelectAndKeepMedia(
            media: media,
            type: type,
            galleryMap: galleryMap,
          );
        },
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
  final UniversalMediaSource type;

  final List<GalleryGroup<CLMedia>> galleryMap;

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
      builder: (theStore) {
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
                      isValidSuggestion: (collection) {
                        // ALLOW NEW COLLECTION OR SERVER COLLECTION
                        // IF ANY OF THE MEDIA IS FROM SERVER
                        return collection.id == null ||
                            (currMedia.any((e) => e.hasServerUID) &&
                                collection.hasServerUID);
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
                        collection: targetCollection!,
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
                                      await ConfirmAction.deleteMediaMultiple(
                                            context,
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
