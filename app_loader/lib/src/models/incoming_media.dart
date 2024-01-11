// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import 'package:share_handler/share_handler.dart';

import '../utils/url_handler.dart';

extension ColonExtensionOnString on String {
  bool isURL() {
    try {
      final uri = Uri.parse(this);
      // Check if the scheme is non-empty to ensure it's a valid URL
      return uri.scheme.isNotEmpty;
    } catch (e) {
      return false; // Parsing failed, not a valid URL
    }
  }
}

@immutable
class IncomingMedia {
  final List<CLMediaInfoGroup> data;

  factory IncomingMedia(SharedMedia? sharedMedia) {
    if (sharedMedia == null) {
      return const IncomingMedia._(data: []);
    }
    final newMedia = getMedia(sharedMedia);
    return IncomingMedia._(data: [newMedia]);
  }
  const IncomingMedia._({
    required this.data,
  });

  bool get hasMedia => data.isNotEmpty;

  IncomingMedia copyWith({
    List<CLMediaInfoGroup>? data,
  }) {
    return IncomingMedia._(data: data ?? this.data);
  }

  Future<IncomingMedia> append(SharedMedia sharedMedia) async {
    final media = getMedia(sharedMedia);
    final newMedia = await receiveFiles(media);

    if (newMedia.isNotEmpty) {
      return IncomingMedia._(data: [...data, newMedia]);
    }
    return this;
  }

  Future<CLMediaInfoGroup> receiveFiles(CLMediaInfoGroup media) async {
    final newMedia = <CLMedia>[];
    for (final e in media.list) {
      switch (e.type) {
        case CLMediaType.url:
          final mimeType = await URLHandler.getMimeType(e.path);
          switch (mimeType) {
            case CLMediaType.image:
            case CLMediaType.audio:
            case CLMediaType.video:
            case CLMediaType.file:
              final r = await URLHandler.downloadAndSaveImage(e.path);
              if (r != null) {
                newMedia.add(CLMediaImage(path: r, type: mimeType!));
              } else {
                //retain as url
                newMedia.add(e);
              }

            case CLMediaType.url:
            case CLMediaType.text: // This shouldn't appear

            case null:
              newMedia.add(e);
          }
        case CLMediaType.text:
          newMedia.add(e);

        case CLMediaType.image:
        case CLMediaType.video:
        case CLMediaType.audio:
        case CLMediaType.file:
          final newFile = await FileHandler.move(e.path, toDir: 'incoming');
          newMedia.add(CLMediaImage(path: newFile, type: e.type));
      }
    }
    return CLMediaInfoGroup(newMedia);
  }

  Future<void> deleteIfExists(String fpath) async {
    final file = File(fpath);

    if (file.existsSync()) {
      debugPrint('Deleting $fpath');
      await file.delete();
    }
  }

  Future<IncomingMedia> pop() async {
    final item2Delete = data[0];

    for (final e in item2Delete.list) {
      switch (e.type) {
        case CLMediaType.text:
        case CLMediaType.url:
          break;

        case CLMediaType.image:
        case CLMediaType.video:
        case CLMediaType.audio:
        case CLMediaType.file:
          await deleteIfExists(e.path);
      }
    }

    return IncomingMedia._(data: List.from(data.sublist(1)));
  }

  static CLMediaInfoGroup getMedia(SharedMedia sharedMedia) {
    final newMedia = <CLMediaImage>[];
    if (sharedMedia.content?.isNotEmpty ?? false) {
      final text = sharedMedia.content!;
      newMedia.add(
        CLMediaImage(
          path: text,
          type: text.isURL() ? CLMediaType.url : CLMediaType.text,
        ),
      );
    }
    if (sharedMedia.imageFilePath != null) {
      newMedia.add(
        CLMediaImage(
          path: sharedMedia.imageFilePath!,
          type: CLMediaType.image,
        ),
      );
    }
    if (sharedMedia.attachments?.isNotEmpty ?? false) {
      for (final e in sharedMedia.attachments!) {
        if (e != null) {
          newMedia.add(
            CLMediaImage(
              path: e.path,
              type: switch (e.type) {
                SharedAttachmentType.image => CLMediaType.image,
                SharedAttachmentType.video => CLMediaType.video,
                SharedAttachmentType.audio => CLMediaType.audio,
                SharedAttachmentType.file => CLMediaType.file,
              },
            ),
          );
        }
      }
    }

    return CLMediaInfoGroup(newMedia);
  }

  @override
  bool operator ==(covariant IncomingMedia other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return listEquals(other.data, data);
  }

  @override
  int get hashCode => data.hashCode;
}
