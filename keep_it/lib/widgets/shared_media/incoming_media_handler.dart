import 'package:app_loader/app_loader.dart';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it/widgets/store_manager.dart';
import 'package:store/store.dart';

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
    return StoreManager(
      builder: ({required storeAction}) => IncomingMediaHandler0(
        incomingMedia: incomingMedia,
        onDiscard: onDiscard,
        onSave: storeAction.openWizard,
      ),
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
    _infoLogger('build IncomingMediaHandler $candidate');
    final Widget widget0;
    if (isSaving) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    try {
      widget0 = FullscreenLayout(
        child: (candidate == null)
            ? AnalysePage(
                incomingMedia: widget.incomingMedia,
                onDone: onSave,
                onCancel: () => onDiscard(result: false),
              )
            : DuplicatePage(
                incomingMedia: candidate!,
                onDone: onSave,
                onCancel: () => onDiscard(result: false),
              ),
      );
    } catch (e) {
      return FullscreenLayout(
        child: CLErrorView(errorMessage: e.toString()),
      );
    }
    _infoLogger('build IncomingMediaHandler - Done');
    return widget0;
  }

  void onSave({required CLSharedMedia? mg}) {
    if (mg?.hasTargetMismatchedItems ?? false) {
      setState(() {
        candidate = mg;
      });
      return;
    }
    candidate = null;
    isSaving = true;
    if (widget.incomingMedia.type != null) {
      widget.onSave(mg?.entries ?? [], widget.incomingMedia.type!);
    }

    widget.onDiscard(result: !(mg == null || mg.isEmpty));

    if (mounted) {
      setState(() {});
    }
  }

  void onDiscard({required bool result}) {
    candidate = null;

    widget.onDiscard(result: result);
    isSaving = false;
    if (mounted) {
      setState(() {});
    }
  }
}

bool _disableInfoLogger = false;
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i(msg);
  }
}
