import 'dart:io';

import 'package:colan_widgets/src/models/cl_media/extensions/io_ext_on_cl_media.dart';

import 'package:path/path.dart' as path_handler;

import '../../../views/stream_progress_view.dart';
import '../../cl_media.dart';
import '../../collection.dart';

extension IOExtOnCollection on Collection {
  void deleteDir(String pathPrefix) {
    final targetDir = path_handler.join(
      pathPrefix,
      'keep_it',
      'cluster_${id!}',
    );
    Directory(targetDir).deleteSync(recursive: true);
  }

  Future<List<CLMedia>?> addMedia({
    required List<CLMedia>? media,
    required String pathPrefix,
  }) async {
    if (media?.isEmpty ?? false) {
      final updated = <CLMedia>[];
      for (final item0 in media!) {
        final item1 = item0..setCollectionId(id);
        if (item1.isValidMedia) {
          final item = await item1.moveFile(pathPrefix: pathPrefix);
          updated.add(item);
        }
      }
      return updated;
    }
    return null;
  }

  Stream<Progress> addMediaWithProgress({
    required List<CLMedia> media,
    required String pathPrefix,
    required void Function(List<CLMedia>) onDone,
  }) async* {
    if (media.isEmpty) {
      onDone([]);
    }

    yield Progress(
      currentItem: 'processing ${media[0].basename}',
      fractCompleted: 0,
    );
    final updated = <CLMedia>[];
    for (final (i, item0) in media.indexed) {
      final item1 = item0.setCollectionId(id);
      if (item1.isValidMedia) {
        final item = await item1.moveFile(pathPrefix: pathPrefix);
        updated.add(item);
      }
      if (i + 1 < media.length) {
        yield Progress(
          currentItem: 'processing ${media[i + 1].basename}',
          fractCompleted: (i + 1) / media.length,
        );
      }
    }
    yield const Progress(
      currentItem: 'Successfully Completed',
      fractCompleted: 1,
    );
    onDone.call(updated);
  }
}
