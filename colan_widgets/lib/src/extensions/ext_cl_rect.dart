import 'dart:ui';

extension ExtCLRect on Rect {
  bool isSameAs(Rect other) {
    return left.ceil() == other.left.ceil() &&
        right.ceil() == other.right.ceil() &&
        top.ceil() == other.top.ceil() &&
        bottom.ceil() == other.bottom.ceil();
  }
}
