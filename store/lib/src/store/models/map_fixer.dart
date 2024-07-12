import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:device_resources/device_resources.dart';
import 'package:flutter/foundation.dart';

enum PathType { any, relative, absolute }

/// Supported Features
/// Validation:
///   1. Check if all madatory keys are present
///   2. Check if the paths are valid and exists in the file system
/// Fix:
///   1. if error callback is provided and error found, abond fix if demanded
///   2. Fix path to relative or absolute
///   3. remove entries with removeValues, particularly useful to remove
///       if the value is 'null

@immutable
class MapFixer {
  const MapFixer({
    required this.pathType,
    required this.basePath,
    required this.mandatoryKeys,
    required this.pathKeys,
    required this.removeValues,
  });

  final PathType pathType;
  final String basePath;
  final List<String> mandatoryKeys;
  final List<String> pathKeys;
  final List<dynamic> removeValues;

  /// If pathType is
  /// any - the path is kept unmodified
  /// relative - if the path prefix is basePath, it will be removed and
  ///             relative path will be returned.
  ///            else, the path is kept unmodified
  /// absolute - if any path is relative path, the basePath prefix is added
  ///             else, the path is kept unmodified
  String path(String currentPath) {
    return switch (pathType) {
      PathType.any => currentPath,
      PathType.absolute =>
        currentPath.startsWith('/') ? currentPath : '$basePath/$currentPath'
          ..replaceAll('//', '/'),
      PathType.relative => currentPath.startsWith(basePath)
          ? currentPath.replaceFirst('$basePath/', '').replaceAll('//', '/')
          : currentPath
    };
  }

  List<String> validate(Map<String, dynamic> currentMap) {
    final errors = <String>[];
    // Confirm if all mandatoryKeys are present
    for (final key in mandatoryKeys) {
      if (!currentMap.containsKey(key)) {
        errors.add('MapFixer: $key is missing in currentMap');
      }
    }
    // For all paths
    for (final key in pathKeys) {
      if (currentMap.containsKey(key)) {
        final p = currentMap[key] as String;
        if (!File(p.startsWith('/') ? p : path(p)).existsSync()) {
          errors.add("MapFixer: The file $p doesn't exists");
        }
      }
    }
    return errors;
  }

  Map<String, dynamic> fix(
    Map<String, dynamic> currentMap, {
    bool Function(List<String> errors)? onError,
  }) {
    final map = <String, dynamic>{};

    for (final e in currentMap.entries) {
      final value = switch (e) {
        (final MapEntry<String, dynamic> entry) when pathKeys.contains(e.key) =>
          path(entry.value as String),
        (final MapEntry<String, dynamic> _)
            when removeValues.contains(e.value) =>
          null,
        _ => e.value
      };
      if (value != null) {
        map[e.key] = value;
      }
    }

    /// If onError Callback is provided and error found in the map
    /// invoke the call back, and if it returns false,
    /// don't parse currentMap and return null
    if (onError != null) {
      final errors = validate(currentMap);
      if (errors.isNotEmpty) {
        if (!onError(errors)) {
          return {};
        }
      }
    }

    return map;
  }
}

class NullablesFromMap {
  static Collection? collection(
    Map<String, dynamic> map, {
    required AppSettings appSettings,
  }) {
    return Collection.fromMap(map);
  }

  static MapFixer incomingMapFixer(String basePath) => MapFixer(
        pathType: PathType.absolute,
        basePath: basePath,
        mandatoryKeys: const ['type', 'path', 'md5String'],
        pathKeys: const ['path'],
        removeValues: const ['null'],
      );

  static CLMedia? media(
    Map<String, dynamic> map1, {
    required AppSettings appSettings,
  }) {
    final map = incomingMapFixer(appSettings.directories.media.pathString).fix(
      map1,
      /* onError: (errors) {
        if (errors.isNotEmpty) {
          logger.e(errors.join(','));
          return false;
        }
        return true;
      }, */
    );
    if (map.isEmpty) {
      return null;
    }
    return CLMedia.fromMap(map);
  }

  static CLNote? note(
    Map<String, dynamic> map1, {
    // ignore: avoid_unused_constructor_parameters
    required AppSettings appSettings,
  }) {
    final map = incomingMapFixer(appSettings.directories.notes.pathString).fix(
      map1,
      /* onError: (errors) {
          if (errors.isNotEmpty) {
            logger.e(errors.join(','));
            return false;
          }
          return true;
        }, */
    );
    if (map.isEmpty) {
      return null;
    }
    return CLNote.fromMap(map);
  }
}
