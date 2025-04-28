import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:minimal_mvn/minimal_mvn.dart';

@immutable
class UIState {
  const UIState({
    this.showMenu = false,
    this.isDartTheme = false,
    this.iconColor = const Color.fromARGB(255, 80, 140, 224),
    this.entities = const [],
    this.currentIndex = 0,
  });
  final bool showMenu;
  final bool isDartTheme;
  final Color iconColor;
  final List<ViewerEntityMixin> entities;
  final int currentIndex;

  UIState copyWith({
    bool? showMenu,
    bool? isDartTheme,
    Color? iconColor,
    List<ViewerEntityMixin>? entities,
    int? currentIndex,
  }) {
    return UIState(
      showMenu: showMenu ?? this.showMenu,
      isDartTheme: isDartTheme ?? this.isDartTheme,
      iconColor: iconColor ?? this.iconColor,
      entities: entities ?? this.entities,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  @override
  bool operator ==(covariant UIState other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.showMenu == showMenu &&
        other.isDartTheme == isDartTheme &&
        other.iconColor == iconColor &&
        listEquals(other.entities, entities) &&
        other.currentIndex == currentIndex;
  }

  @override
  int get hashCode {
    return showMenu.hashCode ^
        isDartTheme.hashCode ^
        iconColor.hashCode ^
        entities.hashCode ^
        currentIndex.hashCode;
  }

  @override
  String toString() {
    return 'UIState(showMenu: $showMenu, isDartTheme: $isDartTheme, iconColor: $iconColor, entities: $entities, currentIndex: $currentIndex)';
  }

  ViewerEntityMixin get currentItem => entities[currentIndex];

  int get length => entities.length;
}

class MediaViewerUIStateNotifier extends MMNotifier<UIState> {
  MediaViewerUIStateNotifier() : super(const UIState());

  void lightTheme() => notify(state.copyWith(isDartTheme: false));
  void darkTheme() => notify(state.copyWith(isDartTheme: true));
  void toggleDarkTheme() =>
      notify(state.copyWith(isDartTheme: !state.isDartTheme));

  void showMenu() => notify(state.copyWith(showMenu: true));
  void hideMenu() => notify(state.copyWith(showMenu: false));
  void toggleMenu() => notify(state.copyWith(showMenu: !state.showMenu));

  set currIndex(int value) => notify(state.copyWith(currentIndex: value));
  int get currIndex => state.currentIndex;

  set entities(List<ViewerEntityMixin> entities) =>
      notify(state.copyWith(entities: entities));
  List<ViewerEntityMixin> get entities => state.entities;
}

final MMManager<MediaViewerUIStateNotifier> uiStateManager = MMManager(
  MediaViewerUIStateNotifier.new,
);
