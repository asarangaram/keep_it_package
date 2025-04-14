import 'package:cl_media_tools/cl_media_tools.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';
import 'package:store/store.dart';

import '../../internal/fullscreen_layout.dart';
import '../basic_page_service/widgets/cl_error_view.dart';
import '../media_wizard_service/media_wizard_service.dart';

import 'widgets/step1_analyse.dart';
import 'widgets/step2_duplicates.dart';

class IncomingMediaService extends StatelessWidget {
  const IncomingMediaService({
    required this.incomingMedia,
    required this.parentIdentifier,
    required this.onDiscard,
    required this.storeIdentity,
    super.key,
  });
  final CLMediaFileGroup incomingMedia;
  final String parentIdentifier;
  final void Function({required bool result}) onDiscard;
  final String storeIdentity;

  @override
  Widget build(BuildContext context) {
    return FullscreenLayout(
      child: IncomingMediaHandler0(
        storeIdentity: storeIdentity,
        errorBuilder: (errorMsg) => CLErrorView(errorMessage: errorMsg),
        loadingBuilder: () =>
            CLLoader.widget(debugMessage: 'IncomingMediaService'),
        incomingMedia: incomingMedia,
        parentIdentifier: parentIdentifier,
        onDiscard: onDiscard,
      ),
    );
  }
}

class IncomingMediaHandler0 extends ConsumerStatefulWidget {
  const IncomingMediaHandler0({
    required this.parentIdentifier,
    required this.incomingMedia,
    required this.onDiscard,
    required this.storeIdentity,
    required this.errorBuilder,
    required this.loadingBuilder,
    super.key,
  });
  final CLMediaFileGroup incomingMedia;
  final String parentIdentifier;
  final void Function({required bool result}) onDiscard;
  final String storeIdentity;
  final Widget Function(String errorMsg) errorBuilder;
  final Widget Function() loadingBuilder;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _IncomingMediaHandler0State();
}

class _IncomingMediaHandler0State extends ConsumerState<IncomingMediaHandler0> {
  CLSharedMedia? duplicateCandidates;
  List<StoreEntity>? newCandidates;

  bool isSaving = false;
  @override
  void didChangeDependencies() {
    duplicateCandidates = null;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    _infoLogger('build candidate: $duplicateCandidates, isSaving:$isSaving');
    _infoLogger('incoming Media: ${widget.incomingMedia}');
    final Widget widget0;
    try {
      widget0 = isSaving
          ? const Center(child: CircularProgressIndicator())
          : (duplicateCandidates == null)
              ? AnalysePage(
                  storeIdentity: widget.storeIdentity,
                  errorBuilder: widget.errorBuilder,
                  loadingBuilder: widget.loadingBuilder,
                  incomingMedia: widget.incomingMedia,
                  onDone: segretated,
                  onCancel: () => onDiscard(result: false),
                )
              : DuplicatePage(
                  incomingMedia: duplicateCandidates!,
                  parentIdentifier: widget.parentIdentifier,
                  onDone: ({required CLSharedMedia? mg}) {
                    onSave(
                      mg: CLSharedMedia(
                        entries: [
                          ...mg?.entries ?? [],
                          ...newCandidates ?? [],
                        ],
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
  }

  bool get isSavingState => isSaving;

  set isSavingState(bool val) {
    isSaving = val;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> segretated({
    required List<StoreEntity> existingEntities,
    required List<StoreEntity> newEntities,
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
        mg: CLSharedMedia(
          entries: newEntities,
          collection: widget.incomingMedia.collection,
          type: widget.incomingMedia.type,
        ),
      );
    }
  }

  Future<void> onSave({required CLSharedMedia mg}) async {
    _infoLogger(mg.toString());
    _infoLogger('onSave - Enter');
    isSavingState = true;
    widget.onDiscard(result: mg.isNotEmpty);
    await MediaWizardService.openWizard(context, ref, mg);
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
