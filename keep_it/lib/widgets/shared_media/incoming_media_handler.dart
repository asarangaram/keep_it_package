import 'package:app_loader/app_loader.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store/store.dart';

import 'step1_analyse.dart';
import 'step2_duplicates.dart';

class IncomingMediaHandler extends ConsumerStatefulWidget {
  const IncomingMediaHandler({
    required this.incomingMedia,
    required this.onDiscard,
    super.key,
  });
  final CLSharedMedia incomingMedia;
  final void Function({required bool result}) onDiscard;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _IncomingMediaHandlerState();
}

class _IncomingMediaHandlerState extends ConsumerState<IncomingMediaHandler> {
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
    if (mg == null || mg.isEmpty) {
      candidate = null;
      isSaving = true;
      setState(() {});
      ref.read(notificationMessageProvider.notifier).push('Nothing to do.');
      onDiscard(result: false);
      return;
    }
    if (mg.hasTargetMismatchedItems) {
      setState(() {
        candidate = mg;
      });
      return;
    }
    if (widget.incomingMedia.type != null) {
      MediaWizardService.addMedia(
        context,
        ref,
        media: mg.copyWith(type: widget.incomingMedia.type),
      );
      onDiscard(result: true);
      context.push(
        '/media_wizard?type='
        '${widget.incomingMedia.type!.name}',
      );
    }
    candidate = null;
    isSaving = true;
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

bool _disableInfoLogger = true;
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i(msg);
  }
}
