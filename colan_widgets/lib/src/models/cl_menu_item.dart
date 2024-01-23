// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

@immutable
class CLMenuItem {
  final String title;
  final IconData icon;
  final Future<bool?> Function()? onTap;
  const CLMenuItem({
    required this.title,
    required this.icon,
    this.onTap,
  });

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
        final res = (await onTap!.call()) ?? false;

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
        final res = (await onTap!.call()) ?? false;

        if (res) {
          action();
        }
        return res;
      },
    );
  }
}
