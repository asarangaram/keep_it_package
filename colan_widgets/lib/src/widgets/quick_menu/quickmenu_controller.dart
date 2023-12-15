import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/widgets.dart';

typedef MenuBuilder = Widget Function(
    BuildContext context, BoxConstraints boxconstraints,
    {required Function() onDone});

class QuickMenuController {
  final bool isMenuShowing;

  final Size? anchorSize;
  final Offset? anchorOffset;
  final Offset? parentOffset;

  final bool edit;
  final MenuBuilder? menuBuilder;

  QuickMenuController({
    this.isMenuShowing = false,
    this.anchorSize,
    this.anchorOffset,
    this.parentOffset,
    this.edit = false,
    this.menuBuilder,
  });

  QuickMenuController copyWith(
      {GlobalKey? parentKey,
      bool? isMenuShowing,
      Size? anchorSize,
      Offset? anchorOffset,
      Offset? parentOffset,
      bool? edit,
      MenuBuilder? menuBuilder}) {
    return QuickMenuController(
        isMenuShowing: isMenuShowing ?? this.isMenuShowing,
        anchorSize: anchorSize ?? this.anchorSize,
        anchorOffset: anchorOffset ?? this.anchorOffset,
        parentOffset: parentOffset ?? this.parentOffset,
        edit: edit ?? this.edit,
        menuBuilder: menuBuilder ?? this.menuBuilder);
  }

  QuickMenuController showMenu({
    Size? region,
    required Size anchorSize,
    required Offset anchorOffset,
    required Offset parentOffset,
    required MenuBuilder? menuBuilder,
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
        anchorSize: null,
        anchorOffset: null,
        parentOffset: null,
        isMenuShowing: false,
        menuBuilder: null,
      );
}

class QuickMenuControllerNotifier extends StateNotifier<QuickMenuController> {
  QuickMenuControllerNotifier() : super(QuickMenuController());
  void showMenu({
    Size? overlaySize,
    required Size anchorSize,
    required Offset anchorOffset,
    required Offset parentOffset,
    required MenuBuilder? menuBuilder,
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
