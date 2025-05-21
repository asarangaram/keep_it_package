import 'package:flutter/foundation.dart';

@immutable
class MediaViewModifier {
  const MediaViewModifier({required this.quarterTurns, required this.onRotate});

  final int quarterTurns;
  final Future<void> Function(int quarterTurns) onRotate;
}
