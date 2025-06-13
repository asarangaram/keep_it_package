import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:cl_media_tools/cl_media_tools.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:store/store.dart';
import 'package:store_tasks/store_tasks.dart';

import '../../internal/fullscreen_layout.dart';
import '../../models/cl_media_candidate.dart';
import '../../models/cl_shared_media.dart';
import '../basic_page_service/widgets/cl_error_view.dart';
import '../basic_page_service/widgets/page_manager.dart';

import 'widgets/step1_analyse.dart';
import 'widgets/step2_duplicates.dart';

class IncomingMediaService extends ConsumerStatefulWidget {
  const IncomingMediaService(
      {required this.incomingMedia, required this.onDiscard, super.key});

  final CLMediaFileGroup incomingMedia;

  final void Function({required bool result}) onDiscard;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _IncomingMediaHandlerState();
}

class _IncomingMediaHandlerState extends ConsumerState<IncomingMediaService> {
  CLSharedMedia? duplicateCandidates;
  ViewerEntities? newCandidates;

  bool isSaving = false;
  @override
  void didChangeDependencies() {
    duplicateCandidates = null;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return FullscreenLayout(
      child: GetDefaultStore(
          errorBuilder: (e, st) => CLErrorView(errorMessage: e.toString()),
          loadingBuilder: () =>
              CLLoader.widget(debugMessage: 'IncomingMediaService'),
          builder: (store) {
            return GetStoreTaskManager(
                contentOrigin: widget.incomingMedia.type ?? ContentOrigin.stale,
                builder: (taskManager) {
                  _infoLogger(
                      'build candidate: $duplicateCandidates, isSaving:$isSaving');
                  _infoLogger('incoming Media: ${widget.incomingMedia}');
                  final Widget widget0;
                  try {
                    widget0 = isSaving
                        ? const Center(child: CircularProgressIndicator())
                        : (duplicateCandidates == null)
                            ? AnalysePage(
                                store: store,
                                // Hide the Collection from Analysis so that all goes into default
                                incomingMedia: CLMediaFileGroup(
                                    entries: widget.incomingMedia.entries,
                                    type: widget.incomingMedia.type),
                                onDone: (
                                        {required existingEntities,
                                        required invalidContent,
                                        required newEntities}) =>
                                    segretated(
                                        storeTaskManager: taskManager,
                                        existingEntities: existingEntities,
                                        newEntities: newEntities,
                                        invalidContent: invalidContent),
                                onCancel: () => onDiscard(result: false),
                              )
                            : DuplicatePage(
                                incomingMedia: duplicateCandidates!,
                                onDone: ({required CLSharedMedia? mg}) {
                                  onSave(
                                    storeTaskManager: taskManager,
                                    mg: CLSharedMedia(
                                      entries: ViewerEntities([
                                        ...mg?.entries.entities ?? [],
                                        ...newCandidates?.entities ?? [],
                                      ]),
                                      collection:
                                          widget.incomingMedia.collection,
                                      type: widget.incomingMedia.type,
                                    ),
                                  );
                                },
                                onCancel: () => onDiscard(result: false),
                              );
                  } catch (e) {
                    return CLErrorView(errorMessage: e.toString());
                  }
                  _infoLogger('build IncomingMediaHandler - Done');
                  return widget0;
                });
          }),
    );
  }

  bool get isSavingState => isSaving;

  set isSavingState(bool val) {
    isSaving = val;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> segretated({
    required StoreTaskManager storeTaskManager,
    required ViewerEntities existingEntities,
    required ViewerEntities newEntities,
    required List<CLMediaContent> invalidContent,
  }) async {
    final duplicateCandidates0 = CLSharedMedia(
      entries: existingEntities,
      collection: widget.incomingMedia.collection,
      type: widget.incomingMedia.type,
    );
    if (duplicateCandidates0.targetMismatch.isNotEmpty) {
      duplicateCandidates = duplicateCandidates0;
      newCandidates = newEntities;
      setState(() {});
    } else {
      await onSave(
        storeTaskManager: storeTaskManager,
        mg: CLSharedMedia(
          entries: newEntities,
          collection: widget.incomingMedia.collection,
          type: widget.incomingMedia.type,
        ),
      );
    }
  }

  Future<void> onSave(
      {required StoreTaskManager storeTaskManager,
      required CLSharedMedia mg}) async {
    _infoLogger(mg.toString());
    _infoLogger('onSave - Enter');
    isSavingState = true;
    widget.onDiscard(result: mg.isNotEmpty);

    storeTaskManager.add(StoreTask(
      items: mg.entries.entities.cast<StoreEntity>(),
      contentOrigin: widget.incomingMedia.type ?? ContentOrigin.stale,
    ));
    await PageManager.of(context)
        .openWizard(widget.incomingMedia.type ?? ContentOrigin.stale);

    duplicateCandidates = null;
    newCandidates = null;

    isSavingState = false;
    _infoLogger('onSave - Return');
  }

  void onDiscard({required bool result}) {
    duplicateCandidates = null;
    _infoLogger('discard media');
    widget.onDiscard(result: result);
  }
}

bool _disableInfoLogger = true;
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i('Incoming Media Handler: $msg');
  }
}
