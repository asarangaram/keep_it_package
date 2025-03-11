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
  const TabIdentifier({
    required this.view,
    required this.tabId,
  });
  final ViewIdentifier view;
  final String tabId;

  TabIdentifier copyWith({
    ViewIdentifier? view,
    String? tabId,
  }) {
    return TabIdentifier(
      view: view ?? this.view,
      tabId: tabId ?? this.tabId,
    );
  }

  @override
  String toString() => 'TapIdentifier(view: $view, tabId: $tabId)';

  @override
  bool operator ==(covariant TabIdentifier other) {
    if (identical(this, other)) return true;

    return other.view == view && other.tabId == tabId;
  }

  @override
  int get hashCode => view.hashCode ^ tabId.hashCode;
}
