import 'package:flutter/material.dart';

@immutable
abstract class CLFormFieldResult {}

// Possible to make this immutable?
@immutable
class CLFormTextFieldResult extends CLFormFieldResult {}

@immutable
class CLFormSelectResult extends CLFormFieldResult {
  CLFormSelectResult(this.selectedEntities);
  final List<Object> selectedEntities;
  void insert(Object item) {
    selectedEntities.add(item);
  }

  void remove(Object item) {
    selectedEntities.remove(item);
  }
}
