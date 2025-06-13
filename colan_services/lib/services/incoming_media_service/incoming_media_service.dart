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
import '../basic_page_service/widgets/cl_error_view.dart';
import '../basic_page_service/widgets/page_manager.dart';
import '../entity_viewer_service/views/keep_it_error_view.dart';
import '../entity_viewer_service/views/keep_it_load_view.dart';

import 'widgets/step1_analyse.dart';
import 'widgets/step2_duplicates.dart';

class IncomingMediaService extends StatelessWidget {
  const IncomingMediaService({
    required this.incomingMedia,
    required this.onDiscard,
    super.key,
  });

  final CLMediaFileGroup incomingMedia;

  final void Function({required bool result}) onDiscard;

  @override
  Widget build(BuildContext context) {
    KeepItLoadView loadBuilder() => const KeepItLoadView();
    return GetRegisterredURLs(
        loadingBuilder: loadBuilder,
        errorBuilder: (e, st) => KeepItErrorView(e: e, st: st),
        builder: (registeredURLs) {
          return FullscreenLayout(
            child: IncomingMediaHandler0(
              serverId: registeredURLs.activeStoreURL.name,
              errorBuilder: (e, st) => CLErrorView(errorMessage: e.toString()),
              loadingBuilder: () =>
                  CLLoader.widget(debugMessage: 'IncomingMediaService'),
              incomingMedia: incomingMedia,
              onDiscard: onDiscard,
            ),
          );
        });
  }
}

class IncomingMediaHandler0 extends ConsumerStatefulWidget {
  const IncomingMediaHandler0({
    required this.serverId,
    required this.incomingMedia,
    required this.onDiscard,
    required this.errorBuilder,
    required this.loadingBuilder,
    super.key,
  });
  final String serverId;
  final CLMediaFileGroup incomingMedia;

  final void Function({required bool result}) onDiscard;

  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _IncomingMediaHandler0State();
}

class _IncomingMediaHandler0State extends ConsumerState<IncomingMediaHandler0> {
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
                        errorBuilder: widget.errorBuilder,
                        loadingBuilder: widget.loadingBuilder,
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
                            serverId: widget.serverId,
                            mg: CLSharedMedia(
                              entries: ViewerEntities([
                                ...mg?.entries.entities ?? [],
                                ...newCandidates?.entities ?? [],
                              ]),
                              collection: widget.incomingMedia.collection,
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
        serverId: widget.serverId,
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
      required String serverId,
      required CLSharedMedia mg}) async {
    _infoLogger(mg.toString());
    _infoLogger('onSave - Enter');
    isSavingState = true;
    widget.onDiscard(result: mg.isNotEmpty);
    final contentOrigin = widget.incomingMedia.type ?? ContentOrigin.stale;
    storeTaskManager.add(StoreTask(
      items: mg.entries.entities.cast<StoreEntity>(),
      contentOrigin: contentOrigin,
    ));
    await PageManager.of(context).openWizard(contentOrigin, serverId: serverId);

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
