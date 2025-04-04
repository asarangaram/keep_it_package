import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'cl_media_info_extractor_platform_interface.dart';

/// An implementation of [ClMediaInfoExtractorPlatform] that uses method channels.
class MethodChannelClMediaInfoExtractor extends ClMediaInfoExtractorPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('cl_media_info_extractor');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<Map<String, String>> launchApp(
      String appPath, List<String> arguments) async {
    try {
      final result = await methodChannel.invokeMethod('launchApp', {
        'appPath': appPath,
        'arguments': arguments,
      });
      if (result is Map) {
        return {
          'stdout': result['stdout'] as String? ?? '',
          'stderr': result['stderr'] as String? ?? '',
          "exitCode": (result['exitCode'] as int? ?? 0).toString(),
        };
      }
      return {'stdout': '', 'stderr': ''}; // Success with no output
    } on PlatformException catch (e) {
      throw Exception(
          'Failed to launch app: ${e.message}\nDetails: ${e.details}');
    }
  }
}
