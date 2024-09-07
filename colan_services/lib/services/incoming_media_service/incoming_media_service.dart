import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../media_wizard_service/media_wizard_service.dart';
import 'models/cl_shared_media.dart';
import 'step1_analyse.dart';
import 'step2_duplicates.dart';

class IncomingMediaService extends StatelessWidget {
  const IncomingMediaService({
    required this.incomingMedia,
    required this.parentIdentifier,
    required this.onDiscard,
    super.key,
  });
  final CLMediaFileGroup incomingMedia;
  final String parentIdentifier;
  final void Function({required bool result}) onDiscard;

  @override
  Widget build(BuildContext context) {
    return IncomingMediaHandler0(
      incomingMedia: incomingMedia,
      parentIdentifier: parentIdentifier,
      onDiscard: onDiscard,
    );
  }
}

class IncomingMediaHandler0 extends ConsumerStatefulWidget {
  const IncomingMediaHandler0({
    required this.parentIdentifier,
    required this.incomingMedia,
    required this.onDiscard,
    super.key,
  });
  final CLMediaFileGroup incomingMedia;
  final String parentIdentifier;
  final void Function({required bool result}) onDiscard;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _IncomingMediaHandler0State();
}

class _IncomingMediaHandler0State extends ConsumerState<IncomingMediaHandler0> {
  CLSharedMedia? duplicateCandidates;
  List<CLMedia>? newCandidates;

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
    required List<CLMedia> existingItems,
    required List<CLMedia> newItems,
  }) async {
    if (existingItems.isNotEmpty) {
      duplicateCandidates = CLSharedMedia(
        entries: existingItems,
        collection: widget.incomingMedia.collection,
        type: widget.incomingMedia.type,
      );
      newCandidates = newItems;
    } else {
      await onSave(
        mg: CLSharedMedia(
          entries: newItems,
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
