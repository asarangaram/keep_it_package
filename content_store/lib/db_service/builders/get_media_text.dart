import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'get_media_uri.dart';

class GetMediaText extends ConsumerWidget {
  const GetMediaText({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    required this.id,
    super.key,
  });
  final Widget Function(String text) builder;
  final Widget Function(Object, StackTrace)? errorBuilder;
  final Widget Function()? loadingBuilder;
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetMediaUri(
      id: id,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      builder: (uri) {
        if (uri == null) return builder('');
        return builder(getText(uri));
      },
    );
  }

  String getText(Uri uri) {
    // FIXME: block non text files
    // if (media?.type != CLMediaType.text) return '';

    if (uri.scheme == 'file') {
      final path = uri.toFilePath();

      return File(path).existsSync()
          ? File(path).readAsStringSync()
          : 'Content Missing. File not found';
    }
    throw UnimplementedError('Implement for Server');
  }
}
