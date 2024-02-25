import 'package:flutter/material.dart';

@immutable
abstract class CLFormFieldResult {}

// Possible to make this immutable?
@immutable
class CLFormTextFieldResult extends CLFormFieldResult {
  CLFormTextFieldResult(this.value);
  final String value;
}

@immutable
class CLFormSelectMultipleResult extends CLFormFieldResult {
  CLFormSelectMultipleResult(this.selectedEntities);
  final List<Object> selectedEntities;
}
