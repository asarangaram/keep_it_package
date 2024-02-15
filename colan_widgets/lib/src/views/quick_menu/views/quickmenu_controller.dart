import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef MenuBuilder = Widget Function(
  BuildContext context,
  BoxConstraints boxconstraints, {
  required void Function() onDone,
});

class QuickMenuController {
  QuickMenuController({
    this.isMenuShowing = false,
    this.anchorSize,
    this.anchorOffset,
    this.parentOffset,
    this.edit = false,
    this.menuBuilder,
  });
  final bool isMenuShowing;

  final Size? anchorSize;
  final Offset? anchorOffset;
  final Offset? parentOffset;

  final bool edit;
  final MenuBuilder? menuBuilder;

  QuickMenuController copyWith({
    GlobalKey? parentKey,
    bool? isMenuShowing,
    Size? anchorSize,
    Offset? anchorOffset,
    Offset? parentOffset,
    bool? edit,
    MenuBuilder? menuBuilder,
  }) {
    return QuickMenuController(
      isMenuShowing: isMenuShowing ?? this.isMenuShowing,
      anchorSize: anchorSize ?? this.anchorSize,
      anchorOffset: anchorOffset ?? this.anchorOffset,
      parentOffset: parentOffset ?? this.parentOffset,
      edit: edit ?? this.edit,
      menuBuilder: menuBuilder ?? this.menuBuilder,
    );
  }

  QuickMenuController showMenu({
    required Size anchorSize,
    required Offset anchorOffset,
    required Offset parentOffset,
    required MenuBuilder? menuBuilder,
    Size? region,
  }) {
    return copyWith(
      anchorSize: anchorSize,
      anchorOffset: anchorOffset,
      parentOffset: parentOffset,
      isMenuShowing: true,
      menuBuilder: menuBuilder,
    );
  }

  QuickMenuController hideMenu() => copyWith(
        isMenuShowing: false,
      );
}

class QuickMenuControllerNotifier extends StateNotifier<QuickMenuController> {
  QuickMenuControllerNotifier() : super(QuickMenuController());
  void showMenu({
    required Size anchorSize,
    required Offset anchorOffset,
    required Offset parentOffset,
    required MenuBuilder? menuBuilder,
    Size? overlaySize,
  }) =>
      state = state.showMenu(
        region: overlaySize,
        anchorSize: anchorSize,
        anchorOffset: anchorOffset,
        parentOffset: parentOffset,
        menuBuilder: menuBuilder,
      );
  void hideMenu() => state = state.hideMenu();
}

final quickMenuControllerNotifierProvider =
    StateNotifierProvider<QuickMenuControllerNotifier, QuickMenuController>(
        (ref) {
  return QuickMenuControllerNotifier();
});
