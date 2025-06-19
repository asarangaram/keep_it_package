import 'package:flutter/material.dart';

import '../../form_factory.dart' show CLFormFieldDescriptors;
import '../views/cl_form_select_multiple.dart' show CLFormSelectMultiple;
import '../views/cl_form_select_single.dart' show CLFormSelectSingle;
import '../views/cl_form_textfield.dart' show CLFormTextField;
import 'cl_form_field_descriptors.dart'
    show
        CLFormTextFieldDescriptor,
        CLFormSelectMultipleDescriptors,
        CLFormSelectSingleDescriptors;
import 'cl_form_field_result.dart';

abstract class CLFormFieldState {
  CLFormFieldState(this.descriptor);
  final CLFormFieldDescriptors descriptor;
  CLFormFieldResult get result;
  void dispose();

  Widget formField(BuildContext context, {required void Function() onRefresh});
}

@immutable
class CLFormTextFieldState extends CLFormFieldState {
  CLFormTextFieldState(
    super.descriptor, {
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

  @override
  Widget formField(BuildContext context, {required void Function() onRefresh}) {
    return CLFormTextField(
        descriptors: descriptor as CLFormTextFieldDescriptor,
        state: this,
        onRefresh: onRefresh);
  }
}

@immutable
class CLFormSelectMultipleState extends CLFormFieldState {
  CLFormSelectMultipleState(
    super.descriptor, {
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

  @override
  Widget formField(BuildContext context, {required void Function() onRefresh}) {
    return CLFormSelectMultiple(
        descriptors: descriptor as CLFormSelectMultipleDescriptors,
        state: this,
        onRefresh: onRefresh);
  }
}

@immutable
class CLFormSelectSingleState extends CLFormFieldState {
  CLFormSelectSingleState(
    super.descriptor, {
    required this.searchController,
    required this.selectedEntitry,
    this.searchControllerListener,
  });

  final SearchController searchController;
  final List<Object?> selectedEntitry;
  final void Function()? searchControllerListener;

  @override
  CLFormFieldResult get result => CLFormSelectSingleResult(selectedEntitry);

  @override
  void dispose() {
    searchController.dispose();
  }

  @override
  Widget formField(BuildContext context, {required void Function() onRefresh}) {
    return CLFormSelectSingle(
        descriptors: descriptor as CLFormSelectSingleDescriptors,
        state: this,
        onRefresh: onRefresh);
  }
}
