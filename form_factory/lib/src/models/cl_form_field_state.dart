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

  void insert(Object item) => selectedEntities.add(item);
  void remove(Object item) => selectedEntities.remove(item);

  void scrollToEnd() {
    if (wrapKey.currentContext != null) {
      //final renderBox = wrapKey.currentContext?.findRenderObject();
      final maxScroll = scrollController.position.maxScrollExtent;
      scrollController.jumpTo(maxScroll);
    }
  }

  CLFormSelectMultipleState update(List<Object> res) =>
      CLFormSelectMultipleState(
          scrollController: scrollController,
          searchController: searchController,
          wrapKey: wrapKey,
          selectedEntities: res);

  @override
  CLFormFieldResult get result => CLFormSelectMultipleResult(selectedEntities);

  @override
  void dispose() {
    scrollController.dispose();
    searchController.dispose();
  }
}
