import 'package:flutter/material.dart';

import 'cl_form_field_result.dart';

abstract class CLFormFieldState {
  CLFormFieldState();
  CLFormFieldResult get result;
  void dispose();
}

@immutable
class CLFormTextFieldState extends CLFormFieldState {
  CLFormTextFieldState({
    required this.controller,
    this.focusNode,
  });
  final TextEditingController controller;
  final FocusNode? focusNode;

  @override
  CLFormFieldResult get result => CLFormTextFieldResult(controller.text);

  @override
  void dispose() {
    controller.dispose();
    focusNode?.dispose();
  }

  @override
  String toString() {
    return "controller.text: ${controller.text}";
  }
}

@immutable
class CLFormSelectMultipleState extends CLFormFieldState {
  CLFormSelectMultipleState({
    required this.scrollController,
    required this.wrapKey,
    required this.searchController,
    required this.selectedEntities,
  });

  final ScrollController scrollController;
  final GlobalKey wrapKey;
  final SearchController searchController;
  final List<Object> selectedEntities;

  void scrollToEnd() {
    if (wrapKey.currentContext != null) {
      //final renderBox = wrapKey.currentContext?.findRenderObject();
      final maxScroll = scrollController.position.maxScrollExtent;
      scrollController.jumpTo(maxScroll);
    }
  }

  @override
  CLFormFieldResult get result =>
      CLFormSelectMultipleResult(List.from(selectedEntities));

  @override
  void dispose() {
    scrollController.dispose();
    searchController.dispose();
  }

  @override
  String toString() {
    return "$selectedEntities";
  }
}

@immutable
class CLFormSelectSingleState extends CLFormFieldState {
  CLFormSelectSingleState({
    required this.searchController,
    required this.selectedEntitry,
  });

  final SearchController searchController;
  final List<Object?> selectedEntitry;

  @override
  CLFormFieldResult get result => CLFormSelectSingleResult(selectedEntitry);

  @override
  void dispose() {
    searchController.dispose();
  }
}
