import 'package:flutter/material.dart';

@immutable
class CLMenuItemBase {
  const CLMenuItemBase({
    required this.title,
    required this.icon,
    this.isDestructive = false,
    this.tooltip,
  });

  final String title;
  final IconData icon;
  final bool isDestructive;
  final String? tooltip;
}

@immutable
class CLMenuItem extends CLMenuItemBase {
  const CLMenuItem({
    required super.title,
    required super.icon,
    this.onTap,
    super.isDestructive = false,
    super.tooltip,
  });

  final Future<bool?> Function()? onTap;

  CLMenuItem copyWith({
    String? title,
    IconData? icon,
    Future<bool?> Function()? onTap,
    bool? isDestructive,
    String? tooltip,
  }) {
    return CLMenuItem(
      title: title ?? this.title,
      icon: icon ?? this.icon,
      onTap: onTap ?? this.onTap,
      isDestructive: isDestructive ?? this.isDestructive,
      tooltip: tooltip ?? this.tooltip,
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

  @override
  String toString() {
    return 'CLMenuItem(title: $title, icon: $icon, onTap: $onTap, isDestructive: $isDestructive, tooltip: $tooltip)';
  }

  @override
  bool operator ==(covariant CLMenuItem other) {
    if (identical(this, other)) return true;

    return other.title == title &&
        other.icon == icon &&
        other.onTap == onTap &&
        other.isDestructive == isDestructive &&
        other.tooltip == tooltip;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        icon.hashCode ^
        onTap.hashCode ^
        isDestructive.hashCode ^
        tooltip.hashCode;
  }
}

extension Ext2DCLMenuItem on List<List<CLMenuItem>> {
  List<List<CLMenuItem>> insertOnDone(
    void Function() onDone,
  ) {
    return map((list) {
      return list.map((e) => e.extraActionOnSuccess(onDone)).toList();
    }).toList();
  }
}

extension Ext1DCLMenuItem on List<CLMenuItem> {
  List<CLMenuItem> insertOnDone(
    void Function() onDone,
  ) {
    return map((e) => e.extraActionOnSuccess(onDone)).toList();
  }
}

class CLPopOverMenuItem extends CLMenuItemBase {
  const CLPopOverMenuItem({
    required super.title,
    required super.icon,
    this.menuItems = const [],
    super.isDestructive = false,
    super.tooltip,
  });
  final List<CLMenuItem> menuItems;
}
