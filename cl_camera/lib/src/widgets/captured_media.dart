import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CapturedMedia extends ConsumerWidget {
  const CapturedMedia({
    required this.onSendCapturedMedia,
    required this.onGeneratePreview,
    super.key,
  });

  final Widget Function(List<CLMedia>) onGeneratePreview;

  final void Function(
    List<CLMedia> capturedMedia,
  ) onSendCapturedMedia;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capturedMedia = ref.watch(capturedMediaProvider);
    if (capturedMedia.isEmpty) return Container();
    return InkWell(
      onTap: () {
        onSendCapturedMedia(List.from(capturedMedia));
        ref.read(capturedMediaProvider.notifier).clear();
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(
            10,
          ),
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            8,
          ),
          child:
              (capturedMedia.isEmpty) ? null : onGeneratePreview(capturedMedia),
        ),
      ),
    );
  }
}

class CapturedMediaNotifier extends StateNotifier<List<CLMedia>> {
  CapturedMediaNotifier() : super([]);

  void add(CLMedia media) {
    state = [...state, media];
  }

  void onDiscard() {
    for (final e in state) {
      e.deleteFile();
    }
    state = [];
  }

  void clear() {
    // Called after handing over the files to some other module.
    // We can ignore as deleting those files is the new owners responsibility
    state = [];
  }
}

final capturedMediaProvider =
    StateNotifierProvider<CapturedMediaNotifier, List<CLMedia>>((ref) {
  return CapturedMediaNotifier();
});
