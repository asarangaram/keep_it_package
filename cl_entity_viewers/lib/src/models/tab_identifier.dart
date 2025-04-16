// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

@immutable
class ViewIdentifier {
  const ViewIdentifier({
    required this.parentID,
    required this.viewId,
  });

  final String parentID;
  final String viewId;

  ViewIdentifier copyWith({
    String? parentID,
    String? viewId,
  }) {
    return ViewIdentifier(
      parentID: parentID ?? this.parentID,
      viewId: viewId ?? this.viewId,
    );
  }

  @override
  String toString() => 'ViewIdentifier(parentID: $parentID, viewId: $viewId)';

  @override
  bool operator ==(covariant ViewIdentifier other) {
    if (identical(this, other)) return true;

    return other.parentID == parentID && other.viewId == viewId;
  }

  @override
  int get hashCode => parentID.hashCode ^ viewId.hashCode;
}

@immutable
class TabIdentifier {
  const TabIdentifier._({
    required this.view,
  });
  factory TabIdentifier.def(ViewIdentifier view) {
    return TabIdentifier._(view: view);
  }

  final ViewIdentifier view;

  TabIdentifier copyWith({
    ViewIdentifier? view,
  }) {
    return TabIdentifier._(
      view: view ?? this.view,
    );
  }

  @override
  String toString() => 'TabIdentifier(view: $view)';

  @override
  bool operator ==(covariant TabIdentifier other) {
    if (identical(this, other)) return true;

    return other.view == view;
  }

  @override
  int get hashCode => view.hashCode;
}
