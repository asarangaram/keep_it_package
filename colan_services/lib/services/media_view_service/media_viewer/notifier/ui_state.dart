import 'package:flutter/material.dart';
import 'package:minimal_mvn/minimal_mvn.dart';

@immutable
class UIState {
  const UIState({
    this.showMenu = false,
    this.isDartTheme = false,
    this.iconColor = const Color.fromARGB(255, 80, 140, 224),
  });
  final bool showMenu;
  final bool isDartTheme;
  final Color iconColor;

  UIState copyWith({bool? showMenu, bool? isDartTheme, Color? iconColor}) {
    return UIState(
      showMenu: showMenu ?? this.showMenu,
      isDartTheme: isDartTheme ?? this.isDartTheme,
      iconColor: iconColor ?? this.iconColor,
    );
  }

  @override
  bool operator ==(covariant UIState other) {
    if (identical(this, other)) return true;

    return other.showMenu == showMenu &&
        other.isDartTheme == isDartTheme &&
        other.iconColor == iconColor;
  }

  @override
  int get hashCode =>
      showMenu.hashCode ^ isDartTheme.hashCode ^ iconColor.hashCode;

  @override
  String toString() =>
      'UIState(showMenu: $showMenu, isDartTheme: $isDartTheme, iconColor: $iconColor)';
}

class UIStateNotifier extends MMNotifier<UIState> {
  UIStateNotifier() : super(const UIState());

  void lightTheme() => notify(state.copyWith(isDartTheme: false));
  void darkTheme() => notify(state.copyWith(isDartTheme: true));
  void toggleDarkTheme() =>
      notify(state.copyWith(isDartTheme: !state.isDartTheme));

  void showMenu() => notify(state.copyWith(showMenu: true));
  void hideMenu() => notify(state.copyWith(showMenu: false));
  void toggleMenu() => notify(state.copyWith(showMenu: !state.showMenu));
}

final MMManager<UIStateNotifier> uiStateManager = MMManager(
  UIStateNotifier.new,
);
