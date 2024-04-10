import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/editor_options.dart';

class EditorOptionsNotifier extends StateNotifier<EditorOptions> {
  EditorOptionsNotifier() : super(const EditorOptions());

  AspectRatio? get aspectRatio => state.aspectRatio;
  set aspectRatio(AspectRatio? value) {
    state = state.copyWith(aspectRatio: value);
  }

  bool get isAspectRatioLandscape =>
      throw Exception('Unexpected; keeping only for lint');

  set isAspectRatioLandscape(bool val) {
    state = state.copyWith(
      aspectRatio: state.aspectRatio?.copyWith(isLandscape: val),
    );
  }
}

final editorOptionsProvider =
    StateNotifierProvider<EditorOptionsNotifier, EditorOptions>((ref) {
  return EditorOptionsNotifier();
});
