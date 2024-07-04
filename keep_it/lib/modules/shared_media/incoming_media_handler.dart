import 'package:app_loader/app_loader.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'step1_analyse.dart';
import 'step2_duplicates.dart';

class IncomingMediaHandler extends ConsumerStatefulWidget {
  const IncomingMediaHandler({
    required this.incomingMedia,
    required this.onDiscard,
    super.key,
    this.moving = false,
  });
  final CLSharedMedia incomingMedia;
  final void Function({required bool result}) onDiscard;
  final bool moving;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _IncomingMediaHandlerState();
}

class _IncomingMediaHandlerState extends ConsumerState<IncomingMediaHandler> {
  CLSharedMedia? candidates;
  bool isSaving = false;
  @override
  void didChangeDependencies() {
    candidates = null;
    if (widget.moving) {
      // No need to analyze
      candidates = widget.incomingMedia;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    _infoLogger('build IncomingMediaHandler $candidates');
    final Widget widget0;
    if (isSaving) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    try {
      widget0 = FullscreenLayout(
        child: (candidates == null)
            ? AnalysePage(
                incomingMedia: widget.incomingMedia,
                onDone: onSave,
                onCancel: () => onDiscard(result: false),
              )
            : DuplicatePage(
                incomingMedia: candidates!,
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
    if (mg == null || mg.isEmpty) {
      candidates = null;
      isSaving = true;
      setState(() {});
      ref.read(notificationMessageProvider.notifier).push('Nothing to do.');
      onDiscard(result: false);
      return;
    }
    if (!widget.moving && mg.hasTargetMismatchedItems) {
      setState(() {
        candidates = mg;
      });
      return;
    }
    MediaWizardService.addMedia(
      context,
      ref,
      type: UniversalMediaTypes.imported,
      media: mg,
    );
    onDiscard(result: true);
    context.push(
      '/media_wizard?type='
      '${UniversalMediaTypes.imported.name}',
    );
    candidates = null;
    isSaving = true;
    if (mounted) {
      setState(() {});
    }
  }

  void onDone({CLSharedMedia? mg}) {
    if (mg == null || mg.isEmpty) {
      candidates = null;
      isSaving = true;
      setState(() {});
      ref.read(notificationMessageProvider.notifier).push('Nothing to do.');
      onDiscard(result: false);
      return;
    }
    setState(() {
      candidates = mg;
    });
  }

  void onDiscard({required bool result}) {
    candidates = null;

    widget.onDiscard(result: result);
    isSaving = false;
    if (mounted) {
      setState(() {});
    }
  }
}

bool _disableInfoLogger = true;
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i(msg);
  }
}
