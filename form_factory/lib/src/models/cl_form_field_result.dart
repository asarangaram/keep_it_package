// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

@immutable
abstract class CLFormFieldResult {
  bool get isEmpty;
}

// Possible to make this immutable?
@immutable
class CLFormTextFieldResult extends CLFormFieldResult {
  CLFormTextFieldResult(this.value);
  final String value;
  @override
  bool get isEmpty => value.isEmpty;
}

@immutable
class CLFormSelectMultipleResult extends CLFormFieldResult {
  CLFormSelectMultipleResult(this.selectedEntities);
  final List<Object> selectedEntities;
  @override
  bool get isEmpty => selectedEntities.isEmpty;
}

@immutable
class CLFormSelectSingleResult extends CLFormFieldResult {
  CLFormSelectSingleResult(this.selectedEntitry);
  final Object? selectedEntitry;
  @override
  bool get isEmpty => selectedEntitry == null;

  @override
  String toString() =>
      'CLFormSelectSingleResult(selectedEntitry: $selectedEntitry)';
}
