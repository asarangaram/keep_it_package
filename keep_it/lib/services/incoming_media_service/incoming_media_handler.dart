import 'package:app_loader/app_loader.dart';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'step1_analyse.dart';
import 'step2_duplicates.dart';

class IncomingMediaHandler extends StatelessWidget {
  const IncomingMediaHandler({
    required this.incomingMedia,
    required this.onDiscard,
    super.key,
  });
  final CLSharedMedia incomingMedia;
  final void Function({required bool result}) onDiscard;

  @override
  Widget build(BuildContext context) {
    return IncomingMediaHandler0(
      incomingMedia: incomingMedia,
      onDiscard: onDiscard,
      onSave: TheStore.of(context).openWizard,
    );
  }
}

class IncomingMediaHandler0 extends ConsumerStatefulWidget {
  const IncomingMediaHandler0({
    required this.incomingMedia,
    required this.onDiscard,
    required this.onSave,
    super.key,
  });
  final CLSharedMedia incomingMedia;
  final void Function({required bool result}) onDiscard;
  final Future<void> Function(List<CLMedia> media, UniversalMediaSource type)
      onSave;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _IncomingMediaHandler0State();
}

class _IncomingMediaHandler0State extends ConsumerState<IncomingMediaHandler0> {
  CLSharedMedia? candidate;
  bool isSaving = false;
  @override
  void didChangeDependencies() {
    candidate = null;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    _infoLogger('build candidate: $candidate, isSaving:$isSaving');
    _infoLogger('incoming Media: ${widget.incomingMedia}');
    final Widget widget0;
    try {
      widget0 = isSaving
          ? const Center(child: CircularProgressIndicator())
          : (candidate == null)
              ? AnalysePage(
                  incomingMedia: widget.incomingMedia,
                  onDone: onSave,
                  onCancel: () => onDiscard(result: false),
                )
              : DuplicatePage(
                  incomingMedia: candidate!,
                  onDone: onSave,
                  onCancel: () => onDiscard(result: false),
                );
    } catch (e) {
      return CLErrorView(errorMessage: e.toString());
    }
    _infoLogger('build IncomingMediaHandler - Done');
    return FullscreenLayout(child: widget0);
  }

  bool get isSavingState => isSaving;

  set isSavingState(bool val) {
    isSaving = val;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> onSave({required CLSharedMedia? mg}) async {
    _infoLogger(mg.toString());
    _infoLogger('onSave - Enter');
    isSavingState = true;
    {
      if (mg?.hasTargetMismatchedItems ?? false) {
        _infoLogger('duplicates found.');
        setState(() {
          candidate = mg;
        });
      } else if (mg == null || mg.isEmpty) {
        _infoLogger('nothing to save. clear incoming media');
        widget.onDiscard(result: false);
        _infoLogger('nothing to save. send notification');
        await widget.onSave([], widget.incomingMedia.type!);
        _infoLogger('nothing to save. return');
      } else {
        candidate = null;
        widget.onDiscard(result: true);
        if (widget.incomingMedia.type != null) {
          _infoLogger('saving, type: widget.incomingMedia.type ');
          await widget.onSave(mg.entries, widget.incomingMedia.type!);
          _infoLogger('Saving complete');
        }
      }
    }
    isSavingState = false;
    _infoLogger('onSave - Return');
  }

  void onDiscard({required bool result}) {
    candidate = null;
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
