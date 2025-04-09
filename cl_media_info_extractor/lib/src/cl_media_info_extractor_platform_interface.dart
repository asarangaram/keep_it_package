import 'dart:convert';
import 'dart:io';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'cl_media_info_extractor_method_channel.dart';

abstract class ClMediaInfoExtractorPlatform extends PlatformInterface {
  /// Constructs a ClMediaInfoExtractorPlatform.
  ClMediaInfoExtractorPlatform() : super(token: _token);

  static final Object _token = Object();

  static ClMediaInfoExtractorPlatform _instance =
      MethodChannelClMediaInfoExtractor();

  /// The default instance of [ClMediaInfoExtractorPlatform] to use.
  ///
  /// Defaults to [MethodChannelClMediaInfoExtractor].
  static ClMediaInfoExtractorPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ClMediaInfoExtractorPlatform] when
  /// they register themselves.
  static set instance(ClMediaInfoExtractorPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<Map<String, String>> launchApp(
      String appPath, List<String> arguments) {
    throw UnimplementedError('launchApp() has not been implemented.');
  }

  Future<Map<String, String>> runCommand(String command) async {
    if (command.isEmpty) {
      throw Exception('Command cannot be empty');
    }
    final args = splitRespectingQuotes(command);

    final appPath = args.first;
    final arguments = args.skip(1).toList();

    return launchApp(appPath, arguments);
  }

  List<String> splitRespectingQuotes(String input) {
    final regex = RegExp(r'''(?:[^\s"']+|"[^"]*"|'[^']*')+''');
    return regex.allMatches(input).map((m) {
      final match = m.group(0)!;
      // Remove surrounding quotes if any
      if ((match.startsWith('"') && match.endsWith('"')) ||
          (match.startsWith("'") && match.endsWith("'"))) {
        return match.substring(1, match.length - 1);
      }
      return match;
    }).toList();
  }

  Future<Map<String, dynamic>> getMediaInfo(
      String exiftoolPath, String mediaPath) async {
    final result = await runCommand(
        // "/usr/local/bin/exiftool  -n -j  '/Users/anandasarangaram/Downloads/WhatsApp Image 2025-03-30 at 17.28.28.jpeg'",
        "$exiftoolPath -n -j $mediaPath");
    if (result['exitCode'] == '0') {
      try {
        final jsonString = result['stdout'] ?? '';
        final jsonData = json.decode('{ "exiftool": $jsonString }');

        return jsonData as Map<String, dynamic>;
      } catch (e) {
        throw Exception('Failed to parse JSON: $e');
      }
    } else {
      throw Exception('Failed to get media info: ${result['stderr']}');
    }
  }

  String get ffprobeEntries =>
      '-show_entries stream=width,height,codec_name,r_frame_rate,duration -show_entries format=duration,size';
  Future<Map<String, dynamic>> ffprobeVideo(
      String ffprobePath, String mediaPath) async {
    final result = await runCommand(
        "$ffprobePath  -v error -select_streams v:0 $ffprobeEntries -print_format json  $mediaPath");
    if (result['exitCode'] == '0') {
      try {
        final jsonString = result['stdout'] ?? '';
        final jsonData = json.decode('{ "ffprobeVideo": $jsonString }');

        return jsonData as Map<String, dynamic>;
      } catch (e) {
        throw Exception('Failed to parse JSON: $e');
      }
    } else {
      throw Exception('Failed to get media info: ${result['stderr']}');
    }
  }

  Future<Map<String, dynamic>> ffprobeAudio(
      String ffprobePath, String mediaPath) async {
    final result = await runCommand(
        "$ffprobePath  -v error -select_streams a:0 $ffprobeEntries -print_format json  $mediaPath");
    if (result['exitCode'] == '0') {
      try {
        final jsonString = result['stdout'] ?? '';
        final jsonData = json.decode('{ "ffprobeAudio": $jsonString }');

        return jsonData as Map<String, dynamic>;
      } catch (e) {
        throw Exception('Failed to parse JSON: $e');
      }
    } else {
      throw Exception('Failed to get media info: ${result['stderr']}');
    }
  }

  Future<Map<String, dynamic>> ffprobe(
      String ffprobePath, String mediaPath) async {
    Map<String, dynamic> result = await ffprobeVideo(ffprobePath, mediaPath);

    result.addAll(await ffprobeAudio(ffprobePath, mediaPath));

    return result;
  }

  String escapePath(String path) =>
      Platform.isWindows ? '"$path"' : path.replaceAll(' ', '\\ ');

  Future<String> ffmpegGeneratePreview(String ffmpegPath, String mediaPath,
      {required String previewPath,
      required int frameFreq,
      required int dimension,
      required int tileSize}) async {
    //print(mediaPath.replaceAll(' ', '\\ '));
    final result = await runCommand(
      '$ffmpegPath '
      '-y '
      '-i '
      '$mediaPath '
      '-frames '
      '1 '
      '-q:v '
      '1 '
      '-vf '
      //'""select=not(mod(n,$frameFreq)),scale=-1:$dimension,tile=${tileSize}x$tileSize"" '
      "select='not(mod(n,\\$frameFreq))',scale=-1:$dimension,tile=${tileSize}x$tileSize "
      '-update 1 '
      "'$previewPath'",
    );

    if (result['exitCode'] == '0') {
      return previewPath;
    } else {
      throw Exception('Failed to generate media preview: ${result['stderr']}');
    }
  }
}
