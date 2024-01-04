// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import 'package:share_handler/share_handler.dart';
import 'package:store/store.dart';
import '../utils/file_handler.dart';
import '../utils/url_handler.dart';

extension ColonExtensionOnString on String {
  bool isURL() {
    try {
      Uri uri = Uri.parse(this);
      // Check if the scheme is non-empty to ensure it's a valid URL
      return uri.scheme.isNotEmpty;
    } catch (e) {
      return false; // Parsing failed, not a valid URL
    }
  }
}

@immutable
class IncomingMedia {
  final List<Map<String, SupportedMediaType>> data;
  const IncomingMedia._({
    required this.data,
  });

  bool get hasMedia => data.isNotEmpty;

  factory IncomingMedia(SharedMedia? sharedMedia) {
    if (sharedMedia == null) {
      return const IncomingMedia._(data: []);
    }
    final newMedia = getMedia(sharedMedia);
    return IncomingMedia._(data: [newMedia]);
  }

  IncomingMedia copyWith({
    List<Map<String, SupportedMediaType>>? data,
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

  Future<Map<String, SupportedMediaType>> receiveFiles(
      Map<String, SupportedMediaType> media) async {
    Map<String, SupportedMediaType> newMedia = {};
    for (var e in media.entries) {
      switch (e.value) {
        case SupportedMediaType.url:
          final mimeType = await URLHandler.getMimeType(e.key);
          switch (mimeType) {
            case SupportedMediaType.image:
            case SupportedMediaType.audio:
            case SupportedMediaType.video:
            case SupportedMediaType.file:
              final String? r = await URLHandler.downloadAndSaveImage(e.key);
              if (r != null) {
                newMedia[r] = mimeType!;
              } else {
                //retain as url
                newMedia[e.key] = e.value;
              }
              break;

            case SupportedMediaType.url:
            case SupportedMediaType.text: // This shouldn't appear

            case null:
              newMedia[e.key] = e.value;
          }
          break;
        case SupportedMediaType.text:
          newMedia[e.key] = e.value;
          break;

        case SupportedMediaType.image:
        case SupportedMediaType.video:
        case SupportedMediaType.audio:
        case SupportedMediaType.file:
          final newFile = await FileHandler.move(e.key, toDir: 'incoming');
          newMedia[newFile] = e.value;
      }
    }
    return newMedia;
  }

  deleteIfExists(String fpath) async {
    final file = File(fpath);

    if (await file.exists()) {
      debugPrint("Deleting $fpath");
      await file.delete();
    }
  }

  Future<IncomingMedia> pop() async {
    final Map<String, SupportedMediaType> item2Delete = data[0];

    for (var e in item2Delete.entries) {
      switch (e.value) {
        case SupportedMediaType.text:
        case SupportedMediaType.url:
          break;

        case SupportedMediaType.image:
        case SupportedMediaType.video:
        case SupportedMediaType.audio:
        case SupportedMediaType.file:
          await deleteIfExists(e.key);
      }
    }

    return IncomingMedia._(data: List.from(data.sublist(1)));
  }

  static Map<String, SupportedMediaType> getMedia(SharedMedia sharedMedia) {
    Map<String, SupportedMediaType> newMedia = {};
    if (sharedMedia.content?.isNotEmpty ?? false) {
      final text = sharedMedia.content!;
      newMedia[text] =
          text.isURL() ? SupportedMediaType.url : SupportedMediaType.text;
    }
    if (sharedMedia.imageFilePath != null) {
      newMedia[sharedMedia.imageFilePath!] = SupportedMediaType.image;
    }
    if (sharedMedia.attachments?.isNotEmpty ?? false) {
      for (var e in sharedMedia.attachments!) {
        if (e != null) {
          newMedia[e.path] = switch (e.type) {
            SharedAttachmentType.image => SupportedMediaType.image,
            SharedAttachmentType.video => SupportedMediaType.video,
            SharedAttachmentType.audio => SupportedMediaType.audio,
            SharedAttachmentType.file => SupportedMediaType.file,
          };
        }
      }
    }

    return newMedia;
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
