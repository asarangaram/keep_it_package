import 'package:extended_image/extended_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/aspect_ratio.dart' as aratio;
import '../models/editor_options.dart';

class EditorOptionsNotifier extends StateNotifier<EditorOptions> {
  EditorOptionsNotifier()
      : super(EditorOptions(controller: GlobalKey<ExtendedImageEditorState>()));

  aratio.AspectRatio? get aspectRatio => state.aspectRatio;
  set aspectRatio(aratio.AspectRatio? value) {
    state = state.copyWith(aspectRatio: value);
  }

  void rotateLeft() =>
      state = state.copyWith(rotation: (state.rotation + 1) % 4);

  void rotateRight() =>
      state = state.copyWith(rotation: (state.rotation - 1) % 4);

  bool get isAspectRatioLandscape =>
      throw Exception('Unexpected; keeping only for lint');

  set isAspectRatioLandscape(bool val) {
    state = state.copyWith(
      aspectRatio: state.aspectRatio.copyWith(isLandscape: val),
    );
  }
}

final editorOptionsProvider =
    StateNotifierProvider<EditorOptionsNotifier, EditorOptions>((ref) {
  return EditorOptionsNotifier();
});
