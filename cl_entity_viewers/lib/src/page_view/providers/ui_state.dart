import 'dart:async';

import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class MediaViewerUIState {
  const MediaViewerUIState({
    this.showMenu = false,
    this.showPlayerMenu = false,
    this.iconColor = const Color.fromARGB(255, 80, 140, 224),
    this.entities = const [],
    this.currentIndex = 0,
  });
  final bool showMenu;
  final bool showPlayerMenu;

  final Color iconColor;
  final List<ViewerEntityMixin> entities;
  final int currentIndex;

  MediaViewerUIState copyWith({
    bool? showMenu,
    bool? showPlayerMenu,
    Color? iconColor,
    List<ViewerEntityMixin>? entities,
    int? currentIndex,
  }) {
    return MediaViewerUIState(
      showMenu: showMenu ?? this.showMenu,
      showPlayerMenu: showPlayerMenu ?? this.showPlayerMenu,
      iconColor: iconColor ?? this.iconColor,
      entities: entities ?? this.entities,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  @override
  bool operator ==(covariant MediaViewerUIState other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.showMenu == showMenu &&
        other.showPlayerMenu == showPlayerMenu &&
        other.iconColor == iconColor &&
        listEquals(other.entities, entities) &&
        other.currentIndex == currentIndex;
  }

  @override
  int get hashCode {
    return showMenu.hashCode ^
        showPlayerMenu.hashCode ^
        iconColor.hashCode ^
        entities.hashCode ^
        currentIndex.hashCode;
  }

  @override
  String toString() {
    return 'UIState(showMenu: $showMenu, showPlayerMenu: $showPlayerMenu, iconColor: $iconColor, entities: $entities, currentIndex: $currentIndex)';
  }

  ViewerEntityMixin get currentItem => entities[currentIndex];

  int get length => entities.length;
}

class MediaViewerUIStateNotifier extends StateNotifier<MediaViewerUIState> {
  MediaViewerUIStateNotifier() : super(const MediaViewerUIState());
  Timer? disableControls;
  //final Duration? defaultTimeOut = const Duration(seconds: 3);
  final Duration? defaultTimeOut = null;

  void setupTimer([Duration? Function()? getTimeout]) {
    disableControls?.cancel();
    final Duration? timeout;

    if (getTimeout != null) {
      timeout = getTimeout();
    } else {
      timeout = defaultTimeOut;
    }
    if (timeout != null) {
      disableControls = Timer(
        timeout,
        () {
          state = state.copyWith(showPlayerMenu: false);
        },
      );
    }
  }

  void notify(MediaViewerUIState value, [Duration? Function()? timeout]) {
    setupTimer(timeout);
    state = value;
  }

  void showMenu([Duration? Function()? timeout]) =>
      notify(state.copyWith(showMenu: true, showPlayerMenu: true));

  void hideMenu([Duration? Function()? timeout]) =>
      notify(state.copyWith(showMenu: false, showPlayerMenu: true));

  void toggleMenu([Duration? Function()? timeout]) =>
      notify(state.copyWith(showMenu: !state.showMenu, showPlayerMenu: true));

  void showPlayerMenu([Duration? Function()? timeout]) =>
      notify(state.copyWith(showPlayerMenu: true));

  set currIndex(int value) => notify(state.copyWith(currentIndex: value));
  int get currIndex => state.currentIndex;

  set entities(List<ViewerEntityMixin> entities) =>
      notify(state.copyWith(entities: entities));
  List<ViewerEntityMixin> get entities => state.entities;
}

final mediaViewerUIStateProvider =
    StateNotifierProvider<MediaViewerUIStateNotifier, MediaViewerUIState>(
        (ref) {
  return MediaViewerUIStateNotifier();
});
