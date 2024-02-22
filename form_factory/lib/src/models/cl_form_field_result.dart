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
class CLFormSelectResult extends CLFormFieldResult {
  CLFormSelectResult(this.selectedEntities);
  final List<Object> selectedEntities;
}
