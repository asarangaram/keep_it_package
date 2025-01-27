import 'package:flutter/material.dart';

@immutable
class CLMenuItem {
  const CLMenuItem({
    required this.title,
    required this.icon,
    this.onTap,
  });
  final String title;
  final IconData icon;
  final Future<bool?> Function()? onTap;

  CLMenuItem copyWith({
    String? title,
    IconData? icon,
    Future<bool?> Function()? onTap,
  }) {
    return CLMenuItem(
      title: title ?? this.title,
      icon: icon ?? this.icon,
      onTap: onTap ?? this.onTap,
    );
  }

  CLMenuItem extraAction(
    void Function() action,
  ) {
    return copyWith(
      onTap: () async {
        final res = (await onTap?.call()) ?? false;

        action();
        return res;
      },
    );
  }

  CLMenuItem extraActionOnSuccess(
    void Function() action,
  ) {
    return copyWith(
      onTap: () async {
        final res = (await onTap?.call()) ?? false;

        if (res) {
          action();
        }
        return res;
      },
    );
  }
}
