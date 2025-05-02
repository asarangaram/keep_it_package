import 'package:flutter/material.dart';
import 'package:minimal_mvn/minimal_mvn.dart';

@immutable
class AppPreferences {
  const AppPreferences({
    required this.themeMode,
  });
  final ThemeMode themeMode;

  AppPreferences copyWith({
    ThemeMode? themeMode,
  }) {
    return AppPreferences(
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  String toString() => 'AppPreferences(themeMode: $themeMode)';

  @override
  bool operator ==(covariant AppPreferences other) {
    if (identical(this, other)) return true;

    return other.themeMode == themeMode;
  }

  @override
  int get hashCode => themeMode.hashCode;
}

class ThemeNotifier extends MMNotifier<AppPreferences> {
  ThemeNotifier() : super(const AppPreferences(themeMode: ThemeMode.light));

  set themeMode(ThemeMode value) => notify(state.copyWith(themeMode: value));
  ThemeMode get themeMode => state.themeMode;
}

final MMManager<ThemeNotifier> appPreferenceManager = MMManager(
  ThemeNotifier.new,
);
