import 'dart:io';
import 'package:flutter/material.dart';
import '../../extensions/ext_string.dart';

import '../file_handler.dart';
import 'cl_media_type.dart';

@immutable
class CLMedia {
  CLMedia({
    required this.path,
    required this.type,
    this.url,
    this.previewPath,
  }) {
    if (!path.startsWith('/')) {
      path.printString();
      throw Exception('CLMedia must have absolute path');
    }
  }
  final String path;
  final CLMediaType type;
  final String? url;
  final previewWidth = 128;

  final String? previewPath;

  CLMedia copyWith({
    String? path,
    CLMediaType? type,
    String? url,
    String? previewPath,
  }) {
    return CLMedia(
      path: path ?? this.path,
      type: type ?? this.type,
      url: url ?? this.url,
      previewPath: previewPath ?? this.previewPath,
    );
  }

  Future<CLMedia> withPreview({
    bool forceCreate = false,
  }) async {
    return this;
  }

  void delete() {
    for (final f in [path, previewPath]) {
      if (f != null) {
        if (File(f).existsSync()) {
          File(f).deleteSync();
        }
      }
    }
  }

  Future<String> get relativePathFuture async => FileHandler.relativePath(path);

  Future<CLMedia> move({required String toDir}) async {
    final String? newPreviewPath;
    final String newPath;
    if (previewPath != null && File(previewPath!).existsSync()) {
      newPreviewPath = await FileHandler.move(previewPath!, toDir: toDir);
    } else {
      newPreviewPath = previewPath;
    }

    if (File(path).existsSync()) {
      newPath = await FileHandler.move(path, toDir: toDir);
    } else {
      newPath = path;
    }
    return copyWith(path: newPath, previewPath: newPreviewPath);
  }

  String get previewFileName => previewPath ?? '$path.jpg';

  @override
  String toString() {
    return 'CLMedia(path: $path, type: $type, previewPath: $previewPath, ';
  }

  @override
  bool operator ==(covariant CLMedia other) {
    if (identical(this, other)) return true;

    return other.path == path &&
        other.type == type &&
        other.previewPath == previewPath;
  }

  @override
  int get hashCode {
    return path.hashCode ^ type.hashCode ^ previewPath.hashCode;
  }

  bool get hasPreview => previewPath != null;
}

class CLMediaInfoGroup {
  CLMediaInfoGroup(this.list);
  final List<CLMedia> list;

  bool get isEmpty => list.isEmpty;
  bool get isNotEmpty => list.isNotEmpty;

  @override
  String toString() => 'CLMediaInfoGroup(list: $list)';
}

extension EXTCLMediaInfoGroupNullable on CLMediaInfoGroup? {
  List<CLMediaInfoGroup> toList() {
    if (this == null) {
      return [];
    } else {
      return [this!];
    }
  }
}

/*
extension ImageLoad on CLMedia {
  Future<ui.Image?> getImage() async {
    _infoLogger('getImage  ${this.path}');
    final absPath = await FileHandler.getAbsoluteFilePath(this.path);
    final img = switch (type) {
      CLMediaType.image => await loadImage(await tryAsImage(absPath)),
      _ => null
    };
    _infoLogger('getImage  ${this.path} - Done');
    return img;
  }

  Future<CLMedia> load() async {
    _infoLogger('loading  ${this.path}');
    final CLMedia loadedMedia;
    try {
      final absPath = await FileHandler.getAbsoluteFilePath(this.path);
      final media = copyWith(path: absPath);

      final image = await loadImage(
        await switch (media.type) {
          CLMediaType.image => tryAsImage(absPath),
          CLMediaType.video => tryAsVideo(absPath),
          _ => throw UnimplementedError()
        },
      );

      loadedMedia = switch (media.type) {
        CLMediaType.image => CLMediaImage(
            path: absPath,
            type: media.type,
            preview: image,
            data: image,
          ),
        CLMediaType.video =>
          CLMediaVideo(path: absPath, type: media.type, preview: image),
        _ => throw UnimplementedError()
      };
    } catch (err) {
      throw Exception(
        'Failed to load the media ${this.path}, $type',
      );
    }
    _infoLogger('loading  ${this.path} - Done');
    return loadedMedia;
  }

  Future<Uint8List> tryAsVideo(String mediaPath) async {
    return switch (mediaPath) {
      (final String s) when mediaPath.startsWith('/') =>
        await VideoHandler.loadVideoThumbnail(s),
      (final String s) when mediaPath.startsWith('assets') =>
        throw Exception('Video from assets is not handled: $s'),
      _ => throw Exception('Relative Path not supported.'),
    };
  }

  Future<Uint8List> tryAsImage(String mediaPath) async => switch (mediaPath) {
        (final String s) when mediaPath.startsWith('/') =>
          Uint8List.fromList(await File(s).readAsBytes()),
        (final String s) when mediaPath.startsWith('assets') =>
          (await rootBundle.load(s)).buffer.asUint8List(),
        _ => throw Exception('Relative Path not supported.'),
      };

  Future<ui.Image> loadImage(Uint8List data) async {
    final codec = await ui.instantiateImageCodec(data);
    final fi = await codec.getNextFrame();
    final uiImage = fi.image;

    return uiImage;
  }
}

class MediaNotifier extends StateNotifier<AsyncValue<CLMedia>> {
  CLMedia mediaInfo;
  MediaNotifier(this.mediaInfo) : super(const AsyncValue.loading()) {
    _get();
  }

  Future<void> _get() async {
    state = await AsyncValue.guard(
      () async => mediaInfo.load(),
    );
  }

  Future<Uint8List> tryDocumentsDir(String imagePath) async {
    final documentsDir = await FileHandler.getDocumentsDirectory(null);
    final file = File(path.join(documentsDir, imagePath));
    if (!file.existsSync()) {
      throw Exception("File doesn't exists");
    }
    final List<int> bytes = await file.readAsBytes();
    return Uint8List.fromList(bytes);
  }
}

final mediaProvider =
    StateNotifierProvider.family<MediaNotifier, AsyncValue<CLMedia>, CLMedia>(
        (ref, mediaEntry) {
  return MediaNotifier(mediaEntry);
});

bool _disableInfoLogger = true;
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i(msg);
  }
}

*/
