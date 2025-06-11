// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

@immutable
class ViewIdentifier {
  const ViewIdentifier({
    required this.parentID,
    required this.viewIdDELETED,
  });

  final String parentID;
  final String viewIdDELETED;

  @override
  String toString() =>
      'ViewIdentifier(parentID: $parentID, viewId: $viewIdDELETED)';

  @override
  bool operator ==(covariant ViewIdentifier other) {
    if (identical(this, other)) return true;

    return other.parentID == parentID && other.viewIdDELETED == viewIdDELETED;
  }

  @override
  int get hashCode => parentID.hashCode ^ viewIdDELETED.hashCode;
}
