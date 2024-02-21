import 'package:flutter/material.dart';

import 'cl_form_field_result.dart';

abstract class CLFormFieldState {
  CLFormFieldState({required this.result});
  final CLFormFieldResult result;
  void dispose();
}

@immutable
class CLFormTextFieldState extends CLFormFieldState {
  CLFormTextFieldState({
    required CLFormTextFieldResult result,
    required this.controller,
    this.focusNode,
  }) : super(result: result);
  final TextEditingController controller;
  final FocusNode? focusNode;

  @override
  void dispose() {
    controller.dispose();
    focusNode?.dispose();
  }
}

@immutable
class CLFormSelectState extends CLFormFieldState {
  CLFormSelectState({
    required CLFormSelectResult result,
    required this.scrollController,
    required this.wrapKey,
    required this.searchController,
  }) : super(result: result);

  final ScrollController scrollController;
  final GlobalKey wrapKey;
  final SearchController searchController;

  void insert(Object item) => (result as CLFormSelectResult).insert(item);
  void remove(Object item) => (result as CLFormSelectResult).remove(item);

  void scrollToEnd() {
    if (wrapKey.currentContext != null) {
      //final renderBox = wrapKey.currentContext?.findRenderObject();
      final maxScroll = scrollController.position.maxScrollExtent;
      scrollController.jumpTo(maxScroll);
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    searchController.dispose();
  }
}
